//
//  CMARemoveImageActionSheet.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-06.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMARemoveImageActionSheet : UIAlertController

@property (strong, nonatomic) void (^deleteActionBlock)(UIAlertAction *);

- (void)addActions;
- (void)showInViewController:(UIViewController *)aViewController;

@end
