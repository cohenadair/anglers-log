//
//  CMASegmentedControlTableViewCell.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/21/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMASegmentedControlTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
