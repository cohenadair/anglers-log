//
//  CMATouchSegmentedControl.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/12/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMATouchSegmentedControl.h"

/*
 * This class is used to capture touch events on a UISegmentedControl.
 * The default UISegmentedControl only responts to UIControlEventValueChanged events.
 */
@implementation CMATouchSegmentedControl

NSInteger current = -1;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    // only fire event if the segment touched is the one already selected
    if (current == self.selectedSegmentIndex)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
