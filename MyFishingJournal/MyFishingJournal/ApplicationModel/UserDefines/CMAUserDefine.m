//
//  CMAUserDefine.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMALocation.h"
#import "CMABait.h"
#import "CMASpecies.h"
#import "CMAFishingMethod.h"
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
        _objects = [NSMutableArray array];
    }
    
    return self;
}

#pragma Editing

// Does nothing if an object with the same name already exists in self.objects.
- (void)addObject: (id)anObject {
    if ([self objectNamed:[anObject name]] == nil)
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

#pragma mark - Object Types

// Returns an object of correct type with the name property set to aName.
- (id)emptyObjectNamed: (NSString *)aName {
    if ([self.name isEqualToString:SET_LOCATIONS])
        return [CMALocation withName:aName];
    
    if ([self.name isEqualToString:SET_SPECIES])
        return [CMASpecies withName:aName];
    
    if ([self.name isEqualToString:SET_BAITS])
        return [CMABait withName:aName];
    
    if ([self.name isEqualToString:SET_FISHING_METHODS])
        return [CMAFishingMethod withName:aName];
    
    NSLog(@"Invalid user define name in - [CMAUserDefine emptyObjectNamed]");
    return nil;
}

@end
