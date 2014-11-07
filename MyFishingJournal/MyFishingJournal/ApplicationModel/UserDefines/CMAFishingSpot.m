//
//  CMAFishingSpot.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingSpot.h"

@implementation CMAFishingSpot

#pragma mark - Instance Creation

+ (CMAFishingSpot *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = [NSMutableString stringWithString:aName];
        _location = [CLLocation new];
    }
    
    return self;
}

- (id)init {
    if (self = [super init]) {
        _name = [NSMutableString string];
        _location = [CLLocation new];
    }
    
    return self;
}

#pragma mark - Editing

- (void)setCoordinates: (CLLocationCoordinate2D)coordinates {
    self.location = [self.location initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
}

// updates self's properties with aNewFishinSpot's attributes
- (void)edit: (CMAFishingSpot *)aNewFishingSpot {
    self.name = aNewFishingSpot.name;
    self.location = aNewFishingSpot.location;
}

#pragma mark - Accessing

// returns the coordinates of the location
- (CLLocationCoordinate2D)coordinate {
    return [self.location coordinate];
}

@end
