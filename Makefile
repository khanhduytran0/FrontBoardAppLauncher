ARCHS := arm64
PACKAGE_FORMAT := ipa
TARGET := iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = FrontBoardAppLauncher

FrontBoardAppLauncher_FILES = \
  AppDelegate.m SceneDelegate.m ViewController.m main.m
FrontBoardAppLauncher_FRAMEWORKS = UIKit
FrontBoardAppLauncher_PRIVATE_FRAMEWORKS = FrontBoard RunningBoardServices
FrontBoardAppLauncher_CFLAGS = -fcommon -fobjc-arc -Iinclude -I. -Wno-error
# FrontBoardAppLauncher_LDFLAGS =
FrontBoardAppLauncher_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
