//
//  CMAAddBaitViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMABait.h"
#import "CMAConstants.h"

@interface CMAAddBaitViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)CMABait *bait;
@property (nonatomic)CMAViewControllerID previousViewID;
@property (nonatomic, copy)void (^onSavePhotoBlock)(BOOL);

@end
