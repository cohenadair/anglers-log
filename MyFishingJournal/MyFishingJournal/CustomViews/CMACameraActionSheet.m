//
//  CMACameraActionSheet.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMACameraActionSheet.h"

@implementation CMACameraActionSheet

+ (CMACameraActionSheet *)withDelegate:(id<UIActionSheetDelegate>)aDelegate {
    return (CMACameraActionSheet *)
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:aDelegate
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Take Photo", @"Attach Photo", nil];
}

@end
