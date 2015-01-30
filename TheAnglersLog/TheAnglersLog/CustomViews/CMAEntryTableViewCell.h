//
//  CMAEntryTableViewCell.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/11/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMAEntryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
