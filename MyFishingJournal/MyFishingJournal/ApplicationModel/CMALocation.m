//
//  CMALocation.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMALocation.h"

@implementation CMALocation

// instance creation
+ (CMALocation *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

// initializing
- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
        _fishingSpots = [NSMutableDictionary dictionary];
    }
    
    return self;
}

// setting
- (void)addFishingSpot: (NSString *)aName location: (CLLocation *)aLocation {
    [self.fishingSpots setObject: aLocation forKey: aName];
}

- (void)removeFishingSpotByName: (NSString *)aName {
    [self.fishingSpots removeObjectForKey:aName];
}

// removes fishing spot with aName and adds fishing spot with aNewName and aNewLocation
- (void)editFishingSpot: (NSString *)aName newName: (NSString *)aNewName newLocation: (CLLocation *)aNewLocation {
    [self removeFishingSpotByName:aName];
    [self addFishingSpot:aNewName location:aNewLocation];
}

// accessing
- (NSInteger)fishingSpotCount {
    return [self.fishingSpots count];
}

@end
