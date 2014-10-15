//
//  CMAUserStrings.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserStrings.h"

@implementation CMAUserStrings

// instance creation
- (CMAUserStrings *)init {
    self = [super init];
    return self;
}

// updates self's string with aNewObject's string
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject {
    [[self stringNamed:aName] setString:aNewObject];
}

// removes obejct with aName from self's objects
- (void)removeObjectNamed: (NSString *)aName {
    [self.objects removeObject:[self stringNamed:aName]];
}

// returns nil if a string with aName doesn't exist
- (NSMutableString *)stringNamed: (NSString *)aName {
    return [self.objects member:aName];
}

@end
