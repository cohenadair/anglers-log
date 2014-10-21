//
//  CMAUserStrings.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserStrings.h"

@implementation CMAUserStrings

#pragma mark - Initialization

- (CMAUserStrings *)init {
    self = [super init];
    return self;
}

#pragma mark - Editing

// overridden to make sure the incoming NSString is capitalized
- (void)addObject: (id)anObject {
    [self.objects addObject:[anObject capitalizedString]];
}

// removes obejct with aName from self's objects
- (void)removeObjectNamed: (NSString *)aName {
    [self.objects removeObject:[self stringNamed:aName]];
}

// updates self's string with aNewObject's string
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject {
    [[self stringNamed:aName] setString:aNewObject];
}

#pragma mark - Accessing

// returns nil if a string with aName doesn't exist
- (NSMutableString *)stringNamed: (NSString *)aName {
    return [self.objects member:aName];
}

// returns the name at anIndex
- (NSString *)nameAtIndex: (NSInteger)anIndex {
    return [[self.objects allObjects] objectAtIndex:anIndex];
}

@end
