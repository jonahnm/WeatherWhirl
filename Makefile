SHELL := /bin/bash
THEOS_PACKAGE_SCHEME = rootless
ifdef ROOTFUL
$(shell test -f controlrootful && mv control controlrootless)
$(shell test -f controlrootful && mv controlrootful control)
THEOS_PACKAGE_SCHEME = rootful
else
$(shell test -f controlrootless && mv control controlrootful)
$(shell test -f controlrootless && mv controlrootless control)
endif
TWEAK_NAME = WeatherWhirl
WeatherWhirl_FILES = Tweak.m WeatherHandler.m HomeScreenView.m CloudView.m RainViewController.m
WeatherWhirl_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
WeatherWhirl_EXTRA_FRAMEWORKS = FLAnimatedImage
ifdef ROOTFUL
WeatherWhirl_LDFLAGS += -rpath /Library/Frameworks
endif
ifndef FORSIM
TARGET := iphone:clang:16.5:15.0
else
TARGET = simulator:latest:15.0
ARCHS = x86_64
WeatherWhirl_FRAMEWORKS := CydiaSubstrate
endif
INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk