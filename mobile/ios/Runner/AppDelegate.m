#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import "MigrationChannel.h"
#import "UserNotifications/UserNotifications.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)didInitializeImplicitFlutterEngine:(NSObject<FlutterImplicitEngineBridge> *)engineBridge {
    [GeneratedPluginRegistrant registerWithRegistry:engineBridge.pluginRegistry];
    [MigrationChannel create:
            [engineBridge.pluginRegistry registrarForPlugin:@"MigrationChannel"].messenger];
}

@end
