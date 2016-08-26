//
//  CMACameraActionSheet.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMACameraActionSheet.h"

@implementation CMACameraActionSheet

- (void)addActions {
    [self setTitle:nil];
    
    UIAlertAction *takePhotoAction =
        [UIAlertAction actionWithTitle:@"Take Photo"
                                 style:UIAlertActionStyleDefault
                               handler:self.takePhotoBlock];
    
    UIAlertAction *attachPhotoAction =
        [UIAlertAction actionWithTitle:@"Attach Photo"
                                 style:UIAlertActionStyleDefault
                               handler:self.attachPhotoBlock];
    
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDestructive
                               handler:nil];
    
    [self addAction:takePhotoAction];
    [self addAction:attachPhotoAction];
    [self addAction:cancelAction];
}

- (void)showInViewController:(UIViewController *)aViewController {
    [aViewController presentViewController:self animated:YES completion:nil];
}

@end
