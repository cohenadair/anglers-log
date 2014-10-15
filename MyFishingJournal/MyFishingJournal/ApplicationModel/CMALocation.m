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
        _name = [NSMutableString stringWithString:aName];
        _fishingSpots = [NSMutableSet set];
    }
    
    return self;
}

- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot {
    if ([self fishingSpotNamed:aFishingSpot.name] != nil) {
        NSLog(@"Fishing spot with name %@ already exists", aFishingSpot.name);
        return NO;
    }

    [self.fishingSpots addObject:aFishingSpot];
    return YES;
}

- (void)removeFishingSpotNamed: (NSString *)aName {
    [self.fishingSpots removeObject:[self fishingSpotNamed:aName]];
}

- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot; {
    [[self fishingSpotNamed:aName] edit:aNewFishingSpot];
}

// updates self's properties with aNewLocation's properties
- (void)edit: (CMALocation *)aNewLocation {
    [self.name setString:aNewLocation.name];
    
    // no need to mess with fishing spots since there are separate methods for that
}

- (NSInteger)fishingSpotCount {
    return [self.fishingSpots count];
}

// returns nil if a fishing spot with aName does not exist, otherwise returns a pointer to the existing fishing spot
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName {
    for (CMAFishingSpot *spot in self.fishingSpots)
        if ([spot.name isEqualToString:aName])
            return spot;
    
    return nil;
}

@end
