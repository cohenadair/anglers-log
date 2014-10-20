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

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CMAJournal *journal;

@end
