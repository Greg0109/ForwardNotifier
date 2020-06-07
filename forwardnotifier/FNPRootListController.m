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
		if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-FirstUse"] isEqual:@"1"]) {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"This tweak relies on a CC module!"
												 message:@"To enable or disable ForwardNotifier, you need to use the CC module. We recomend CC support to enable third party modules. This alert and any other that show up on settings will only show up once."
												 preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * action) {}];
			[alert addAction:defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
			[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-FirstUse"];
	  }
		((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
			if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-PCSpecifierWindows"] isEqual:@"1"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Crossplatform use is advised!"
                           message:@"Windows SSH support is buggy at the moment. Crossplatform server use is advised."
                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
				[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-PCSpecifierWindows"];
			}
    } else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"2"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"pcspecifier"]) {
			if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-PCSpecifieriOS"] isEqual:@"1"]) {
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"iOS only supports SSH"
													 message:@"Since the crossplatform server uses python3, iOS as a receiver only supports SSH at the moment."
													 preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
				[alert addAction:defaultAction];
				[self presentViewController:alert animated:YES completion:nil];
				[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-PCSpecifieriOS"];
			}
		} else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"1"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"methodspecifier"]) {
			if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-MethodSpecifier"] isEqual:@"1"]) {
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Crossplatform Server"
													 message:@"When using the Crossplatform Server you only need to insert the hostname or ip address. There's no need for user, password or port."
													 preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
				[alert addAction:defaultAction];
				[self presentViewController:alert animated:YES completion:nil];
				[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-MethodSpecifier"];
			}
		}

		if ([[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"receiver"] || [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"password"] || [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"chargingenabled"]) {
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
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil userInfo:nil];
}

@end
