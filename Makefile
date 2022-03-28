CIRCUITPY_VOLUME = /Volumes/CIRCUITPY

CIRCUITPYTHON_VERSION = 7.x
ADAFRUIT_LED_ANIMATION_VERSION = 2.5.14
ADAFRUIT_REQUESTS_VERSION = 1.11.1
NEOPIXEL_VERSION = 6.3.0
PIXELBUF_VERSION = 1.1.3

setup.build::
	mkdir -p build/ lib/

stage.lib.adafruit_led_animation.%:: setup.build ## Install adafruit_led_animation
	curl -SL --output build/adafruit_led_animation.zip https://github.com/adafruit/Adafruit_CircuitPython_LED_Animation/releases/download/$*/adafruit-circuitpython-led-animation-${CIRCUITPYTHON_VERSION}-mpy-$*.zip
	unzip -o build/adafruit_led_animation.zip -d build/
	rm -rf ./lib/adafruit_led_animation
	mv build/adafruit-circuitpython-led-animation-${CIRCUITPYTHON_VERSION}-mpy-$*/lib/adafruit_led_animation ./lib
	rm -f build/adafruit_led_animation.zip
	rm -rf build/adafruit-circuitpython-led-animation-${CIRCUITPYTHON_VERSION}-mpy-$*
	touch "build/$@"

stage.lib.adafruit_requests.%: setup.build ## Install adafruit_requests
	curl -SL --output build/adafruit_requests.zip https://github.com/adafruit/Adafruit_CircuitPython_Requests/releases/download/$*/adafruit-circuitpython-requests-${CIRCUITPYTHON_VERSION}-mpy-$*.zip
	unzip -o build/adafruit_requests.zip -d build/
	rm -f build/adafruit_requests.zip
	rm -f ./lib/adafruit_requests.mpy
	mv build/adafruit-circuitpython-requests-${CIRCUITPYTHON_VERSION}-mpy-$*/lib/*.mpy ./lib
	rm -rf build/adafruit-circuitpython-requests-${CIRCUITPYTHON_VERSION}-mpy-$*
	touch "build/$@"

stage.lib.neopixels.%: setup.build stage.lib.pixelbuf.$(PIXELBUF_VERSION) ## Install neopixel
	curl -SL --output build/neopixel.zip https://github.com/adafruit/Adafruit_CircuitPython_NeoPixel/releases/download/$*/adafruit-circuitpython-neopixel-${CIRCUITPYTHON_VERSION}-mpy-$*.zip
	unzip -o build/neopixel.zip -d build/
	rm -f build/neopixel.zip
	rm -f ./lib/neopixel.mpy
	mv build/adafruit-circuitpython-neopixel-${CIRCUITPYTHON_VERSION}-mpy-$*/lib/*.mpy ./lib
	rm -rf build/adafruit-circuitpython-neopixel-${CIRCUITPYTHON_VERSION}-mpy-$*
	touch "build/$@"

stage.lib.pixelbuf.%: setup.build ## Install pixelbuf
	curl -SL --output build/pixelbuf.zip https://github.com/adafruit/Adafruit_CircuitPython_Pixelbuf/releases/download/$*/adafruit-circuitpython-pixelbuf-${CIRCUITPYTHON_VERSION}-mpy-$*.zip
	unzip -o build/pixelbuf.zip -d build/
	rm -f build/pixelbuf.zip
	rm -f ./lib/adafruit_pixelbuf.mpy
	mv build/adafruit-circuitpython-pixelbuf-${CIRCUITPYTHON_VERSION}-mpy-$*/lib/*.mpy ./lib
	rm -rf build/adafruit-circuitpython-pixelbuf-${CIRCUITPYTHON_VERSION}-mpy-$*
	touch "build/$@"

stage.lib.all:: clean stage.lib.adafruit_requests.$(ADAFRUIT_REQUESTS_VERSION) stage.lib.adafruit_led_animation.$(ADAFRUIT_LED_ANIMATION_VERSION) stage.lib.neopixels.$(NEOPIXEL_VERSION) ## Install all packages
	@true

copy-files::
	mkdir -p $(CIRCUITPY_VOLUME)/lib
	cp -R ./lib $(CIRCUITPY_VOLUME)/lib
	cp *.py $(CIRCUITPY_VOLUME)

clean:: ## Clean build & lib directories
	rm -rf build/ lib/
	touch lib/.gitkeep
