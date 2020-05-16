#include "FNPRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
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
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(killall)];
    self.navigationItem.rightBarButtonItem = button;
}
- (void)killall {
    NSTask *killallSpringBoard = [[NSTask alloc] init];
    [killallSpringBoard setLaunchPath:@"/usr/bin/killall"];
    [killallSpringBoard setArguments:@[@"-9", @"SpringBoard"]];
    [killallSpringBoard launch];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    return (plist[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary new];
    plist[specifier.properties[@"key"]] = value;
    [plist writeToFile:path atomically:true];
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName)
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, true);
    if ([[NSString stringWithFormat:@"%@",value] isEqual:@"3"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"This Feature is in beta!"
                           message:@"Windows support is still in beta and it might not work properly for you at the moment."
                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
