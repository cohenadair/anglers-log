//
//  CMAAppDelegate.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 9/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAJournal.h"

@interface CMAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)UIAlertController *iCloudAlert;
@property (nonatomic)BOOL presentCloudAccountChangedAlert;

@property (strong, nonatomic)UIWindow *window;

@property (nonatomic)BOOL didEnterBackground;

- (void)iCloudUbiquityTokenHandler;
- (void)iCloudRequestHandlerOverrideFirstLaunch:(BOOL)overrideFirstLaunch withCallback:(void(^)())aCallbackBlock;
- (void)iCloudDisableHandler;

@end
