//
//  CMASelectFishingSpotViewController.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAConstants.h"
#import "CMALocation.h"

@interface CMASelectFishingSpotViewController : UITableViewController

@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)NSString *selectedCellLabelText;
@property (nonatomic)CMAViewControllerID previousViewID;

@end
