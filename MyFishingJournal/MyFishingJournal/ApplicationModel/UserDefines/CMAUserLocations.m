//
//  CMAUserLocations.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserLocations.h"

@implementation CMAUserLocations

#pragma mark - Initialization

- (CMAUserLocations *)init {
    self = [super init];
    return self;
}

#pragma mark - Editing

// removes obejct with aName from self's objects
- (void)removeObjectNamed: (NSString *)aName {
    [self.objects removeObject:[self locationNamed:aName]];
}

// updates self's poperties with aNewObject's properties
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject {
    [[self locationNamed:aName] edit:aNewObject];
}

#pragma mark - Accessing

// returns nil if a location with aName doesn't exist
- (CMALocation *)locationNamed: (NSString *)aName {
    for (CMALocation *loc in self.objects)
        if ([loc.name isEqualToString:aName])
            return loc;
    
    return nil;
}

// returns the name at anIndex
- (NSString *)nameAtIndex: (NSInteger)anIndex {
    int i = 0;
    
    for (CMALocation *loc in self.objects) {
        if (i == anIndex)
            return loc.name;
        
        i++;
    }
    
    return @"";
}

@end
