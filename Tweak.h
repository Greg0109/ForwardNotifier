#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <dlfcn.h>
#include <NSTask.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end

@interface JBBulletinManager : NSObject
  +(id)sharedInstance;
  -(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
  -(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID hasSound:(BOOL)hasSound soundID:(int)soundID vibrateMode:(int)vibrate soundPath:(NSString *)soundPath attachmentImage:(UIImage *)attachmentImage overrideBundleImage:(UIImage *)overrideBundleImage;
@end

@interface SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 ;
@end

@interface BBAction : NSObject

+(id)actionWithLaunchURL:(id)arg1 callblock:(/*^block*/id)arg2 ;
+(id)actionWithLaunchBundleID:(id)arg1 callblock:(/*^block*/id)arg2 ;
+(id)actionWithCallblock:(/*^block*/id)arg1 ;
+(id)actionWithAppearance:(id)arg1 ;
+(id)actionWithLaunchURL:(id)arg1 ;
+(id)actionWithActivatePluginName:(id)arg1 activationContext:(id)arg2 ;
+(id)actionWithIdentifier:(id)arg1 ;
+(id)actionWithIdentifier:(id)arg1 title:(id)arg2 ;
+(id)actionWithLaunchBundleID:(id)arg1 ;
@end

@class BBContent;
@interface BBContent : NSObject
@property (nonatomic,retain) NSString * message;
@property (nonatomic,retain) NSString * title;
@end

@interface BBSectionIcon : NSObject
@end

@interface BBBulletin : NSObject
@property (nonatomic,retain) NSString * message;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,retain) NSString * sectionID;
@property (nonatomic,retain) BBSectionIcon * icon;
@property (nonatomic,retain) NSString * bulletinID;
@property (nonatomic,retain) NSString * recordID;
@property (nonatomic,retain) NSString * publisherBulletinID;
@property (nonatomic,retain) NSString * sectionDisplayName;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,copy) BBAction * defaultAction;
@property (nonatomic,retain) BBContent * content;
@end

@interface BBServer
-(void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2 ;
@end

@interface SBLockStateAggregator : NSObject
+(id)sharedInstance;
-(unsigned long long)lockState;
@end
