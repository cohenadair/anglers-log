//
//  CMAAddEntryViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>
#import "CMAConstants.h"
#import "CMAEntry.h"

@interface CMAAddEntryViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, CLLocationManagerDelegate>

@property (nonatomic)CMAViewControllerID previousViewID;
@property (strong, nonatomic)CMAEntry *entry;

@end
