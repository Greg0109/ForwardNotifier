#import "Tweak.h"

//Settings
BOOL receiver;
BOOL errorlog;
BOOL lockstateenabled;
BOOL chargingenabled;
int pcspecifier;

//Settings
int methodspecifier;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *port;
NSString *password;
NSString *command;
NSArray *arguments;

//Notifications
NSString *pc;
NSString *title;
NSString *message;
NSString *image;
BOOL locked;
long long previousState = 0;

//For the error output
NSPipe *out;
static BBServer *notificationserver = nil;

static void loadPrefs() {
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.greg0109.forwardnotifierprefs.plist"];
  receiver = prefs[@"receiver"] ? [prefs[@"receiver"] boolValue] : NO;
  errorlog = prefs[@"errorlog"] ? [prefs[@"errorlog"] boolValue] : NO;
  chargingenabled = prefs[@"chargingenabled"] ? [prefs[@"chargingenabled"] boolValue] : NO;
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
  if (lockstateenabled) {
    locked = [[%c(SBLockStateAggregator) sharedInstance] lockState];
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
  if (methodspecifier == 0) { // SSH
      if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
      dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
      dispatch_async(sendnotif, ^{
        pc = [NSString stringWithFormat:@"%@@%@",user,ip];
        if (pcspecifier == 0) { // Linux
          command = [NSString stringWithFormat:@"notify-send -i applications-development \"%@\" \"%@\"",title,message];
        } else if (pcspecifier == 1) { // MacOS
          command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -sound pop -title \"%@\" -message \"%@\"",title,message];
        } else if (pcspecifier == 2) { // iOS
          command = [NSString stringWithFormat:@"ForwardNotifierReceiver \"%@\" \"%@\"",title,message];
        } else if (pcspecifier == 3) { // Windows
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
  } else if (methodspecifier == 1) { // Crossplatform Server
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
      dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
      dispatch_async(sendnotif, ^{
        title = [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        if (pcspecifier == 0) { // Linux
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Linux\"}",title,message];
        } else if (pcspecifier == 1) { // MacOS
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"MacOS\"}",title,message];
        } else if (pcspecifier == 2) { // iOS
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"iOS\"}",title,message];
        } else if (pcspecifier == 3) { // Windows
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Windows\"}",title,message];
        }
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/curl"];
        [task setArguments:@[[NSString stringWithFormat:@"%@:8000",ip],@"-d",command ]];
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
  if (![title containsString:@"ForwardNotifier"] && [arg1.date timeIntervalSinceNow] > -2) { //This helps avoid the notifications to get forwarded again after a respring, which makes them avoid respring loops. If notifications are 2 seconds old, then won't get forwarded.
    NSMutableDictionary *applist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.greg0109.forwardnotifierblacklist"];
  	if (![applist valueForKey:arg1.sectionID] || [[NSString stringWithFormat:@"%@",[applist valueForKey:arg1.sectionID]] isEqual:@"0"]) {
      pushnotif(FALSE);
    }
  } else if ([title isEqualToString:@"ForwardNotifier Test"]) {
    pushnotif(TRUE);
  }
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
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
      title = @"ForwardNotifier Test";
      message = @"This is a test notification";
      testnotif(title,message);
    }
  }];
  %orig;
}
%end
%end

%group charging
%hook UIDevice // Enable when charging - Disable when charging
-(void)_setBatteryState:(long long)arg1 {
  if (arg1 == 2 && previousState != arg1) { // Chargin
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-Status"];
    previousState = arg1;
  } else if (arg1 == 1 && previousState != arg1) { // 1 -> Not charging
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ForwardNotifier-Status"];
    previousState = arg1;
  }
  %orig;
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
  loadPrefs();
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.greg0109.forwardnotifierprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  %init();
  if (chargingenabled) {
    %init(charging);
  }
  if (receiver) {
    %init(devicereceiver);
  } else {
    %init(ssh);
  }
}
