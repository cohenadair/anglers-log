//
//  CMAAlerts.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import "CMAAlerts.h"

@implementation CMAAlerts

+ (void)errorAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:OKAction];
    
    [aViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)alertAlert:(NSString *)msg presentationViewController:(UIViewController *)aViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:OKAction];
    
    [aViewController presentViewController:alert animated:YES completion:nil];
}

@end