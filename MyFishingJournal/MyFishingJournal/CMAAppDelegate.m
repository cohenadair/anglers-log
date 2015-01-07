//
//  CMAAppDelegate.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 9/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAppDelegate.h"
#import "CMAAlerts.h"

@implementation CMAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"Documents: %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    [self iCloudUbiquityTokenHandler];
    [self iCloudAccountChangeHandler];
    [self iCloudRequestHandler];
    
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
    [self.journal archive];
    
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Appearances

- (void)initAppearances {
    // Used to alternate background color of UITableViewCells
    CELL_COLOR_DARK = [UIColor colorWithWhite:0.95 alpha:1.0];
    CELL_COLOR_LIGHT = [UIColor clearColor];
    
    UIColor *buttonTintColor = [UIColor colorWithRed:21.0/255 green:165.0/255 blue:231.0/255 alpha:1.0];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:buttonTintColor];
    [[UIToolbar appearance] setTranslucent:NO];
    [[UIToolbar appearance] setBarTintColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    [[UIToolbar appearance] setTintColor:buttonTintColor];
    [[UITableViewCell appearance] setTintColor:buttonTintColor];
    [[UIButton appearance] setTintColor:buttonTintColor];
    [[UISegmentedControl appearance] setTintColor:buttonTintColor];
}

#pragma mark - iCloud Handlers

#define kUbiquityTokenIDKey         @"CMA.MyFishingJournal.UbiquityIdentityToken"
#define kFirstLaunchWithCloudKey    @"CMA.MyFishingJournal.FirstLaunchStringKey"
#define kUsingCloudBackupKey        @"CMA.MyFishingJournal.UsingCloudBackup"

#define kNil 0
#define kYES 1
#define kNO  2

NSString *const kFirstLaunchKey = @"CMA.MyFishingJournal.firstLaunchWithCloudAvailableKey";
NSString *const kCloudBackupEnabledKey = @"CMA.MyFishingJournal.cloudBackupEnabledKey";

// Checks to see if iCloud is available. Save the current Ubiquity Token ID if an account is logged in.
- (void)iCloudUbiquityTokenHandler {
    // gets the current devices iCloud token and archives it, or removes it from the archive if it doesn't exist
    id currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    id previousCloudToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUbiquityTokenIDKey];
    
    if (currentCloudToken && ![currentCloudToken isEqualToData:previousCloudToken]) { // if the current ID is different
        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentCloudToken];
        
        [[NSUserDefaults standardUserDefaults] setObject:newTokenData forKey:kUbiquityTokenIDKey];
        [[NSUserDefaults standardUserDefaults] setInteger:kYES forKey:kFirstLaunchWithCloudKey];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUsingCloudBackupKey];
        
    } else if (!currentCloudToken) { // if no iCloud account is signed in, remove stored key
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUbiquityTokenIDKey];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUsingCloudBackupKey];
    }
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
    
    if (!currentCloudToken)
        [CMAAlerts errorAlert:@"iCloud has been disabled. Your journal entries will no longer update on all your devices." presentationViewController:self.window.rootViewController];
    
    [self iCloudUbiquityTokenHandler];
    [self iCloudRequestHandler];
}

// Asks the user if they want to use iCloud or local storage (if an iCloud account is logged in).
// Uses local storage if no account is logged in.
- (void)iCloudRequestHandler {
    NSInteger firstLaunchWithCloudAvailable = [[NSUserDefaults standardUserDefaults] integerForKey:kFirstLaunchKey];
    
    if (firstLaunchWithCloudAvailable == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kFirstLaunchKey];
        firstLaunchWithCloudAvailable = 1;
    }
    
    // ask the user if they want to use iCloud
    if ([[NSFileManager defaultManager] ubiquityIdentityToken] && (firstLaunchWithCloudAvailable == 1)) { // if this is the first launch with an iCloud account
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Choose Storage Option"
                                                message:@"Should journal entries be stored in iCloud and be available on all your devices (recommended)?"
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *localOnlyAction =
            [UIAlertAction actionWithTitle:@"Local Only"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCloudBackupEnabledKey];
                                       [self initJournalFromLocalStorage];
                                   }];
        
        UIAlertAction *useCloudAction =
            [UIAlertAction actionWithTitle:@"Use iCloud"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCloudBackupEnabledKey];
                                       [self initJournal];
                                   }];
        
        [alert addAction:localOnlyAction];
        [alert addAction:useCloudAction];
        
        [self.window addSubview:self.window.rootViewController.view];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kFirstLaunchKey]; // first launch is no longer available
    } else
        [self initJournal];
    
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CMA.MyFishingJournal.firstLaunchWithCloudAvailableKey"];
}

#pragma mark - Journal Initializing

- (void)initJournalFromLocalStorage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths firstObject];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@", docsPath, ARCHIVE_FILE_NAME];
    
    self.journal = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    
    if (self.journal == nil)
        self.journal = [CMAJournal new];
    else
        [self.journal validateUserDefines];
    
    [self.journal setCloudURL:nil];
}

- (void)initJournal {
    BOOL iCloudBackupEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kCloudBackupEnabledKey];
    
    if (iCloudBackupEnabled) {
        dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSURL *myContainer = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            
            // unarchive journal object from iCloud
            if (myContainer != nil) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", myContainer.path, ARCHIVE_FILE_NAME];
                self.journal = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                
                // initialize journal from local storage if there's no iCloud archive
                if (self.journal == nil)
                    [self initJournalFromLocalStorage];
                else
                    [self.journal validateUserDefines];
                
                self.journal.cloudURL = myContainer;
                
                dispatch_async (dispatch_get_main_queue (), ^(void) {
                    // On the main thread, update UI and state as appropriate
                });
            }
        });
    } else
        [self initJournalFromLocalStorage];
}

@end
