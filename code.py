from time import sleep, time, localtime, monotonic
from ulab.numpy import mean
from random import choice
from rtc import RTC
from wifi import radio
from socketpool import SocketPool
from ssl import create_default_context
import board

import neopixel
from adafruit_led_animation.animation.solid import Solid
from adafruit_led_animation.animation.rainbowchase import RainbowChase
from adafruit_requests import Session

# Get wifi details and more from a secrets.py file
try:
    import settings
except ImportError:
    print("WiFi secrets are kept in settings.py, please add them there!")
    raise


class HTTPRequestError(Exception):
    """Exception used when making a HTTP request"""
    pass


def init():
    """Initialize the system"""
    global requests
    connect_to_wifi()
    requests = Session(SocketPool(radio), create_default_context())
    _now = update_clock()
    pixels.fill(settings.BLACK)
    pixels.show()
    return _now.tm_mday


def deque(iterable, value, max_values=10):
    """Simple implementation of collections.deque"""
    iterable.append(value)
    if len(iterable) > max_values:
        iterable.pop()


def connect_to_wifi():
    """Establish connection to WiFi network"""
    radio.hostname = settings.WIFI_HOSTNAME
    print("My MAC addr:", [hex(i) for i in radio.mac_address])
    print("Available WiFi networks:")
    pixels.fill(settings.AQUA)
    pixels.show()
    for network in radio.start_scanning_networks():
        print("\t%s\t\tRSSI: %d\tChannel: %d" % (str(network.ssid, "utf-8"), network.rssi, network.channel))
    radio.stop_scanning_networks()

    print("Connecting to %s ..." % settings.WIFI_SSID)
    pixels.fill(settings.JADE)
    pixels.show()
    radio.connect(settings.WIFI_SSID, settings.WIFI_PASSWORD)
    print("Connected to %s!" % settings.WIFI_SSID)
    pixels.fill(settings.PURPLE)
    pixels.show()
    print("My IP address is", radio.ipv4_address)


def http_request(method, url, retry_attempts: int = 0, *args, **kwargs):
    """Execute a HTTP Request"""
    print(f"{method}: {url}")
    _now = monotonic()
    try:
        resp = requests.request(method, url, *args, **kwargs)
    except (RuntimeError,) as ex:
        if retry_attempts < settings.MAX_RETRY_ATTEMPTS:
            sleep(settings.SLEEP_INTERVAL)
            return http_request(method=method, url=url, retry_attempts=retry_attempts + 1, *args, **kwargs)
        raise ex

    deque(rolling_request_duration, monotonic() - _now)
    if 429 == resp.status_code >= 500:
        if retry_attempts < settings.MAX_RETRY_ATTEMPTS:
            sleep(settings.SLEEP_INTERVAL)
            return http_request(method=method, url=url, retry_attempts=retry_attempts + 1, *args, **kwargs)
    if 400 <= resp.status_code > 500:
        print(f"Unhandled status_code for url: {url}")
        raise HTTPRequestError(resp.content)

    return resp


def update_clock():
    """Fetch and set the microcontroller's current UTC time"""
    _now = None
    try:
        print("Updating time from Adafruit IO")
        data = http_request(
            method='GET',
            url="https://io.adafruit.com/api/v2/time/seconds"
        ).text
        _now = localtime(int(data) + settings.TZ_OFFSET * 3600)
        clock.datetime = _now
    except (HTTPRequestError, OverflowError,) as ex:
        print(ex)

    return _now


def get_user_status():
    """Fetch the users status"""
    _status = None
    try:
        data = http_request(
            method='GET',
            url=f"{settings.WEBEX_BASE_URL}/people/{settings.WEBEX_USER_ID}",
            headers={
                'Authorization': f'Bearer {settings.WEBEX_BOT_TOKEN}'
            }
        ).json()
        _status = data["status"].upper()
        print(f"Status: {_status}")
    except (HTTPRequestError,) as ex:
        print(ex)
    except (KeyError, AttributeError,) as ex:
        print(f"Unable to retrieve status!")
        print(ex)

    return _status


def animate(sequence):
    """Get an animation object"""
    if sequence.animation == 'Solid':
        s = Solid(pixels, sequence.color)
    elif sequence.animation == 'RainbowChase':
        s = RainbowChase(pixels, sequence.speed, size=2, spacing=3, reverse=choice([True, False]))
    else:
        s = None
        print(f"Unknown animation: {sequence.animation}")

    return s


# Setup global variables
clock = RTC()
pixels = neopixel.NeoPixel(
    getattr(board, settings.PIXEL_PIN), settings.PIXEL_NUM, brightness=settings.PIXEL_BRIGHTNESS, auto_write=False
)
rolling_request_duration = []
timer_check_status = 0
current_status = ''
prev_status = ''
today = None
seq = None
requests = None

# Start system
today = init()
while True:
    if isinstance(seq, Solid) and seq.colors[-1] == settings.BLACK:
        sleep(settings.SLEEP_INTERVAL - mean(rolling_request_duration))

    ts_now = time()
    now = localtime(ts_now)

    # update the clock every day
    if now.tm_mday != today:
        today = update_clock().tm_mday

    # don't query during after-hours
    if settings.HOUR_START_OF_DAY > now.tm_hour > settings.HOUR_END_OF_DAY:
        print("Outside business hours, will not query")
        continue

    # check if there's a new status every so often
    if timer_check_status < ts_now:
        timer_check_status = ts_now + settings.CHECK_STATUS_EVERY_N_SEC
        current_status = get_user_status()

    if not hasattr(settings, f'STATUS_{current_status}'):
        print(f"Unknown status: {current_status}")
        continue

    if current_status != prev_status:
        seq = animate(sequence=getattr(settings, f'STATUS_{current_status}'))
        prev_status = current_status

    if hasattr(seq, 'animate'):
        seq.animate()
