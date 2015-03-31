//
//  CMAPassthroughView.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMACircleView.h"

@implementation CMACircleView

// Return true if the point tapped is within the radius (width) of the view.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([super pointInside:point withEvent:event]) {
        // the center of the view relative to self's origin
        CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        
        double dx = (center.x - point.x);
        double dy = (center.y - point.y);
        double distFromCenter = sqrt((dx * dx) + (dy * dy));
        
        return (distFromCenter < (self.frame.size.width / 2));
    }
    
    return NO;
}

@end
