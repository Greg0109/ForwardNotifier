#import "ForwardNotifierCC.h"

@implementation ForwardNotifierCC

//Return the icon of your module here
- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

//Return the color selection color of your module here
- (UIColor *)selectedColor {
	return [UIColor blackColor];
}

- (BOOL)isSelected {
  if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"]) {
    return TRUE;
  } else {
    return FALSE;
  }
}

- (void)setSelected:(BOOL)selected {
	_selected = selected;
  [super refreshState];
  if(_selected) {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-Status"];
  } else {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ForwardNotifier-Status"];
  }
}

@end
