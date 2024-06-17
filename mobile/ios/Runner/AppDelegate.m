#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import "MigrationChannel.h"
#import "UserNotifications/UserNotifications.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MigrationChannel create:self];
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
