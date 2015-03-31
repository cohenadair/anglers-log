//
//  CMAAlerts.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

@interface CMAAlerts : NSObject

+ (void)errorAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController;
+ (void)alertAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController;

@end
