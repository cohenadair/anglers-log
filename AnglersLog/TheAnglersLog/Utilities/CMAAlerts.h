//
//  CMAAlerts.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

@interface CMAAlerts : NSObject

+ (void)errorAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController;
+ (void)alertAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController;

@end
