#import "Tweak.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <dlfcn.h>

//Settings
BOOL receiver;
BOOL lockstateenabled;
int pcspecifier;

//Settings SSH
BOOL sshenabled;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *password;
NSString *command;

//Notifications
NSString *pc;
NSString *title;
NSString *message;

//For the error output
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

%group server
%hook BBServer
-(id)initWithQueue:(id)arg1 {
    notificationserver = %orig;
    return notificationserver;
}
-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    notificationserver = %orig;
    return notificationserver;
}
- (void)dealloc {
  if (notificationserver == self) {
    notificationserver = nil;
  }
  %orig;
}
%end
%end

void testnotif(NSString *titletest, NSString *messagetest) {
  BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];

  bulletin.title = titletest;
  bulletin.message = messagetest;
  bulletin.sectionID = @"com.apple.Preferences";   
  bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
  bulletin.date = [NSDate date];
  bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"com.apple.Preferences" callblock:nil];
  dispatch_sync(getBBServerQueue(), ^{
    [notificationserver publishBulletin:bulletin destinations:14];
  });
}

BOOL isItLocked() {
  BOOL locked;
  if (lockstateenabled) {
    locked = [[%c(SBLockStateAggregator) sharedInstance] lockState];
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
      if (pcspecifier == 0) { // Linux
        command = [NSString stringWithFormat:@"notify-send -i applications-development \"%@\" \"%@\"",title,message];
      } else if (pcspecifier == 1) { // MacOS
        command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -title \"%@\" -message \"%@\"",title,message];
      } else if (pcspecifier == 2) { // iOS
        command = [NSString stringWithFormat:@"ForwardNotifierReceiver \"%@\" \"%@\"",title,message];
      } else if (pcspecifier == 3) { // Windows
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

%group ssh
%hook BBServer
-(void)publishBulletin:(BBBulletin *)arg1 destinations:(unsigned long long)arg2 {
  %orig;
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
%end
%end

%group devicereceiver
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      NSString *titlenotif = notification.userInfo[@"title"];
      NSString *messagenotif = notification.userInfo[@"message"];
      testnotif(titlenotif,messagenotif);
  }];
  %orig;
}
%end
%end

%ctor {
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
  %init(server)
  if (receiver) {
    %init(devicereceiver);
  }
  if (sshenabled) {
    %init(ssh)
  }
}