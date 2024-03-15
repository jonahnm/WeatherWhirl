THEOS_PACKAGE_SCHEME = rootless
TARGET := iphone:clang:16.5:latest
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeatherWhirl

WeatherWhirl_FILES = Tweak.m WeatherHandler.m
WeatherWhirl_CFLAGS = -fobjc-arc
WeatherWhirl_PRIVATE_FRAMEWORKS = PaperBoardUI
include $(THEOS_MAKE_PATH)/tweak.mk
