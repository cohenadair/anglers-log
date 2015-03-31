//
//  CMAAddBaitViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>
#import "CMABait.h"
#import "CMAConstants.h"

@interface CMAAddBaitViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)CMABait *bait;
@property (nonatomic)CMAViewControllerID previousViewID;

@end
