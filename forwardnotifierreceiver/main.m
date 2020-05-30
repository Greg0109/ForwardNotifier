#include <stdio.h>
#import <Foundation/Foundation.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end


int main(int argc, char **argv, char **envp) {
	NSString *title = [NSString stringWithUTF8String:argv[1]];
	NSString *message = [NSString stringWithUTF8String:argv[2]];
	if ([title isEqualToString:@"ActivateForwardNotifier"]) {
		if ([message isEqualToString:@"true"]) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/activate" object:nil userInfo:nil];
			printf("ForwardNotifier Activated!");
		} else if ([message isEqualToString:@"false"]) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/deactivate" object:nil userInfo:nil];
			printf("ForwardNotifier Deactivated!");
		}
	} else {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil userInfo:@{@"title" : title, @"message" : message}];
	}
	return 0;
}
