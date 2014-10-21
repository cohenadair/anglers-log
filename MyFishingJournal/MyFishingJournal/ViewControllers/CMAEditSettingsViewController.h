//
//  CMAEditSettingsViewController.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAJournal.h"

@interface CMAEditSettingsViewController : UITableViewController

@property (strong, nonatomic)NSString *settingName;
@property (strong, nonatomic)NSString *clickedCellLabelText;

- (CMAJournal *)journal;

@end
