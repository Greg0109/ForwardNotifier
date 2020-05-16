ARCHS = armv7 armv7s arm64 arm64e
FINALPACKAGE = 1

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ForwardNotifier

ForwardNotifier_FILES = Tweak.x
ForwardNotifier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += forwardnotifier
SUBPROJECTS += forwardnotifiercc
SUBPROJECTS += forwardnotifierreceiver
include $(THEOS_MAKE_PATH)/aggregate.mk
