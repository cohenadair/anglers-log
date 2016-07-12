//
//  CMABaitTableViewCell.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

@interface CMABaitTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishCaughtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;

@end
