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
- (CMAUserLocations *)init {
    self = [super init];
    return self;
}

// updates self's poperties with aNewObject's properties
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject {
    [[self locationNamed:aName] edit:aNewObject];
}

// removes obejct with aName from self's objects
- (void)removeObjectNamed: (NSString *)aName {
    [self.objects removeObject:[self locationNamed:aName]];
}

// returns nil if a location with aName doesn't exist
- (CMALocation *)locationNamed: (NSString *)aName {
    for (CMALocation *loc in self.objects)
        if ([loc.name isEqualToString:aName])
            return loc;
    
    return nil;
}

@end
