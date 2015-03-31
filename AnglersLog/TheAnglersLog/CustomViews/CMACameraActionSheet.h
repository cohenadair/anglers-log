//
//  CMACameraActionSheet.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

@interface CMACameraActionSheet : UIAlertController

@property (strong, nonatomic) void (^takePhotoBlock)(UIAlertAction *);
@property (strong, nonatomic) void (^attachPhotoBlock)(UIAlertAction *);

- (void)addActions;
- (void)showInViewController:(UIViewController *)aViewController;

@end
