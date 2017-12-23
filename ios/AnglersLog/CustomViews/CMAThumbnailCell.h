//
//  CMAThumbnailCell.h
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-22.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAEntry.h"

@interface CMAThumbnailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleView1;
@property (weak, nonatomic) IBOutlet UILabel *subtitleView2;

+ (CMAThumbnailCell *)forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (void)registerWithTableView:(UITableView *)tableView;

+ (CGFloat)height;

- (void)setEntry:(CMAEntry *)entry;

/**
 * Displays the given entry's data for display in the statistics view.
 * @param showLength True to show the entry's length; false to show the entry's weight.
 * @param measurementSystem The `CMAMeasuringSystemType` used for the current journal.
 */
- (void)setStatsEntry:(CMAEntry *)entry
           showLength:(BOOL)showLength
    measurementSystem:(CMAMeasuringSystemType)system;

/**
 * Displays the given bait's data in the table cell.
 * @param hideAccessory True to hide the cell's accessory view; false to show it.
 */
- (void)setBait:(CMABait *)bait hideAccessory:(BOOL)hideAccessory;

@end
