//
//  CMAAppDelegate.m
//  AnglersLog
//
//  Created by Cohen Adair on 9/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <ChameleonFramework/Chameleon.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <Instabug/Instabug.h>

#import "CMAAppDelegate.h"
#import "CMAConstants.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"
#import "iRate.h"
#import "UIColor+CMA.h"

@implementation CMAAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [iRate sharedInstance].daysUntilPrompt = 7;
    [iRate sharedInstance].usesUntilPrompt = 15;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // initialize Instabug
    [Instabug startWithToken:@"74b1aa82cf70c705dcb0752940c7110b" invocationEvent:IBGInvocationEventRightEdgePan];
    
    // initialize crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    [[CMAStorageManager sharedManager] loadJournal];
    [self initAppearances];
    
    //NSLog(@"%@", [[CMAStorageManager sharedManager] documentsDirectory].path);
    //[[CMAStorageManager sharedManager] deleteAllObjectsForEntityName:CDE_WEATHER_DATA];
    //[[CMAStorageManager sharedManager] debugCoreDataObjects];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[[CMAStorageManager sharedManager] sharedJournal] archive];
    [[CMAStorageManager sharedManager] cleanImages];
    [self setDidEnterBackground:YES];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[[CMAStorageManager sharedManager] sharedJournal] archive];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Appearances

- (void)initAppearances {
    // Ensures top and bottom bars aren't transparent.
    UINavigationBar.appearance.translucent = NO;
    UIToolbar.appearance.translucent = NO;
    
    // Hides back button text on all view controllers.
    [UIBarButtonItem.appearance setBackButtonTitlePositionAdjustment:UIOffsetMake(-200.0, 0)
                                                       forBarMetrics:UIBarMetricsDefault];
    
    // Apply a global theme.
    [Chameleon setGlobalThemeUsingPrimaryColor:UIColor.anglersLogLight
                            withSecondaryColor:UIColor.anglersLogAccent
                               andContentStyle:UIContentStyleContrast];
    
    // Override some Chameleon settings.
    UIButton.appearance.tintColor = UIColor.anglersLogAccent;
    UIButton.appearance.backgroundColor = UIColor.clearColor;
    
    UISegmentedControl.appearance.tintColor = UIColor.anglersLogAccent;
    
    // UITableViewCell selection.
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.anglersLogLightTransparent;
    UITableViewCell.appearance.selectedBackgroundView = view;
    UITableViewCell.appearance.multipleSelectionBackgroundView = view;
}

@end
