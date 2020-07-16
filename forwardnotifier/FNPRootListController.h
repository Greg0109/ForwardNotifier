#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <AppList/AppList.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <SpringBoardServices/SBSRestartRenderServerAction.h>

@interface FNPRootListController : PSListController
@property (nonatomic,retain) NSMutableDictionary *savedSpecifiers;
@end

typedef struct SBIconImageInfo {
	CGSize size;
	double scale;
	double continuousCornerRadius;
} SBIconImageInfo;

@interface FBSSystemService (ForwardNotifier)
+(id)sharedService;
-(void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2 ;
@end

@interface SBSRelaunchAction (ForwardNotifier)
@property (nonatomic,copy,readonly) NSString * reason;
@property (nonatomic,readonly) unsigned long long options;
@property (nonatomic,retain,readonly) NSURL * targetURL;
+(id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3 ;
-(unsigned long long)options;
-(NSString *)reason;
-(id)initWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3 ;
-(NSURL *)targetURL;
@end


@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end

@interface OBButtonTray : UIView
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

OBWelcomeController *welcomeController;

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end
