CIRCUITPY_VOLUME = /Volumes/CIRCUITPY

CIRCUITPYTHON_VERSION = 8.x
ADAFRUIT_LED_ANIMATION_VERSION = 2.8.0
ADAFRUIT_REQUESTS_VERSION = 2.0.3
NEOPIXEL_VERSION = 6.3.11
PIXELBUF_VERSION = 2.0.4

# ADAFRUIT_LED_ANIMATION
lib/adafruit_led_animation: build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION)
	rm -rf ./lib/adafruit_led_animation
	cp -R build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION)/lib/adafruit_led_animation ./lib

build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION): build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION).zip ## Install adafruit_led_animation
	unzip -o build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION).zip -d build/

build/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION).zip: ## Download files
	curl -SL --output '$@' https://github.com/adafruit/Adafruit_CircuitPython_LED_Animation/releases/download/$(ADAFRUIT_LED_ANIMATION_VERSION)/adafruit-circuitpython-led-animation-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_LED_ANIMATION_VERSION).zip

# ADAFRUIT_REQUESTS
lib/adafruit_requests.mpy: build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION) ## Install adafruit_requests
	rm -f ./lib/adafruit_requests.mpy
	cp build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION)/lib/*.mpy ./lib

build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION): build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION).zip ## Install adafruit_requests
	unzip -o build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION).zip -d build/

build/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION).zip: ## Download files
	curl -SL --output '$@' https://github.com/adafruit/Adafruit_CircuitPython_Requests/releases/download/$(ADAFRUIT_REQUESTS_VERSION)/adafruit-circuitpython-requests-$(CIRCUITPYTHON_VERSION)-mpy-$(ADAFRUIT_REQUESTS_VERSION).zip

# ADAFRUIT_NEOPIXEL
lib/neopixel.mpy: build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION) lib/adafruit_pixelbuf.mpy ## Install neopixel
	rm -f ./lib/neopixel.mpy
	cp build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION)/lib/*.mpy ./lib

build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION): build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION).zip ## Install adafruit_requests
	unzip -o build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION).zip -d build/

build/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION).zip: ## Download files
	curl -SL --output '$@' https://github.com/adafruit/Adafruit_CircuitPython_NeoPixel/releases/download/$(NEOPIXEL_VERSION)/adafruit-circuitpython-neopixel-$(CIRCUITPYTHON_VERSION)-mpy-$(NEOPIXEL_VERSION).zip

# ADAFRUIT_PIXELBUF
lib/adafruit_pixelbuf.mpy: build/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION) ## Install pixelbuf
	rm -f ./lib/adafruit_pixelbuf.mpy
	cp build/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION)/lib/*.mpy ./lib

build/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION): build/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION).zip ## Install adafruit_requests
	unzip -o $@.zip -d build/

build/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION).zip: ## Download files
	curl -SL --output $@ https://github.com/adafruit/Adafruit_CircuitPython_Pixelbuf/releases/download/$(PIXELBUF_VERSION)/adafruit-circuitpython-pixelbuf-$(CIRCUITPYTHON_VERSION)-mpy-$(PIXELBUF_VERSION).zip

stage.lib.all: lib/adafruit_requests.mpy lib/neopixel.mpy lib/adafruit_led_animation ## Install all packages
	@true

copy-files: stage.lib.all ## Copy files to attached volume
	mkdir -p $(CIRCUITPY_VOLUME)/lib
	cp -R ./lib $(CIRCUITPY_VOLUME)/lib
	cp *.py $(CIRCUITPY_VOLUME)

clean:: ## Clean build & lib directories
	rm -rf build/ lib/
	mkdir -p build/ lib/
	touch lib/.gitkeep
