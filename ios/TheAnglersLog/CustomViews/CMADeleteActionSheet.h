//
//  CMARemoveImageActionSheet.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-06.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

@interface CMADeleteActionSheet : UIAlertController

@property (strong, nonatomic) void (^deleteActionBlock)(UIAlertAction *);
@property (strong, nonatomic) void (^cancelActionBlock)(UIAlertAction *);

- (void)addActions;
- (void)showInViewController:(UIViewController *)aViewController;

@end
