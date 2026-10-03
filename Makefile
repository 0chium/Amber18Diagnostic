ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Amber18Diagnostic

Amber18Diagnostic_FILES = Tweak.xm
Amber18Diagnostic_CFLAGS = -fobjc-arc
Amber18Diagnostic_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
