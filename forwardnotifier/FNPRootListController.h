#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface FNPRootListController : PSListController
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end
