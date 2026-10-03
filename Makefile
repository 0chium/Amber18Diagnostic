ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Amber18Diagnostic FlashlightObserver

Amber18Diagnostic_FILES = Tweak.xm
Amber18Diagnostic_CFLAGS = -fobjc-arc
Amber18Diagnostic_LIBRARIES = substrate

FlashlightObserver_FILES = FlashlightObserver.xm
FlashlightObserver_CFLAGS = -fobjc-arc
FlashlightObserver_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
