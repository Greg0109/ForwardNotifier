ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ForwardNotifier

ForwardNotifier_FILES = FNPRootListController.m
ForwardNotifier_INSTALL_PATH = /Library/PreferenceBundles
ForwardNotifier_FRAMEWORKS = UIKit
ForwardNotifier_PRIVATE_FRAMEWORKS = Preferences
ForwardNotifier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ForwardNotifier.plist$(ECHO_END)
