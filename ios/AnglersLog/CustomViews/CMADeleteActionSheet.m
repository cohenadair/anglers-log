//
//  CMARemoveImageActionSheet.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-06.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMADeleteActionSheet.h"

@implementation CMADeleteActionSheet

- (void)addActions {
    UIAlertAction *deleteAction =
        [UIAlertAction actionWithTitle:@"Yes, delete it."
                                 style:UIAlertActionStyleDestructive
                               handler:self.deleteActionBlock];
    
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"No, keep it."
                                 style:UIAlertActionStyleCancel
                               handler:self.cancelActionBlock];
    
    [self addAction:deleteAction];
    [self addAction:cancelAction];
}

- (void)showInViewController:(UIViewController *)aViewController {
    [aViewController presentViewController:self animated:YES completion:nil];
}

@end
