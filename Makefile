ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Amber18Diagnostic
Amber18Diagnostic_FILES = Tweak.xm
Amber18Diagnostic_CFLAGS = -fobjc-arc
Amber18Diagnostic_LIBRARIES = substrate
include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = Amber18CCModule
Amber18CCModule_FILES = Amber18CCModule/Amber18CCModule.mm
Amber18CCModule_CFLAGS = -fobjc-arc
Amber18CCModule_PRIVATE_FRAMEWORKS = ControlCenterUIKit SpringBoardUI
Amber18CCModule_INSTALL_PATH = /Library/ControlCenter/Bundles
Amber18CCModule_RESOURCE_FILES = Amber18CCModule/Info.plist
include $(THEOS_MAKE_PATH)/bundle.mk

LIBRARY_NAME = Amber18NativeFlashlightProbe
Amber18NativeFlashlightProbe_FILES = NativeFlashlightProbe/NativeFlashlightProbe.m
Amber18NativeFlashlightProbe_CFLAGS = -fobjc-arc
Amber18NativeFlashlightProbe_PRIVATE_FRAMEWORKS = SpringBoardUI
Amber18NativeFlashlightProbe_INSTALL_PATH = /usr/lib
include $(THEOS_MAKE_PATH)/library.mk
