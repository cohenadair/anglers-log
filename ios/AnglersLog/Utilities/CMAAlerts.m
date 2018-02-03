//
//  CMAAlerts.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAAlerts.h"

@implementation CMAAlerts

+ (void)showError:(NSString *)msg inVc:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:OKAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)showOk:(NSString *)msg inVc:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:OKAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
