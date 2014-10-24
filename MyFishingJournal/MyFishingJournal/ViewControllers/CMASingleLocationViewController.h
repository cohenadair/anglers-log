//
//  CMASingleLocationViewController.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMALocation.h"

@interface CMASingleLocationViewController : UITableViewController

@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)NSString *addEntryLabelText;
@property (nonatomic)BOOL isSelectingForAddEntry;

@end
