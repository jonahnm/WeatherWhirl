THEOS_DEVICE_IP = 10.10.10.170
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
WeatherWhirl_FILES = Tweak.x WeatherHandler.m HomeScreenView.m CloudView.m Preferences.m
WeatherWhirl_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable
WeatherWhirl_EXTRA_FRAMEWORKS = FLAnimatedImage
WeatherWhirl_LIBRARIES = MobileGestalt
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
SUBPROJECTS += weatherwhirlprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
before-all:: $(eval SHELL:=/bin/bash)
	make clean