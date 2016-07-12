//
//  CMAAlertController.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAAlertController.h"

@interface CMAAlertController ()

@end

@implementation CMAAlertController

- (CMAAlertController *)initWithTitle:(NSString *)aTitle
                              message:(NSString *)aMessage
                    actionButtonTitle:(NSString *)aButtonTitle
                          actionBlock:(void (^)())anActionBlock
                          cancelBlock:(void (^)())aCancelBlock {
    
    if ((self = (CMAAlertController *)[UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleActionSheet])) {
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:aButtonTitle
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *a) {
                                   anActionBlock();
                               }];
        
        UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *a) {
                                   aCancelBlock();
                               }];
        
        [self addAction:action];
        [self addAction:cancelAction];
    }
    
    return self;
}

@end
