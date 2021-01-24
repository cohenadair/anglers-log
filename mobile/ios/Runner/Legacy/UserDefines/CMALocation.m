//
//  CMALocation.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMALocation.h"
#import "CMAJSONWriter.h"

@implementation CMALocation

@dynamic fishingSpots;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitLocation:self];
}

@end
