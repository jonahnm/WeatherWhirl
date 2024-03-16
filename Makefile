ifndef FORSIM
THEOS_PACKAGE_SCHEME = rootless
endif
TWEAK_NAME = WeatherWhirl
WeatherWhirl_FILES = Tweak.m WeatherHandler.m
WeatherWhirl_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
WeatherWhirl_LDFLAGS = -L$(THEOS_OBJ_DIR)
ifndef FORSIM
TARGET := iphone:clang:16.5:15.0
else
TARGET = simulator:latest:15.0
ARCHS = x86_64
WeatherWhirl_FRAMEWORKS = CydiaSubstrate
endif
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
