# Study Status LED

This repo contains the code for running [CircuitPython][1] on a [ESP32-S2][2] prototyping board,
to control illuminating a [NeoPixel][3] strip and using WiFi to get [time][7] from Adafruit IO.

In our case, we want the device to poll for the Public status of a particular user (i.e. the person currently
occupying the Study Room), and animate the [NeoPixel][3] strip outside. This will allow others
to know if the person in the room is available or not.

View a quick demo of it in action on [YouTube][17]!

## Meeting Source

We primarily use [Cisco Webex][4] for virtual meetings, and they have a simple [Bot API][5] interface we 
can leverage via simple HTTP requests. In this case, we're just going to poll for the [status][6]
of a person (myself). To simplify the code running on the [ESP32-S2][2] we'll get my own details by calling
the [/v1/people/me][8] endpoint.

## Hardware 

We wanted a _rustic_ looking pipe that could illuminate. To complete the look, we also wanted to have some frame
around the pipe where the LED would illuminate. To do this, we procured the following:
- [8-ft Pine Shiplap][9] - Frame for pipes
- [3/4-in Black Iron Floor Flange Fitting][10]
- [1-in x 3/4-in 90-Degree Black Iron Elbow Fitting][11]
- [3/4-in Black Iron Pipe][12]
- 8x 5/8-in Black Screws - Secure the Floor Flange to Shiplap
- [Gorilla Wood Glue][13] - Secure the Shiplap together
- [Test Tube 32 x 200 w/rim Borosilicate Glass][14] - Outer glass "pipe"
- [Test Tubes w/ Rim 25mm x 200mm][15] - Inner glass "pipe"

1. Cut the Shiplap into 1' long strips, then secured them together with [Wood Glue][13] and some staples at a pre-defined offset
2. Use a Dremel with diamond bits to cut the bottom off the [Test Tubes][14] to length
3. Design and 3D Print LED strip holder, 1-in Bushing, and [ESP32-S2][2] case [Files available on PrusaPrinters][16]
4. Print out and/or spray-paint a light diffuser for the smaller [Test Tube][15]
5. Drill hole behind each Floor Flange to pass wires through
6. Chisel out a path for the wires and [ESP32-S2][2] case
7. Assemble

## Setup

Installation on [ESP32-S2][2] doesn't have the concept of PIP, so we'll need to copy over the libraries to the device.

You can do this manually, or using the Makefile to automate many of these steps:
```bash
make stage.lib.all copy-files
```

### settings.py Format
```text
from collections import namedtuple
from adafruit_led_animation.color import BLACK, GOLD, JADE, AMBER, PURPLE, AQUA

Sequence = namedtuple('Sequence', 'animation speed color')

SLEEP_INTERVAL = 5
CHECK_STATUS_EVERY_N_SEC = 15
MAX_RETRY_ATTEMPTS = 5
# WiFi
WIFI_SSID = '...'
WIFI_PASSWORD = '...'
WIFI_HOSTNAME = '...'
# NeoPixel
PIXEL_PIN = 'A1'
PIXEL_PER_STRIP = 11
PIXEL_STRIPS = 3
PIXEL_NUM = PIXEL_PER_STRIP * PIXEL_STRIPS
PIXEL_BRIGHTNESS = 0.5
# API
WEBEX_BASE_URL = "https://webexapis.com/v1"
WEBEX_BOT_TOKEN = "..."
WEBEX_USER_ID = "..."
# Datetime
TZ_OFFSET = -4
HOUR_START_OF_DAY = 6
HOUR_END_OF_DAY = 21
# Speeds
SPEED_OFF = 0.0
SPEED_SLOW = 0.07
SPEED_MED = 0.05
SPEED_FAST = 0.01
# Status Color
STATUS_ACTIVE = Sequence('Solid', SPEED_OFF, BLACK)
STATUS_CALL = Sequence('Pulse', SPEED_MED, AMBER)
STATUS_DONOTDISTURB = Sequence('Comet', SPEED_MED, GOLD)
STATUS_INACTIVE = Sequence('Solid', SPEED_OFF, BLACK)
STATUS_MEETING = STATUS_CALL
STATUS_OUTOFOFFICE = STATUS_INACTIVE
STATUS_PENDING = STATUS_MEETING
STATUS_PRESENTING = Sequence('Chase', SPEED_SLOW, PURPLE)
STATUS_UNKNOWN = STATUS_INACTIVE

```

[1]: https://circuitpython.org/
[2]: https://www.adafruit.com/product/5325
[3]: https://www.adafruit.com/product/2847
[4]: https://webex.com/
[5]: https://developer.webex.com/my-apps
[6]: https://developer.webex.com/docs/api/v1/people/list-people
[7]: https://io.adafruit.com/services/time
[8]: https://developer.webex.com/docs/api/v1/people/get-my-own-details
[9]: https://www.lowes.com/pd/Rustic-5-375-in-x-8-ft-Woodshed-Pine-Shiplap-Wall-Plank-Coverage-Area-3-66-sq-ft/1000009368
[10]: https://www.lowes.com/pd/B-K-3-4-in-Black-Iron-Floor-Flange-1/1002067002
[11]: https://www.lowes.com/pd/Mueller-Proline-1-in-x-1-in-dia-90-Degree-Black-Iron-Elbow-Fitting/4331502
[12]: https://www.lowes.com/pd/Mueller-Proline-2-in-x-2-in-700-PSI-Threaded-Both-Ends-Black-Iron-Pipe/3459974
[13]: https://www.lowes.com/pd/Gorilla-Wood-Glue-Off-White-Interior-Exterior-Wood-Adhesive-Actual-Net-Contents-8-fl-oz/3121069
[14]: https://www.spectrum-scientifics.com/Test-Tube-32-x-200-w-rim-Borosilicate-Glass-p/7632.htm
[15]: https://www.spectrum-scientifics.com/Test-Tubes-w-Rim-25mm-x-200mm-p/3980.htm
[16]: https://www.prusaprinters.org/prints/155946-black-iron-pipe-led-meeting-status-indicator
[17]: https://www.youtube.com/watch?v=NC4-j7b0HwY&list=PL8L4p4mQPaKp8p0ynjlbCXPw_6nZl_98o&index=1
