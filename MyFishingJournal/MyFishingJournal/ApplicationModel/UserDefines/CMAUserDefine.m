//
//  CMAUserDefine.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMALocation.h"
#import "CMAConstants.h"

@implementation CMAUserDefine

#pragma mark - Instance Creation

+ (CMAUserDefine *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = [NSMutableString stringWithString:aName];
        _objects = [NSMutableSet set];
    }
    
    return self;
}

#pragma Editing

- (void)addObject: (id)anObject {
    [self.objects addObject:anObject];
}

- (void)removeObjectNamed: (NSString *)aName {
    [self.objects removeObject:[self objectNamed:aName]];
}

- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject {
    [[self objectNamed:aName] edit:aNewObject];
}

#pragma mark - Accessing

- (NSInteger)count {
    return [self.objects count];
}

- (id)objectNamed: (NSString *)aName {
    for (id obj in self.objects)
        if ([[obj name] isEqualToString:aName])
            return obj;
    
    return nil;
}

- (BOOL)isSetOfStrings {
    return ![self.name isEqualToString:SET_LOCATIONS];
}

@end
