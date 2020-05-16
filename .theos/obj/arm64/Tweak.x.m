#line 1 "Tweak.x"
#import "Tweak.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <dlfcn.h>


BOOL receiver;
BOOL lockstateenabled;
int pcspecifier;


BOOL sshenabled;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *password;
NSString *command;


NSString *pc;
NSString *title;
NSString *message;


NSPipe *out;
static BBServer *notificationserver = nil;

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

@class SpringBoard; @class BBServer; @class SBLockStateAggregator; @class BBAction; @class BBBulletin; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBAction(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBAction"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBLockStateAggregator(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBLockStateAggregator"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$BBBulletin(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("BBBulletin"); } return _klass; }
#line 45 "Tweak.x"
static BBServer* (*_logos_orig$server$BBServer$initWithQueue$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$server$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id) _LOGOS_RETURN_RETAINED; static BBServer* (*_logos_orig$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$)(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static BBServer* _logos_method$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer*, SEL, id, id, id, id, id, id, id, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$server$BBServer$dealloc)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); static void _logos_method$server$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL); 

static BBServer* _logos_method$server$BBServer$initWithQueue$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1) _LOGOS_RETURN_RETAINED {
    notificationserver = _logos_orig$server$BBServer$initWithQueue$(self, _cmd, arg1);
    return notificationserver;
}
static BBServer* _logos_method$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(_LOGOS_SELF_TYPE_INIT BBServer* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) _LOGOS_RETURN_RETAINED {
    notificationserver = _logos_orig$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$(self, _cmd, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    return notificationserver;
}
static void _logos_method$server$BBServer$dealloc(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  if (notificationserver == self) {
    notificationserver = nil;
  }
  _logos_orig$server$BBServer$dealloc(self, _cmd);
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
  bulletin.defaultAction = [_logos_static_class_lookup$BBAction() actionWithLaunchBundleID:@"com.apple.Preferences" callblock:nil];
  dispatch_sync(getBBServerQueue(), ^{
    [notificationserver publishBulletin:bulletin destinations:14];
  });
}

BOOL isItLocked() {
  BOOL locked;
  if (lockstateenabled) {
    locked = [[_logos_static_class_lookup$SBLockStateAggregator() sharedInstance] lockState];
  } else {
    locked = TRUE;
  }
  return locked;
}

void pushnotif() {
  BOOL locked = isItLocked();
  if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
    dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
    dispatch_async(sendnotif, ^{
      pc = [NSString stringWithFormat:@"%@@%@",user,ip];
      if (pcspecifier == 0) { 
        command = [NSString stringWithFormat:@"notify-send -i applications-development \"%@\" \"%@\"",title,message];
      } else if (pcspecifier == 1) { 
        command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -title \"%@\" -message \"%@\"",title,message];
      } else if (pcspecifier == 2) { 
        command = [NSString stringWithFormat:@"ForwardNotifierReceiver \"%@\" \"%@\"",title,message];
      } else if (pcspecifier == 3) { 
        command = [NSString stringWithFormat:@"ForwardNotifierReceiver -title \"%@\" -message \"%@\"",title,message];
      }
      if (keyauthentication) {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/ssh"];
        [task setArguments:@[@"-i",password,pc,command]];
        out = [NSPipe pipe];
        [task setStandardError:out];
        [task launch];
        [task waitUntilExit];
      } else {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/sshpass"];
        [task setArguments:@[@"-p",password,@"ssh",@"-o",@"StrictHostKeyChecking=no",pc,command]];
        out = [NSPipe pipe];
        [task setStandardError:out];
        [task launch];
        [task waitUntilExit];
      }
      NSFileHandle * read = [out fileHandleForReading];
      NSData * dataRead = [read readDataToEndOfFile];
      NSString *erroroutput = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
      if ([erroroutput length] > 2) {
        testnotif(@"ForwardNotifier Error",erroroutput);
      }
    });
  }
}

static void (*_logos_orig$ssh$BBServer$publishBulletin$destinations$)(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); static void _logos_method$ssh$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST, SEL, BBBulletin *, unsigned long long); 

static void _logos_method$ssh$BBServer$publishBulletin$destinations$(_LOGOS_SELF_TYPE_NORMAL BBServer* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BBBulletin * arg1, unsigned long long arg2) {
  _logos_orig$ssh$BBServer$publishBulletin$destinations$(self, _cmd, arg1, arg2);
  title = arg1.content.title;
  message = arg1.content.message;
  if ([title length] == 0) {
    NSArray *name = [arg1.sectionID componentsSeparatedByString:@"."];
    title = [NSString stringWithFormat:@"%@",[name lastObject]];
  }
  if (![title isEqualToString:@"ForwardNotifier Error"]) {
    pushnotif();
  }
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



static __attribute__((constructor)) void _logosLocalCtor_f500bcc1(int __unused argc, char __unused **argv, char __unused **envp) {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
  receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue] : NO;
  lockstateenabled = prefs[@"lockstateenabled"] ? [prefs[@"lockstateenabled"] boolValue] : YES;
  pcspecifier = prefs[@"pcspecifier"] ? [prefs[@"pcspecifier"] intValue] : 0;

  sshenabled = prefs[@"sshenabled"] ? [prefs[@"sshenabled"] boolValue] : YES;
  keyauthentication = prefs[@"keyauthentication"] ? [prefs[@"keyauthentication"] boolValue] : NO;
  user = prefs[@"user"] && !([prefs[@"user"] isEqualToString:@""]) ? [prefs[@"user"] stringValue] : @"user";
  ip = prefs[@"ip"] && !([prefs[@"ip"] isEqualToString:@""]) ? [prefs[@"ip"] stringValue] : @"ip";
  password = prefs[@"password"] && !([prefs[@"password"] isEqualToString:@""]) ? [prefs[@"password"] stringValue] : @"password";
  user = [user stringByReplacingOccurrencesOfString:@" " withString:@""];
  ip = [ip stringByReplacingOccurrencesOfString:@" " withString:@""];
  password = [password stringByReplacingOccurrencesOfString:@" " withString:@""];

  {Class _logos_class$server$BBServer = objc_getClass("BBServer"); MSHookMessageEx(_logos_class$server$BBServer, @selector(initWithQueue:), (IMP)&_logos_method$server$BBServer$initWithQueue$, (IMP*)&_logos_orig$server$BBServer$initWithQueue$);MSHookMessageEx(_logos_class$server$BBServer, @selector(initWithQueue:dataProviderManager:syncService:dismissalSyncCache:observerListener:utilitiesListener:conduitListener:systemStateListener:settingsListener:), (IMP)&_logos_method$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$, (IMP*)&_logos_orig$server$BBServer$initWithQueue$dataProviderManager$syncService$dismissalSyncCache$observerListener$utilitiesListener$conduitListener$systemStateListener$settingsListener$);MSHookMessageEx(_logos_class$server$BBServer, sel_registerName("dealloc"), (IMP)&_logos_method$server$BBServer$dealloc, (IMP*)&_logos_orig$server$BBServer$dealloc);} if (receiver) {
    {Class _logos_class$devicereceiver$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$devicereceiver$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$devicereceiver$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$devicereceiver$SpringBoard$applicationDidFinishLaunching$);}
  }
  if (sshenabled) {



    {Class _logos_class$ssh$BBServer = objc_getClass("BBServer"); MSHookMessageEx(_logos_class$ssh$BBServer, @selector(publishBulletin:destinations:), (IMP)&_logos_method$ssh$BBServer$publishBulletin$destinations$, (IMP*)&_logos_orig$ssh$BBServer$publishBulletin$destinations$);} } }
