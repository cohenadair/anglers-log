//
//  CMARemoveImageActionSheet.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-06.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMARemoveImageActionSheet.h"

@implementation CMARemoveImageActionSheet

- (void)addActions {
    [self setTitle:@"Remove Photo"];
    [self setMessage:@"Are you sure you want to remove this photo?"];
    
    UIAlertAction *deleteAction =
        [UIAlertAction actionWithTitle:@"Yes, delete it."
                                 style:UIAlertActionStyleDestructive
                               handler:self.deleteActionBlock];
    
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"No, keep it."
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) {}];
    
    [self addAction:deleteAction];
    [self addAction:cancelAction];
}

- (void)showInViewController:(UIViewController *)aViewController {
    [aViewController presentViewController:self animated:YES completion:nil];
}

@end
