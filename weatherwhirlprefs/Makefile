ARCHS = arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WeatherWhirlPrefs

WeatherWhirlPrefs_FRAMEWORKS = SwiftUI
WeatherWhirlPrefs_FILES = $(shell find Sources/WeatherWhirlPrefs -name '*.swift') $(shell find Sources/WeatherWhirlPrefsC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
WeatherWhirlPrefs_SWIFTFLAGS = -ISources/WeatherWhirlPrefsC/include
WeatherWhirlPrefs_INSTALL_PATH = /Library/PreferenceBundles
WeatherWhirlPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
