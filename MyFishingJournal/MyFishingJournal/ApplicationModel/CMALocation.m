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
        _fishingSpots = [NSMutableSet setWithCapacity:0];
    }
    
    return self;
}

// setting
- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot {
    if ([self fishingSpotWithName:aFishingSpot.name] != nil) {
        NSLog(@"Fishing spot with name %@ already exists", aFishingSpot.name);
        return NO;
    }

    [self.fishingSpots addObject:aFishingSpot];
    return YES;
}

- (void)removeFishingSpot: (CMAFishingSpot *)aFishingSpot {
    [self.fishingSpots removeObject:aFishingSpot];
}

- (void)editFishingSpot: (CMAFishingSpot *)anOldFishingSpot newFishingSpot: (CMAFishingSpot *)aNewFishingSpot {
    [self removeFishingSpot:anOldFishingSpot];
    [self addFishingSpot:aNewFishingSpot];
}

// accessing
- (NSInteger)fishingSpotCount {
    return [self.fishingSpots count];
}

- (CMAFishingSpot *)fishingSpotWithName: (NSString *)aName {
    for (CMAFishingSpot *spot in self.fishingSpots)
        if ([spot.name caseInsensitiveCompare:aName] == NSOrderedSame)
            return spot;
    
    return nil;
}

@end
