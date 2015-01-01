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
#import "CMAWaterClarity.h"
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

- (void)validateObjects {
    for (id o in self.objects)
        [o validateProperties];
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMAUserDefineName"];
        _objects = [aDecoder decodeObjectForKey:@"CMAUserDefineObjects"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAUserDefineName"];
    [aCoder encodeObject:self.objects forKey:@"CMAUserDefineObjects"];
}

#pragma Editing

// Does nothing if an object with the same name already exists in self.objects.
- (BOOL)addObject: (id)anObject {
    if ([self objectNamed:[anObject name]] != nil) {
        NSLog(@"Duplicate object name.");
        return NO;
    }
    
    [self.objects addObject:anObject];
    [self sortByNameProperty];
    return YES;
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
    return ![self.name isEqualToString:SET_LOCATIONS] &&
           ![self.name isEqualToString:SET_BAITS];
}

#pragma mark - Object Types

// Returns an object of correct type with the name property set to aName.
- (id)emptyObjectNamed: (NSString *)aName {
    if ([self.name isEqualToString:SET_LOCATIONS])
        return [CMALocation withName:[aName capitalizedString]];
    
    if ([self.name isEqualToString:SET_SPECIES])
        return [CMASpecies withName:[aName capitalizedString]];
    
    if ([self.name isEqualToString:SET_BAITS])
        return [CMABait withName:[aName capitalizedString]];
    
    if ([self.name isEqualToString:SET_FISHING_METHODS])
        return [CMAFishingMethod withName:[aName capitalizedString]];
    
    if ([self.name isEqualToString:SET_WATER_CLARITIES])
        return [CMAWaterClarity withName:[aName capitalizedString]];
    
    NSLog(@"Invalid user define name in - [CMAUserDefine emptyObjectNamed]");
    return nil;
}

#pragma mark - Sorting

- (void)sortByNameProperty {
    self.objects = [[self.objects sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2){
        return [[o1 name] compare:[o2 name]];
    }] mutableCopy];
}

@end
