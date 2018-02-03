//
//  CMAAlerts.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

@interface CMAAlerts : NSObject

+ (void)showError:(NSString *)msg inVc:(UIViewController *)viewController;
+ (void)showOk:(NSString *)msg inVc:(UIViewController *)viewController;

@end
