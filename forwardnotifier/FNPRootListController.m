#include "FNPRootListController.h"

int __isOSVersionAtLeast(int major, int minor, int patch) { NSOperatingSystemVersion version; version.majorVersion = major; version.minorVersion = minor; version.patchVersion = patch; return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }

@implementation FNPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		NSArray *chosenIDs = @[@"hide1",@"hide2",@"hide3",@"hide4"];
		self.savedSpecifiers = (!self.savedSpecifiers) ? [[NSMutableDictionary alloc] init] : self.savedSpecifiers;
		for(PSSpecifier *specifier in _specifiers) {
			if ([chosenIDs containsObject:[specifier propertyForKey:@"id"]]) {
				[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
			}
		}
	}
	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
		if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-FirstUse"] isEqual:@"1"]) {
			if (@available(iOS 13, *)){
				[self updateController];
			} else {
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"This tweak relies on a CC module!"
													 message:@"To enable or disable ForwardNotifier, you need to use the CC module. We recomend CC support to enable third party modules. This alert and any other that show up on settings will only show up once."
													 preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
				[alert addAction:defaultAction];
				[self presentViewController:alert animated:YES completion:nil];
				[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-FirstUse"];
		  }
		}
		((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
   if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HideSSH"] isEqual:@"1"]) {
     [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide1"]] animated:YES];
		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide2"]] animated:YES];
		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide3"]] animated:YES];
		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide4"]] animated:YES];
   }
	 if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HideSSH"] isEqual:@"0"]) {
		 UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Possible exploit warning while using SSH"
 											 message:@"While the text has been sanitized to avoid possible execution of commands, the text is sent 'as is' and this presents a possible security risk.\nIt is advised to use the Crossplatform Server as it's more secure"
 											 preferredStyle:UIAlertControllerStyleAlert];
 		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
 													 handler:^(UIAlertAction * action) {}];
 		[alert addAction:defaultAction];
 		[self presentViewController:alert animated:YES completion:nil];
   }
}

-(void)reloadSpecifiers {
	[super reloadSpecifiers];
	//This will look the exact same as step 5, where we only check if specifiers need to be removed
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HideSSH"] isEqual:@"1"]) {
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide1"]] animated:YES];
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide2"]] animated:YES];
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide3"]] animated:YES];
		[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide4"]] animated:YES];
	}
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
				if (@available(iOS 13,*)) {} else {
	        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Crossplatform use is advised!"
	                           message:@"Windows SSH support is buggy at the moment. Crossplatform server use is advised."
	                           preferredStyle:UIAlertControllerStyleAlert];
	        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
	                               handler:^(UIAlertAction * action) {}];
	        [alert addAction:defaultAction];
	        [self presentViewController:alert animated:YES completion:nil];
					[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-PCSpecifierWindows"];
				}
			}
    } else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"2"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"pcspecifier"]) {
			if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"ForwardNotifier-PCSpecifieriOS"] isEqual:@"1"]) {
				if (@available(iOS 13,*)) {} else {
					UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"iOS only supports SSH"
														 message:@"Since the crossplatform server uses python3, iOS as a receiver only supports SSH at the moment."
														 preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
																 handler:^(UIAlertAction * action) {}];
					[alert addAction:defaultAction];
					[self presentViewController:alert animated:YES completion:nil];
					[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ForwardNotifier-PCSpecifieriOS"];
				}
			}
		} else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"1"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"methodspecifier"]) {
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide1"]] animated:YES];
 		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide2"]] animated:YES];
 		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide3"]] animated:YES];
 		 [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"hide4"]] animated:YES];
			[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"HideSSH"];
		} else if ([[NSString stringWithFormat:@"%@",value] isEqual:@"0"] && [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"methodspecifier"]) {
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"hide1"]] afterSpecifierID:@"hostnameip" animated:YES];
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"hide2"]] afterSpecifierID:@"hide1" animated:YES];
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"hide3"]] afterSpecifierID:@"hide2" animated:YES];
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"hide4"]] afterSpecifierID:@"hide3" animated:YES];
			[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"HideSSH"];
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Possible exploit warning while using SSH"
												 message:@"While the text has been sanitized to avoid possible execution of commands, the text is sent 'as is' and this presents a possible security risk.\nIt is advised to use the Crossplatform Server as it's more secure"
												 preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * action) {}];
			[alert addAction:defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
		}

		if ([[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"receiver"] || [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"password"] || [[NSString stringWithFormat:@"%@",specifier.properties[@"key"]] isEqual:@"chargingenabled"]) {
			UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(killall)];
			self.navigationItem.rightBarButtonItem = button;
		}
}

-(void)updateController {
	if (@available(iOS 13,*)) {
		UIImage *iconImage = [UIImage imageNamed:@"IconWelcome" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    welcomeController = [[OBWelcomeController alloc] initWithTitle:@"ForwardNotifier!" detailText:@"Please, be sure to follow the github instructions carefully and enjoy the tweak!" icon:iconImage];

    [welcomeController addBulletedListItemWithTitle:@"This tweak relies on a CC module!" description:@"To enable or disable ForwardNotifier, you need to use the CC module. We recommend CC support to enable third party modules." image:[UIImage systemImageNamed:@"1.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Use of the Crossplatform server is advised" description:@"The use of the crossplatform server is advised, as it brings more features and will have more support. Besides, it only requires the IP or hostname! No username or password is required." image:[UIImage systemImageNamed:@"2.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Windows" description:@"If you are using windows, please use the crossplatform server, as SSH on windows is not reliable enough." image:[UIImage systemImageNamed:@"3.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"iOS" description:@"Using iOS as the receiver only works over SSH at the moment. Crossplatform support for iOS receiver is being researched." image:[UIImage systemImageNamed:@"4.circle.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Support" description:@"If you are experiencing bugs, please read the github instructions carefuly, there is a link at the buttom of the preferences page. If you still need help, contact me via the links at the bottom of the preferences page." image:[UIImage systemImageNamed:@"5.circle.fill"]];

		//welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
    welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];
    OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.layer setCornerRadius:15];
    [welcomeController.buttonTray addButton:continueButton];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    welcomeController.modalInPresentation = YES;
    welcomeController.view.tintColor = [UIColor systemBlueColor];
    [self presentViewController:welcomeController animated:YES completion:nil];
	}
}

-(void)dismissWelcomeController { // Say goodbye to your controller. :(
    [welcomeController dismissViewControllerAnimated:YES completion:nil];
}

- (void)killall {
		NSURL *relaunchURL = [NSURL URLWithString:@"prefs:root=ForwardNotifier"];
		SBSRelaunchAction *restartAction;
    restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchActionOptionsFadeToBlackTransition targetURL:relaunchURL];
    [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
}

- (void)paypal {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/greg0109"] options:@{} completionHandler:nil];
}

- (void)openTwitter {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/greg_0109"] options:@{} completionHandler:nil];
}

- (void)reddit {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.reddit.com/user/greg0109/"] options:@{} completionHandler:nil];
}

- (void)sendEmail {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:greg.rabago@gmail.com?subject=ForwardNotifier"] options:@{} completionHandler:nil];
}

-(void)testnotif {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil userInfo:nil];
}

@end
