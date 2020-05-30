#include "FNPRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <AppList/AppList.h>
#include "NSTask.h"

@implementation FNPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
		NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
		NSMutableDictionary *settings = [NSMutableDictionary dictionary];
		[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		[settings setObject:value forKey:specifier.properties[@"key"]];
		[settings writeToFile:path atomically:YES];
		CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
		if (notificationName) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
		}
    if ([[NSString stringWithFormat:@"%@",value] isEqual:@"3"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"pcspecifier"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Crossplatform use is advised!"
                           message:@"Windows SSH support is buggy at the moment. Crossplatform server use is advised."
                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"2"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"pcspecifier"]) {
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"iOS only supports SSH"
													 message:@"Since the crossplatform server uses python3, iOS as a receiver only supports SSH at the moment."
													 preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
				[alert addAction:defaultAction];
				[self presentViewController:alert animated:YES completion:nil];
		}

		if ([[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"receiver"] || [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"password"]) {
			UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(killall)];
			self.navigationItem.rightBarButtonItem = button;
		}
}

- (void)killall {
    NSTask *killallSpringBoard = [[NSTask alloc] init];
    [killallSpringBoard setLaunchPath:@"/usr/bin/killall"];
    [killallSpringBoard setArguments:@[@"-9", @"SpringBoard"]];
    [killallSpringBoard launch];
}

- (void)paypal {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/greg0109"]];
}

- (void)openTwitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/greg_0109"]];
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/user/greg0109/"]];
}

- (void)sendEmail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:greg.rabago@gmail.com?subject=ForwardNotifier"]];
}

-(void)testnotif {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/testnotification" object:nil userInfo:nil];
}

@end
