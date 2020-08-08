#line 1 "Tweak.x"
#import "Tweak.h"

struct SBIconImageInfo iconspecs;


BOOL receiver;
BOOL errorlog;
BOOL lockstateenabled;
int pcspecifier;


int methodspecifier;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *port;
NSString *password;
NSString *command;
NSArray *arguments;


NSString *pc;
NSString *title;
NSString *message;
NSString *bundleID;
NSString *appName;
BOOL locked;


NSPipe *out;
static BBServer *notificationserver = nil;

static void loadPrefs() {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
  receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue] : NO;
  errorlog = prefs[@"errorlog"] ? [prefs[@"errorlog"] boolValue] : NO;
  lockstateenabled = prefs[@"lockstateenabled"] ? [prefs[@"lockstateenabled"] boolValue] : YES;
  pcspecifier = prefs[@"pcspecifier"] ? [prefs[@"pcspecifier"] intValue] : 0;

  methodspecifier = prefs[@"methodspecifier"] ? [prefs[@"methodspecifier"] intValue] : 0;
  keyauthentication = prefs[@"keyauthentication"] ? [prefs[@"keyauthentication"] boolValue] : NO;
  user = prefs[@"user"] && !([prefs[@"user"] isEqualToString:@""]) ? [prefs[@"user"] stringValue] : @"user";
  ip = prefs[@"ip"] && !([prefs[@"ip"] isEqualToString:@""]) ? [prefs[@"ip"] stringValue] : @"ip";
  port = prefs[@"port"] && !([prefs[@"port"] isEqualToString:@""]) ? [prefs[@"port"] stringValue] : @"22";
  password = prefs[@"password"] && !([prefs[@"password"] isEqualToString:@""]) ? [prefs[@"password"] stringValue] : @"password";
  user = [user stringByReplacingOccurrencesOfString:@" " withString:@""];
  ip = [ip stringByReplacingOccurrencesOfString:@" " withString:@""];
  password = [password stringByReplacingOccurrencesOfString:@" " withString:@""];
}

static dispatch_queue_t getBBServerQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        void *handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) {
                queue = *pointer;
            }
            dlclose(handle);
        }
    });
    return queue;
}


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

@class SpringBoard; @class BBAction; @class SBIconController; @class SBApplicationController; @class BBBulletin; @class SBLockStateAggregator; @class BBServer; 
static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* (*_logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$BBServer$dealloc)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBIconController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconController"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBAction(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBAction"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBApplicationController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBApplicationController"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBBulletin(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBBulletin"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBLockStateAggregator(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBLockStateAggregator"); } return _klass; }
#line 67 "Tweak.x"

static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1) _LOGOS_RETURN_RETAINED {
    notificationserver = _logos_orig$_ungrouped$BBServer$initWithQueue$(self, _cmd, arg1);
    return notificationserver;
}
static BBServer* _logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) _LOGOS_RETURN_RETAINED {
    notificationserver = _logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(self, _cmd, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    return notificationserver;
}
static void _logos_method$_ungrouped$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if (notificationserver == self) {
    notificationserver = nil;
  }
  _logos_orig$_ungrouped$BBServer$dealloc(self, _cmd);
}


void testnotif(NSString *titletest, NSString *messagetest) {
  BBBulletin *bulletin = [[_logos_static_class_lookup$BBBulletin() alloc] init];

  bulletin.title = titletest;
  bulletin.message = messagetest;
  bulletin.sectionID = @"com.apple.Preferences";
  bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.date = [NSDate date];
  bulletin.defaultAction = [_logos_static_class_lookup$BBAction() actionWithLaunchBundleID:@"prefs:root=ForwardNotifier" callblock:nil];
  dispatch_sync(getBBServerQueue(), ^{
    [notificationserver publishBulletin:bulletin destinations:14];
  });
}

BOOL isItLocked() {
  if (lockstateenabled) {
    locked = [[_logos_static_class_lookup$SBLockStateAggregator() sharedInstance] lockState];
  } else {
    locked = TRUE;
  }
  return locked;
}

void pushnotif(BOOL override) {
  if (!override) {
    isItLocked();
  } else {
    locked = TRUE;
  }
  if (methodspecifier == 0) { 
      if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
      dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
      dispatch_async(sendnotif, ^{
        pc = [NSString stringWithFormat:@"%@@%@",user,ip];
        if (pcspecifier == 0) { 
          command = [NSString stringWithFormat:@"notify-send -i applications-development \"%@\" \"%@\"",title,message];
        } else if (pcspecifier == 1) { 
          command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -sound pop -title \"%@\" -message \"%@\"",title,message];
        } else if (pcspecifier == 2) { 
          command = [NSString stringWithFormat:@"ForwardNotifierReceiver \"%@\" \"%@\"",title,message];
        } else if (pcspecifier == 3) { 
          command = [NSString stringWithFormat:@"ForwardNotifierReceiver -title \"%@\" -message \"%@\"",title,message];
        }
        if (keyauthentication) {
          if ([port isEqual:@"22"]) {
            arguments = @[@"-i",password,pc,command];
          } else {
            arguments = @[@"-i",password,pc,@"-p",port,command];
          }
          NSTask *task = [[NSTask alloc] init];
          [task setLaunchPath:@"/usr/bin/ssh"];
          [task setArguments:arguments];
          out = [NSPipe pipe];
          [task setStandardError:out];
          [task launch];
          [task waitUntilExit];
        } else {
          if ([port isEqual:@"22"]) {
            arguments = @[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,command];
          } else {
            arguments = @[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,@"-p",port,command];
          }
          NSTask *task = [[NSTask alloc] init];
          [task setLaunchPath:@"/usr/bin/sshpass"];
          [task setArguments:arguments];
          out = [NSPipe pipe];
          [task setStandardError:out];
          [task launch];
          [task waitUntilExit];
        }
        NSFileHandle * read = [out fileHandleForReading];
        NSData * dataRead = [read readDataToEndOfFile];
        NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        if ([erroroutput length] > 2 && errorlog) {
          testnotif(@"ForwardNotifier Error",erroroutput);
        }
      });
    }
  } else if (methodspecifier == 1) { 
    
    SBApplicationIcon *icon = [((SBIconController *)[_logos_static_class_lookup$SBIconController() sharedInstance]).model expectedIconForDisplayIdentifier:bundleID];
    UIImage *image = nil;
  	iconspecs.size = CGSizeMake(60, 60);
  	iconspecs.scale = [UIScreen mainScreen].scale;
  	iconspecs.continuousCornerRadius = 12;
  	image = [icon generateIconImageWithInfo:iconspecs];
    NSData *iconData = UIImagePNGRepresentation(image);
    NSString *iconBase64;
    if (![title isEqualToString:@"ForwardNotifier Test"]) {
      iconBase64 = [iconData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    } else {
      iconBase64 = forwardNotifierIconBase64;
    }
    
    NSData *titleData = [title dataUsingEncoding: NSUTF8StringEncoding];
    NSString *titleBase64 = [titleData base64EncodedStringWithOptions:0];
    NSData *messageData = [message dataUsingEncoding: NSUTF8StringEncoding];
    NSString *messageBase64 = [messageData base64EncodedStringWithOptions:0];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
      dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
      dispatch_async(sendnotif, ^{
        title = [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        if (pcspecifier == 0) { 
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Linux\", \"img\": \"%@\", \"appname\": \"%@\"}",titleBase64,messageBase64,iconBase64,appName];
        } else if (pcspecifier == 1) { 
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"MacOS\", \"img\": \"%@\"}",titleBase64,messageBase64,iconBase64];
        } else if (pcspecifier == 2) { 
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"iOS\", \"img\": \"%@\"}",titleBase64,messageBase64,iconBase64];
        } else if (pcspecifier == 3) { 
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Windows\", \"img\": \"%@\"}",titleBase64,messageBase64,iconBase64];
        }
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/curl"];
        [task setArguments:@[@"-sS",[NSString stringWithFormat:@"%@:8000",ip],@"-d",command ]];
        out = [NSPipe pipe];
        [task setStandardError:out];
        [task launch];
        [task waitUntilExit];
        NSFileHandle * read = [out fileHandleForReading];
        NSData * dataRead = [read readDataToEndOfFile];
        NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        if ([erroroutput length] > 2 && errorlog) {
          if ([erroroutput containsString:@"curl"] && ![erroroutput containsString:@"Empty reply"]) {
            testnotif(@"ForwardNotifier Error",erroroutput);
          }
        }
      });
    }
  }
}

static void (*_logos_orig$sender$BBServer$publishBulletin$destinations$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); static void _logos_method$sender$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); static void (*_logos_orig$sender$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$sender$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

static void _logos_method$sender$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BBBulletin * arg1, unsigned long long arg2) {
  _logos_orig$sender$BBServer$publishBulletin$destinations$(self, _cmd, arg1, arg2);
  title = arg1.content.title;
  message = arg1.content.message;
  bundleID = arg1.sectionID;
  SBApplication *app = [[_logos_static_class_lookup$SBApplicationController() sharedInstance] applicationWithBundleIdentifier:bundleID];
  appName = app.displayName;
  if ([title length] == 0) {
    title = app.displayName;
  }
  if (![title containsString:@"ForwardNotifier"] && [arg1.date timeIntervalSinceNow] > -2) { 
    NSMutableDictionary *applist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.greg0109.forwardnotifierblacklist"];
  	if (![applist valueForKey:arg1.sectionID] || [[NSString stringWithFormat:@"%@",[applist valueForKey:arg1.sectionID]] isEqual:@"0"]) {
      pushnotif(FALSE);
    }
  } else if ([title isEqualToString:@"ForwardNotifier Test"]) {
    pushnotif(TRUE);
  }
}



static void _logos_method$sender$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
    NSString *titlenotif = notification.userInfo[@"title"];
    NSString *messagenotif = notification.userInfo[@"message"];
    if ([titlenotif isEqualToString:@"ActivateForwardNotifier"]) {
      if ([messagenotif isEqualToString:@"true"]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-Status"];
      } else if ([messagenotif isEqualToString:@"false"]) {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ForwardNotifier-Status"];
      }
    } else {
      [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-Status"];
      title = @"ForwardNotifier Test";
      message = @"This is a test notification";
      testnotif(title,message);
    }
  }];
  _logos_orig$sender$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
}



static void (*_logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

static void _logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      NSString *titlenotif = notification.userInfo[@"title"];
      NSString *messagenotif = notification.userInfo[@"message"];
      testnotif(titlenotif,messagenotif);
  }];
  _logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
}



static __attribute__((constructor)) void _logosLocalCtor_e9f7249a(int __unused argc, char __unused **argv, char __unused **envp) {
  loadPrefs();
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.greg0109.forwardnotifierprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  {Class _logos_class$_ungrouped$BBServer = objc_getClass("BBServer"); { MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$);}{ MSHookMessageEx(_logos_class$_ungrouped$BBServer, @selector(initWithQueue:dataProviderManager:syncService:dismissalSyncCache:observerListener:utilitiesListener:conduitListener:systemStateListener:settingsListener:), (IMP)&_logos_method$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$, (IMP*)&_logos_orig$_ungrouped$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$);}{ MSHookMessageEx(_logos_class$_ungrouped$BBServer, sel_registerName("dealloc"), (IMP)&_logos_method$_ungrouped$BBServer$dealloc, (IMP*)&_logos_orig$_ungrouped$BBServer$dealloc);}}
  if (receiver) {
    {Class _logos_class$devicereceiver$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$devicereceiver$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$);}}
  } else {
    {Class _logos_class$sender$BBServer = objc_getClass("BBServer"); { MSHookMessageEx(_logos_class$sender$BBServer, @selector(publishBulletin:destinations:), (IMP)&_logos_method$sender$BBServer$publishBulletin$destinations$, (IMP*)&_logos_orig$sender$BBServer$publishBulletin$destinations$);}Class _logos_class$sender$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$sender$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$sender$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$sender$SpringBoard$applicationDidFinishLaunching$);}}
  }
}
