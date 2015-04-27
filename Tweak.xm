#import "../PS.h"
#import <substrate.h>

@interface UIKeyboard : UIView
+ (UIKeyboard *)activeKeyboard;
+ (UIKeyboard *)activeKeyboardForScreen:(UIScreen *)screen;
+ (CGSize)defaultSize;
+ (CGSize)defaultSizeForInterfaceOrientation:(int)orientation;
+ (CGSize)defaultSizeForOrientation:(int)orientation;
@end

@interface UIKBKeyView : UIView
@end

@interface UIKBKeyplaneView : UIView
@end

@interface UIKeyboardLayout : NSObject
@end

@interface UIKeyboardLayoutStar : UIKeyboardLayout
@end

@interface UIKeyboardImpl : NSObject
+ (UIKeyboardImpl *)activeInstance;
+ (CGSize)defaultSizeForInterfaceOrientation:(int)orientation;
@end

@interface _UIEmojiScrollView : UIScrollView
@end

@interface UIKeyboardEmojiScrollView : UIKBKeyView {
	_UIEmojiScrollView *_scrollView;
}
- (void)doLayout;
@end

@interface UIKeyboardEmojiCategory : NSObject {
	int _categoryType;
	NSArray *_emoji;
	int _lastVisibleFirstEmojiIndex;
}
@property int categoryType;
@property(getter=displaySymbol, readonly) NSString *displaySymbol;
@property(retain) NSArray *emoji;
@property NSUInteger lastVisibleFirstEmojiIndex;
@property(getter=name,readonly) NSString *name;
@property(getter=recentDescription,readonly) NSString *recentDescription; // iOS 7+
+ (NSMutableArray *)categories;
+ (UIKeyboardEmojiCategory *)categoryForType:(int)type;
+ (NSArray *)emojiRecentsFromPreferences;
+ (BOOL)hasVariantsForEmoji:(NSString *)emoji; // iOS 7+
+ (NSString *)localizedStringForKey:(NSString *)key;
+ (NSInteger)numberOfCategories;
- (NSString *)displaySymbol;
- (void)releaseCategories;
@end

@interface UIKeyboardEmoji : NSObject {
	NSString *_emojiString;
	BOOL _hasDingbat;
}
@property(retain) NSString *emojiString;
@property BOOL hasDingbat;
+ (UIKeyboardEmoji *)emojiWithString:(NSString *)string;
- (id)initWithString:(NSString *)string;
+ (UIKeyboardEmoji *)emojiWithString:(NSString *)string hasDingbat:(BOOL)dingbat; // iOS 7+
- (id)initWithString:(NSString *)string hasDingbat:(BOOL)dingbat; // iOS 7+
- (BOOL)isEqual:(UIKeyboardEmoji *)emoji;
- (NSString *)key; // emojiString
@end

@interface UIKBRenderConfig : NSObject
@end

@interface UIKBTree : NSObject
@property unsigned int interactionType;
@property unsigned int rendering;
@property int state;
@property(retain, nonatomic) NSString *displayString;
@property(retain, nonatomic) NSString *representedString;
- (NSString *)name;
- (BOOL)_renderAsStringKey;
@end

@interface UIPageControl (Addition)
- (UIImage *)_pageIndicatorImage;
@end

@interface _UIEmojiPageControl : UIPageControl
@end

@interface UIKeyboardEmojiImageView : UIImageView
@end

@interface UIKeyboardEmojiPage : UIView
- (void)updateLayoutConstants;
@end

@protocol UIKeyboardEmojiPressIndicationDelegate;

@interface UIKeyboardEmojiView : UIControl {
	UIKeyboardEmoji *_emoji;
	UIView *_popup;
	UIKeyboardEmojiImageView *_imageView;
	UIKBRenderConfig *_renderConfig;
	UIView <UIKeyboardEmojiPressIndicationDelegate> *_delegate;
}
@property (retain) UIKeyboardEmoji *emoji;
@property (nonatomic, retain) UIKBRenderConfig *renderConfig;
@property (retain) UIView <UIKeyboardEmojiPressIndicationDelegate> *delegate;
@property (retain) UIView *popup;
@property (retain) UIKeyboardEmojiImageView *imageView;
+ (UIKeyboardEmojiView *)emojiViewForEmoji:(UIKeyboardEmoji *)emoji withFrame:(CGRect)frame;
+ (void)recycleEmojiView:(UIKeyboardEmojiImageView *)emojiView;
- (void)uninstallPopup;
- (id)createAndInstallKeyPopupView;
- (UIView *)popup;
- (void)setEmoji:(UIKeyboardEmoji *)emoji withFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame emoji:(UIKeyboardEmoji *)emoji;
@end

@interface UIKeyboardEmojiGraphics : NSObject
+ (CGFloat)emojiPageControlYOffset:(BOOL)portrait;
+ (CGSize)emojiSize:(BOOL)portrait;
+ (CGPoint)margin:(BOOL)portrait;
+ (CGPoint)padding:(BOOL)portrait;
+ (NSInteger)rowCount:(BOOL)portrait;
@end

@interface UIApplication (EmojiLayout)
- (int)_frontMostAppOrientation;
@end

//CGFloat emoSize = 16;
NSInteger row = IPAD ? 3 : 5;
NSInteger col = IPAD ? 12 : 8;
CGFloat margin = 8.5;

static UIKeyboardEmojiScrollView *emojiScrollView()
{
	UIKeyboardImpl *impl = [UIKeyboardImpl activeInstance];
	UIKeyboardLayoutStar *layout = MSHookIvar<UIKeyboardLayoutStar *>(impl, "m_layout");
	UIKBKeyplaneView *keyplane = MSHookIvar<UIKBKeyplaneView *>(layout, "_keyplaneView");
	NSMutableDictionary *subviewIndex = MSHookIvar<NSMutableDictionary *>(keyplane, "_subviewIndex");
	UIKeyboardEmojiScrollView *scrollView = subviewIndex[@"Emoji-InputView-Key"];
	return scrollView;
}

static CGSize emojiSize(BOOL portrait)
{
	return [%c(UIKeyboardEmojiGraphics) emojiSize:portrait];
}

static CGSize emojiScrollViewSize()
{
	UIKeyboardEmojiScrollView *scrollView = emojiScrollView();
	return scrollView ? scrollView.frame.size : CGSizeZero;
}

static CGFloat dotHeight()
{
	CGFloat height = 0.0f;
	UIKeyboardEmojiScrollView *scrollView = emojiScrollView();
	if (scrollView) {
		_UIEmojiPageControl *pageControl = MSHookIvar<_UIEmojiPageControl *>(scrollView, "_pageControl");
		height = pageControl ? pageControl.frame.size.height : [pageControl _pageIndicatorImage].size.height;
	}
	if (height == 0.0f)
		height = 14.0f;
	return height;
}

static CGFloat keyboardHeight()
{
	CGFloat height = emojiScrollViewSize().height;
	if (height == 0.0f) {
		UIKeyboard *keyboard = [UIKeyboard activeKeyboard];
		if (keyboard)
			height = keyboard.frame.size.height - 30.0f;
	}
	return height;
}

/*static CGFloat keyboardWidth()
{
	CGFloat width = emojiScrollViewSize().width;
	if (width == 0.0f) {
		UIKeyboard *keyboard = [UIKeyboard activeKeyboard];
		if (keyboard)
			width = keyboard.frame.size.width;
	}
	return width;
}

static BOOL isPortrait()
{
	UIApplication *application = [UIApplication sharedApplication];
	int orientation = [application _frontMostAppOrientation];
	return orientation == 1 || orientation == 2;
}*/

static CGFloat offset(BOOL portrait)
{
	return [%c(UIKeyboardEmojiGraphics) emojiPageControlYOffset:portrait];
}

static CGFloat paddingXForPortrait()
{
	CGFloat w = [UIKeyboardImpl defaultSizeForInterfaceOrientation:1].width;
	CGFloat padding = (w - (2 * margin) - (col * emojiSize(YES).width)) / (col - 1);
	return padding;
}

static CGFloat paddingYForPortrait()
{
	CGFloat h = keyboardHeight();
	CGFloat padding = (h - offset(YES) - dotHeight() - (2 *margin) - (row * emojiSize(YES).height)) / (row - 1);
	return padding;
}

static NSInteger bestRowForLandscape()
{
	CGFloat h = keyboardHeight();
	CGFloat paddingX = paddingXForPortrait();
	CGFloat u = h - offset(YES) - dotHeight() - margin + paddingX;
	CGFloat d = emojiSize(NO).height + paddingX;
	NSInteger bestRow = round(u/d);
	return bestRow;
}

static CGFloat paddingYForLandscape()
{
	CGFloat h = keyboardHeight();
	NSInteger bestRow = bestRowForLandscape();
	CGFloat padding = (h - offset(NO) - dotHeight() - margin - (bestRow * emojiSize(NO).height)) / (bestRow - 1);
	return padding;
}

static NSInteger bestColForLandscape()
{
	CGFloat w = [UIKeyboardImpl defaultSizeForInterfaceOrientation:3].width;
	CGFloat px = paddingXForPortrait();
	CGFloat u = (w - (2 * margin) + px);
	CGFloat d = emojiSize(NO).width + px;
	NSInteger bestCol = round(u/d);
	return bestCol;
}

static CGFloat paddingXForLandscape()
{
	CGFloat w = [UIKeyboardImpl defaultSizeForInterfaceOrientation:3].width;
	NSInteger bestCol = bestColForLandscape();
	CGFloat padding = (w - (2 * margin) - (bestCol * emojiSize(NO).width))/(bestCol - 1);
	return padding;
}

static CGPoint padding(BOOL portrait)
{
	CGPoint point;
	if (portrait)
		point = CGPointMake(paddingXForPortrait(), paddingYForPortrait());
	else
		point = CGPointMake(paddingXForLandscape(), paddingYForLandscape());
	return point;
}

%hook UIKeyboardEmojiGraphics

/*+ (CGSize)emojiSize:(BOOL)portrait
{
	return CGSizeMake(emoSize, emoSize);
}*/

+ (NSInteger)rowCount:(BOOL)portrait
{
	return portrait ? row : bestRowForLandscape();
}

+ (NSInteger)colCount:(BOOL)portrait
{
	return portrait ? col : bestColForLandscape();
}

+ (CGPoint)padding:(BOOL)portrait
{
	return padding(portrait);
}

+ (CGPoint)margin:(BOOL)portrait
{
	return CGPointMake(margin, dotHeight() + offset(portrait));
}

%end

UIKeyboardEmoji *fake;

%hook UIKeyboardEmojiPage

- (void)takeEmoji:(NSArray *)emoji fromIndex:(NSUInteger)index
{
	if (emoji.count > 0) {
		NSInteger numCols = MSHookIvar<NSInteger>(self, "_numCols");
		NSInteger numRows = MSHookIvar<NSInteger>(self, "_numRows");
		NSMutableArray *reorderedEmoji = [NSMutableArray array];
		for (NSUInteger row = 0; row < numRows; row++) {
			for (NSUInteger count = 0; count < numCols; count++) {
				NSUInteger emojiIndex = (count * numRows) + row;
				if (emojiIndex < emoji.count) {
					UIKeyboardEmoji *emo = emoji[emojiIndex];
					[reorderedEmoji addObject:emo];
				} else {
					if (fake)
						[reorderedEmoji addObject:fake];
				}
			}
		}
		%orig(reorderedEmoji, index);
		return;
	}
	%orig;	
}

%end

%hook UIKeyboardEmojiCategory

+ (BOOL)hasVariantsForEmoji:(NSString *)emoji
{
	if ([emoji isEqualToString:@" "])
		return NO;
	return %orig;
}

%end

%ctor
{
	%init;
	fake = [NSClassFromString(@"UIKeyboardEmoji") respondsToSelector:@selector(emojiWithString:hasDingbat:)] ? [NSClassFromString(@"UIKeyboardEmoji") emojiWithString:@" " hasDingbat:NO]
				: [NSClassFromString(@"UIKeyboardEmoji") emojiWithString:@" "];
}