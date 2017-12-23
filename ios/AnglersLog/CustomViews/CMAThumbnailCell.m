//
//  CMAThumbnailCell.m
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-22.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "CMAThumbnailCell.h"
#import "CMAUtilities.h"

static NSString * const NIB_NAME = @"CMAThumbnailCell";
static NSString * const ID = @"thumbnailCell";

static CGFloat const HEIGHT = 85;

@implementation CMAThumbnailCell

#pragma mark - Constants

+ (CGFloat)height {
    return HEIGHT;
}

#pragma mark - Initializing

+ (CMAThumbnailCell *)forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
}

+ (void)registerWithTableView:(UITableView *)tableView {
    UINib *nib = [UINib nibWithNibName:NIB_NAME bundle:NSBundle.mainBundle];
    [tableView registerNib:nib forCellReuseIdentifier:ID];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.subtitleView1.text = nil;
    self.subtitleView2.text = nil;
}

#pragma mark - Displaying

- (void)setEntry:(CMAEntry *)entry {
    self.thumbnailView.image = entry.imageCount > 0
            ? entry.images[0].tableCellImage : CMAUtilities.placeholderImage;
    self.titleView.text = entry.fishSpecies.name;
    self.subtitleView1.text = [CMAUtilities displayStringForDate:entry.date];
    self.subtitleView2.text = entry.location == nil ? @"" : entry.locationAsString;
}

- (void)setStatsEntry:(CMAEntry *)entry
           showLength:(BOOL)showLength
    measurementSystem:(CMAMeasuringSystemType)system
{
    if (entry == nil) {
        self.thumbnailView.image = CMAUtilities.placeholderImage;
        self.titleView.text = @"Unknown Species";
        self.subtitleView1.text = showLength ? @"No Recorded Lengths" : @"No Recorded Weights";
        self.accessoryType = UITableViewCellAccessoryNone;
        self.userInteractionEnabled = NO;
    } else {
        self.thumbnailView.image = entry.imageCount > 0
                ? entry.images[0].tableCellImage : CMAUtilities.placeholderImage;
        self.titleView.text = entry.fishSpecies.name;
        self.subtitleView1.text = showLength
                ? [entry lengthAsStringWithMeasurementSystem:system shorthand:NO]
                : [entry weightAsStringWithMeasurementSystem:system shorthand:NO];
    }
}

- (void)setBait:(CMABait *)bait hideAccessory:(BOOL)hideAccessory {
    self.thumbnailView.image = bait.imageData == nil
            ? CMAUtilities.placeholderImage : bait.imageData.tableCellImage;
    self.titleView.text = bait.name;
    self.subtitleView1.text = bait.fishCaughtAsString;
    self.subtitleView2.text = bait.colorAsString;
    self.accessoryType = hideAccessory
            ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
}

@end
