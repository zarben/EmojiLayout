GO_EASY_ON_ME = 1
TARGET = iphone:latest:5.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = EmojiLayout
EmojiLayout_FILES = Tweak.xm
EmojiLayout_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
