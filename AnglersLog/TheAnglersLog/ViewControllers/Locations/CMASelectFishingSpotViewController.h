//
//  CMASelectFishingSpotViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>
#import "CMAConstants.h"
#import "CMALocation.h"

@interface CMASelectFishingSpotViewController : UITableViewController

@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)NSString *selectedCellLabelText;
@property (nonatomic)CMAViewControllerID previousViewID;

@end
