//
//  CMAFishingSpot.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingSpot.h"
#import "CMAJSONWriter.h"

@implementation CMAFishingSpot

@dynamic myLocation;
@dynamic location;
@dynamic fishCaught;

#pragma mark - Accessing

// returns the coordinates of the location
- (CLLocationCoordinate2D)coordinate {
    return [self.location coordinate];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitFishingSpot:self];
}

@end
