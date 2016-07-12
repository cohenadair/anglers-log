//
//  CMAStatisticsTableViewCell.h
//  AnglersLog
//
//  Created by Cohen Adair on 12/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

@interface CMAStatisticsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end
