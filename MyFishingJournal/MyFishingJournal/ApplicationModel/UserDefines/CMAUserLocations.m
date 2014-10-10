//
//  CMAUserLocations.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserLocations.h"

@implementation CMAUserLocations

// instance creation
+ (CMAUserLocations *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

// initializing
- (CMAUserLocations *)initWithName: (NSString *)aName {
    self = [super initWithName:aName];
    return self;
}

// updates self's poperties with aNewLocation's properties
- (void)editLocation: (CMALocation *)aLocation newLocation: (CMALocation *)aNewLocation {
    [aLocation edit:aNewLocation];
}

// returns nil if a location with aName doesn't exist
- (CMALocation *)locationNamed: (NSString *)aName {
    for (CMALocation *loc in self.objects)
        if ([loc.name caseInsensitiveCompare:aName] == NSOrderedSame)
            return loc;
    
    return nil;
}

@end
