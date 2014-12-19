//
//  CMASelectionTableViewController.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAConstants.h"

@interface CMASelectionTableViewController : UITableViewController

// used after an unwind to previous view controller
@property (strong, nonatomic)NSString *selectedCellLabelText;

// set before segue from previous view controller to CMASelectionTableViewController
@property (nonatomic)CMAViewControllerID previousViewID;
@property (strong, nonatomic)NSArray *tableDataArray;

@end
