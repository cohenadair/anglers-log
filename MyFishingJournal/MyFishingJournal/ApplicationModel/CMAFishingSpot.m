//
//  CMAFishingSpot.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingSpot.h"

@implementation CMAFishingSpot

// instance creation
+ (CMAFishingSpot *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

// initialization
- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
        _location = [CLLocation new];
    }
    
    return self;
}

// accessing
- (CLLocationCoordinate2D)coordinate {
    return [self.location coordinate];
}

@end
