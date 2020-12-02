#import "Tweak.h"

struct SBIconImageInfo iconspecs;

//Settings
BOOL receiver;
BOOL errorlog;
BOOL lockstateenabled;
int pcspecifier;

//Settings
int methodspecifier;
BOOL keyauthentication;
NSString *user;
NSString *ip;
NSString *port;
NSString *password;
NSString *command;
NSString *finalCommand;
NSArray *arguments;

//Notifications
NSString *pc;
NSString *title;
NSMutableString *finalTitle;
NSString *message;
NSMutableString *finalMessage;
NSString *bundleID;
NSString *appName;
BOOL locked;

//For the error output
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
  bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"prefs:root=ForwardNotifier" callblock:nil];
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

void sanitizeText() { //Thanks Tom for the idea of using \ everywhere :P
  finalTitle = [@"" mutableCopy];
  for (int i=0; i<title.length; i++) {
      NSString *charSelected = [title substringWithRange:NSMakeRange(i, 1)];
      if ([charSelected isEqualToString:@" "]) {
          charSelected = @" ";
      } else {
        charSelected = [NSString stringWithFormat:@"\\%@",charSelected];
      }
      [finalTitle appendString:charSelected];
  }
  finalMessage = [@"" mutableCopy];
  for (int i=0; i<message.length; i++) {
      NSString *charSelected = [message substringWithRange:NSMakeRange(i, 1)];
      if ([charSelected isEqualToString:@" "]) {
          charSelected = @" ";
      } else {
        charSelected = [NSString stringWithFormat:@"\\%@",charSelected];
      }
      [finalMessage appendString:charSelected];
  }
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
        sanitizeText();
        if (pcspecifier == 0) { // Linux
          finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
          command = [NSString stringWithFormat:@"notify-send -i applications-development %@",finalCommand];
          NSLog(@"ForwardNotifier: %@", command);
        } else if (pcspecifier == 1) { // MacOS
          finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
          command = [NSString stringWithFormat:@"/usr/local/bin/terminal-notifier -sound pop %@",finalCommand];
        } else if (pcspecifier == 2) { // iOS
          finalCommand = [NSString stringWithFormat:@"\"$(echo %@)\" \"$(echo %@)\"", finalTitle, finalMessage];
          command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@",finalCommand];
        } else if (pcspecifier == 3) { // Windows
          finalCommand = [NSString stringWithFormat:@"-title \"$(echo %@)\" -message \"$(echo %@)\"", finalTitle, finalMessage];
          command = [NSString stringWithFormat:@"ForwardNotifierReceiver %@",finalCommand];
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
    // Get Icon data
    SBApplicationIcon *icon = [((SBIconController *)[%c(SBIconController) sharedInstance]).model expectedIconForDisplayIdentifier:bundleID];
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
    // Base64 both title and message
    NSData *titleData = [title dataUsingEncoding: NSUTF8StringEncoding];
    NSString *titleBase64 = [titleData base64EncodedStringWithOptions:0];
    NSData *messageData = [message dataUsingEncoding: NSUTF8StringEncoding];
    NSString *messageBase64 = [messageData base64EncodedStringWithOptions:0];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-Status"] isEqual:@"1"] && (locked)) {
      dispatch_queue_t sendnotif = dispatch_queue_create("Send Notif", NULL);
      dispatch_async(sendnotif, ^{
        title = [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\""\""];
        if (pcspecifier == 0) { // Linux
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"Linux\", \"img\": \"%@\", \"appname\": \"%@\"}",titleBase64,messageBase64,iconBase64,appName];
        } else if (pcspecifier == 1) { // MacOS
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"MacOS\", \"img\": \"%@\"}",titleBase64,messageBase64,iconBase64];
        } else if (pcspecifier == 2) { // iOS
          command = [NSString stringWithFormat:@"{\"Title\": \"%@\", \"Message\": \"%@\", \"OS\": \"iOS\", \"img\": \"%@\"}",titleBase64,messageBase64,iconBase64];
        } else if (pcspecifier == 3) { // Windows
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

%group sender
%hook BBServer
-(void)publishBulletin:(BBBulletin *)arg1 destinations:(unsigned long long)arg2 {
  %orig;
  title = arg1.content.title;
  message = arg1.content.message;
  bundleID = arg1.sectionID;
  SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
  appName = app.displayName;
  if (([title length] != 0) || ([message length] != 0)) {
    if ([title length] == 0) {
      title = app.displayName;
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
      [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-Status"];
      title = @"ForwardNotifier Test";
      message = @"This is a test notification";
      testnotif(title,message);
    }
  }];
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
  if (receiver) {
    %init(devicereceiver);
  } else {
    %init(sender);
  }
}
