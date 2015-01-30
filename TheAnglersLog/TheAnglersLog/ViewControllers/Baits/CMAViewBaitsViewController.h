//
//  CMAViewBaitsViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMABait.h"

@interface CMAViewBaitsViewController : UITableViewController

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingForStatistics;
@property (strong, nonatomic)CMABait *baitForAddEntry;
@property (strong, nonatomic)NSString *baitNameForStatistics; // used for unwind to statistics

@end
