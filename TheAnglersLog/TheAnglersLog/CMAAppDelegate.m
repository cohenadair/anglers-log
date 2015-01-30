//
//  CMAAppDelegate.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 9/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAppDelegate.h"
#import "CMAStorageManager.h"
#import "CMAConstants.h"

@implementation CMAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self iCloudUbiquityTokenHandler];
    [self iCloudAccountChangeHandler];
    [self iCloudRequestHandlerOverrideFirstLaunch:NO withCallback:nil];
    
    //[self iCloudDisableHandler];
    
    /*
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:CDE_WEATHER_DATA inManagedObjectContext:[[CMAStorageManager sharedManager] managedObjectContext]]];
    
    NSError *e;
    NSArray *results = [[[CMAStorageManager sharedManager] managedObjectContext] executeFetchRequest:fetchRequest error:&e];
    
    for (CMAWeatherData *obj in results)
        [[[CMAStorageManager sharedManager] managedObjectContext] deleteObject:obj];
    
    [[CMAStorageManager sharedManager] saveContext];
    */
    
    [[CMAStorageManager sharedManager] debugCoreDataObjects];
    
    [self initAppearances];
    
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
        [self iCloudUbiquityTokenHandler]; // see if the last account was logged out/changed

        [[CMAStorageManager sharedManager] setSharedJournal:nil];
        [[CMAStorageManager sharedManager] loadJournalWithCloudEnabled:[self iCloudEnabled]];
    }
    
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

#pragma mark - iCloud Handlers

NSString *const kUbiquityTokenIDKey = @"CMA.MyFishingJournal.UbiquityIdentityToken";
NSString *const kFirstLaunchKey = @"CMA.MyFishingJournal.firstLaunchWithCloudAvailableKey";
NSString *const kCloudBackupEnabledKey = @"CMA.MyFishingJournal.cloudBackupEnabledKey";

NSInteger const kNil = 0;
NSInteger const kYES = 1;
NSInteger const kNO = 2;

// Checks to see if iCloud is available. Save the current Ubiquity Token ID if an account is logged in.
- (void)iCloudUbiquityTokenHandler {
    // gets the current devices iCloud token and archives it, or removes it from the archive if it doesn't exist
    id currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    // gets previously saved token
    id previousCloudTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:kUbiquityTokenIDKey];
    id previousCloudToken;
    
    if (previousCloudTokenData)
        previousCloudToken = [NSKeyedUnarchiver unarchiveObjectWithData:previousCloudTokenData];
    
    if (currentCloudToken && ![currentCloudToken isEqualToData:previousCloudToken]) { // if the current ID is different
        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentCloudToken];
        
        [[NSUserDefaults standardUserDefaults] setObject:newTokenData forKey:kUbiquityTokenIDKey];
        [[NSUserDefaults standardUserDefaults] setInteger:kYES forKey:kFirstLaunchKey];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCloudBackupEnabledKey];
        
    } else if (!currentCloudToken && previousCloudToken) { // if no iCloud account is signed in, but there used to be
        self.presentCloudAccountChangedAlert = YES;
        [self iCloudDisableHandler];
    } else if (!currentCloudToken)
        [self iCloudDisableHandler];
}

// sets up a listener for when the ubiquity identity token changes.
- (void)iCloudAccountChangeHandler {
    // register an observer to detect if a user signs in or out of iCloud
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudAccountAvailabilityChanged)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
}

// Is executed when the ubiquity identity token changes.
- (void)iCloudAccountAvailabilityChanged {
    id currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    self.presentCloudAccountChangedAlert = !currentCloudToken;
    
    [self iCloudUbiquityTokenHandler];
    [self iCloudRequestHandlerOverrideFirstLaunch:NO withCallback:nil];
}

// Asks the user if they want to use iCloud or local storage (if an iCloud account is logged in).
// Uses local storage if no account is logged in.
- (void)iCloudRequestHandlerOverrideFirstLaunch:(BOOL)overrideFirstLaunch withCallback:(void(^)())aCallbackBlock {
    NSInteger firstLaunchWithCloudAvailable = [[NSUserDefaults standardUserDefaults] integerForKey:kFirstLaunchKey];
    
    if (firstLaunchWithCloudAvailable == kNil) {
        [[NSUserDefaults standardUserDefaults] setInteger:kYES forKey:kFirstLaunchKey];
        firstLaunchWithCloudAvailable = kYES;
    }
    
    // ask the user if they want to use iCloud
    if ([[NSFileManager defaultManager] ubiquityIdentityToken] && (firstLaunchWithCloudAvailable == kYES || overrideFirstLaunch)) { // if this is the first launch with an iCloud account
        self.iCloudAlert =
            [UIAlertController alertControllerWithTitle:@"Choose Storage Option"
                                                message:@"Should journal entries be stored in iCloud and be available on all your devices (recommended)?"
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *localOnlyAction =
            [UIAlertAction actionWithTitle:@"Local Only"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCloudBackupEnabledKey];
                                       [[CMAStorageManager sharedManager] loadJournalWithCloudEnabled:NO];
                                       
                                       if (aCallbackBlock)
                                           aCallbackBlock();
                                   }];
        
        UIAlertAction *useCloudAction =
            [UIAlertAction actionWithTitle:@"Use iCloud"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCloudBackupEnabledKey];
                                       [[CMAStorageManager sharedManager] loadJournalWithCloudEnabled:YES];
                                       
                                       if (aCallbackBlock)
                                           aCallbackBlock();
                                   }];
        
        [self.iCloudAlert addAction:localOnlyAction];
        [self.iCloudAlert addAction:useCloudAction];
        
        [[NSUserDefaults standardUserDefaults] setInteger:kNO forKey:kFirstLaunchKey]; // first launch is no longer available
    } else {
        [[CMAStorageManager sharedManager] loadJournalWithCloudEnabled:[self iCloudEnabled]];
        self.iCloudAlert = nil;
    }
}

- (void)iCloudDisableHandler {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUbiquityTokenIDKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCloudBackupEnabledKey];
}

- (BOOL)iCloudEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCloudBackupEnabledKey];
}

@end
