#include <stdio.h>
#import <Foundation/Foundation.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
@end


int main(int argc, char **argv, char **envp) {
	NSString *title = [NSString stringWithUTF8String:argv[1]];
	NSString *message = [NSString stringWithUTF8String:argv[2]];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.greg0109.forwardnotifierreceiver/notification" object:nil userInfo:@{@"title" : title, @"message" : message}];
	return 0;
}