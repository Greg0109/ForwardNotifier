#line 1 "Tweak.x"
#import <UIKit/UIKit.h>
#include <NSTask.h>
#import <Foundation/Foundation.h>

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

@class BBContent;
@interface BBContent : NSObject
@property (nonatomic,retain) NSString * message;
@property (nonatomic,retain) NSString * title;
@end

@interface BBBulletin : NSObject
@property (nonatomic,retain) NSString * sectionID;
@property (nonatomic,retain) NSString * sectionDisplayName;
@property (nonatomic,retain) BBContent * content;
@end

@interface BBServer
-(void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2 ;
@end

@interface SBLockStateAggregator : NSObject
+(id)sharedInstance;
-(unsigned long long)lockState;
@end

BOOL receiver;
BOOL lockstateenabled;
BOOL sshenabled;
NSString *user;
NSString *ip;
NSString *password;
int pcspecifier;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; @class SBLockStateAggregator; @class BBServer; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBLockStateAggregator(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBLockStateAggregator"); } return _klass; }
#line 49 "Tweak.x"
static void (*_logos_orig$ssh$BBServer$publishBulletin$destinations$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); static void _logos_method$ssh$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); 

static void _logos_method$ssh$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BBBulletin * arg1, unsigned long long arg2) {
  _logos_orig$ssh$BBServer$publishBulletin$destinations$(self, _cmd, arg1, arg2);
  BOOL isItLocked;
  if (lockstateenabled) {
    isItLocked = [[_logos_static_class_lookup$SBLockStateAggregator() sharedInstance] lockState];
  } else {
    isItLocked = TRUE;
  }
  if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (isItLocked)) {
    dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
    dispatch_async(sendnotif, ^{
      NSString *title = arg1.content.title;
      NSString *message = arg1.content.message;
      NSString *pc = [NSString stringWithFormat:@"%@@%@",user,ip];
      if ([title length] == 0) {
        NSArray *name = [arg1.sectionID componentsSeparatedByString:@"."];
        title = [NSString stringWithFormat:@"%@",[name lastObject]];
      }
      if (pcspecifier == 0) { 
        NSString *command = [NSString stringWithFormat:@"notify-send \"%@\" \"%@\"",title,message];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/sshpass"];
        [task setArguments:@[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,command]];
        [task launch];
      } else if (pcspecifier == 1) { 
        NSString *command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -title \"%@\" -message \"%@\"",title,message];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/sshpass"];
        [task setArguments:@[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,command]];
        [task launch];
      } else if (pcspecifier == 2) { 
        NSString *command = [NSString stringWithFormat:@"ForwardNotifierReceiver \"%@\" \"%@\"",title,message];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/sshpass"];
        [task setArguments:@[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,command]];
        [task launch];
      }
    });
  }
}



static void (*_logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

static void _logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      NSString *title = notification.userInfo[@"title"];
      NSString *message = notification.userInfo[@"message"];

      [[objc_getClass("JBBulletinManager") sharedInstance] showBulletinWithTitle:title message:message bundleID:@"com.apple.Preferences"];
  }];
  _logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
}



static __attribute__((constructor)) void _logosLocalCtor_127d3fb7(int __unused argc, char __unused **argv, char __unused **envp) {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
  receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue] : NO;
  lockstateenabled = prefs[@"lockstateenabled"] ? [prefs[@"lockstateenabled"] boolValue] : YES;
  pcspecifier = prefs[@"pcspecifier"] ? [prefs[@"pcspecifier"] intValue] : 0;

  sshenabled = prefs[@"sshenabled"] ? [prefs[@"sshenabled"] boolValue] : YES;
  user = prefs[@"user"] && !([prefs[@"user"] isEqualToString:@""]) ? [prefs[@"user"] stringValue] : @"user";
  ip = prefs[@"ip"] && !([prefs[@"ip"] isEqualToString:@""]) ? [prefs[@"ip"] stringValue] : @"ip";
  password = prefs[@"password"] && !([prefs[@"password"] isEqualToString:@""]) ? [prefs[@"password"] stringValue] : @"password";
  if (receiver) {
    {Class _logos_class$devicereceiver$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$devicereceiver$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$);}
  }
  if (sshenabled) {



    {Class _logos_class$ssh$BBServer = objc_getClass("BBServer"); MSHookMessageEx(_logos_class$ssh$BBServer, @selector(publishBulletin:destinations:), (IMP)&_logos_method$ssh$BBServer$publishBulletin$destinations$, (IMP*)&_logos_orig$ssh$BBServer$publishBulletin$destinations$);} } }
