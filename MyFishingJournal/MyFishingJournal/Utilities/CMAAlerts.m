//
//  CMAAlerts.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAAlerts.h"

@implementation CMAAlerts

+ (void)errorAlert: (NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end