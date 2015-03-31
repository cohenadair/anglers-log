//
//  CMAAppDelegate.m
//  AnglersLog
//
//  Created by Cohen Adair on 9/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Instabug/Instabug.h>
#import "CMAAppDelegate.h"
#import "CMAStorageManager.h"
#import "CMAConstants.h"
#import "CMAUtilities.h"

@implementation CMAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Instabug startWithToken:@"00957cd4e3f99f77e904c7bb54cc93dc" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventRightEdgePan];
    [Instabug setFeedbackSentAlertText:[NSString stringWithFormat:@"Thank you for helping improve %@!", APP_NAME]];
    [Instabug setIsTrackingCrashes:YES];
    [Instabug setBugHeaderText:@"Report a Bug"];
    [Instabug setFeedbackHeaderText:@"Requests and Feedback"];
    
    [[CMAStorageManager sharedManager] loadJournal];
    [self initAppearances];
    
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
    // reload journal incase the database was updated in iCloud
    if (self.didEnterBackground) {
        //[self iCloudUbiquityTokenHandler]; // see if the last account was logged out/changed

        [[CMAStorageManager sharedManager] setSharedJournal:nil];
        [[CMAStorageManager sharedManager] loadJournal];
    }
    
    [[CMAStorageManager sharedManager] cleanImages];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[[CMAStorageManager sharedManager] sharedJournal] archive];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Appearances

- (void)initAppearances {
    // Used to alternate background color of UITableViewCells
    CELL_COLOR_DARK = [UIColor colorWithWhite:0.95 alpha:1.0];
    CELL_COLOR_LIGHT = [UIColor clearColor];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIToolbar appearance] setTranslucent:NO];
}

@end
