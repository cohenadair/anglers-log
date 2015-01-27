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
#import "CMAStorageManager.h"

@implementation CMAUserDefine

@dynamic journal;
@dynamic baits;
@dynamic locations;
@dynamic fishingMethods;
@dynamic species;
@dynamic waterClarities;

#pragma mark - Initialization

- (CMAUserDefine *)initWithName:(NSString *)aName andJournal:(CMAJournal *)aJournal {
    self.name = aName;
    self.journal = aJournal;
    
    if ([aName isEqualToString:UDN_BAITS])
        self.baits = [NSMutableOrderedSet orderedSet];
    else if ([aName isEqualToString:UDN_FISHING_METHODS])
        self.fishingMethods = [NSMutableOrderedSet orderedSet];
    else if ([aName isEqualToString:UDN_LOCATIONS])
        self.locations = [NSMutableOrderedSet orderedSet];
    else if ([aName isEqualToString:UDN_SPECIES])
        self.species = [NSMutableOrderedSet orderedSet];
    else if ([aName isEqualToString:UDN_WATER_CLARITIES])
        self.waterClarities = [NSMutableOrderedSet orderedSet];
    
    return self;
}

#pragma mark - Validation

- (void)validateObjects {
    for (id o in [self activeSet])
        [o validateProperties];
}

#pragma mark - Archiving
/*
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
*/
#pragma Editing

// Does nothing if an object with the same name already exists in self.objects.
- (BOOL)addObject:(id)anObject {
    if ([self objectNamed:[anObject name]] != nil) {
        NSLog(@"Duplicate object name.");
        return NO;
    }
    
    [[self activeSet] addObject:anObject];
    [self sortByNameProperty];
    return YES;
}

- (void)removeObjectNamed:(NSString *)aName {
    [[self activeSet] removeObject:[self objectNamed:aName]];
}

- (void)editObjectNamed:(NSString *)aName newObject: (id)aNewObject {
    [[self objectNamed:aName] edit:aNewObject];
    [self sortByNameProperty];
}

#pragma mark - Accessing

- (NSMutableOrderedSet *)activeSet {
    if (self.baits)
        return self.baits;
    else if (self.fishingMethods)
        return self.fishingMethods;
    else if (self.locations)
        return self.locations;
    else if (self.species)
        return self.species;
    else if (self.waterClarities)
        return self.waterClarities;
    
    NSLog(@"All user defines are NULL!");
    return nil;
}

- (void)setActiveSet:(NSMutableOrderedSet *)aMutableOrderedSet {
    if (self.baits)
        self.baits = aMutableOrderedSet;
    else if (self.fishingMethods)
        self.fishingMethods = aMutableOrderedSet;
    else if (self.locations)
        self.locations = aMutableOrderedSet;
    else if (self.species)
        self.species = aMutableOrderedSet;
    else if (self.waterClarities)
        self.waterClarities = aMutableOrderedSet;
}

- (NSInteger)count {
    return [[self activeSet] count];
}

- (id)objectNamed:(NSString *)aName {
    for (id obj in [self activeSet])
        if ([[obj name] isEqualToString:aName])
            return obj;
    
    return nil;
}

- (id)objectAtIndex:(NSInteger)anIndex {
    return [[self activeSet] objectAtIndex:anIndex];
}

- (BOOL)isSetOfStrings {
    return ![self.name isEqualToString:UDN_LOCATIONS] &&
           ![self.name isEqualToString:UDN_BAITS];
}

#pragma mark - Object Types

// Returns an object of correct type with the name property set to aName.
- (id)emptyObjectNamed:(NSString *)aName {
    CMAStorageManager *manager = [CMAStorageManager sharedManager];
    
    if ([self.name isEqualToString:UDN_SPECIES])
        return [[manager managedSpecies] initWithName:aName andUserDefine:self];
    
    if ([self.name isEqualToString:UDN_FISHING_METHODS])
        return [[manager managedFishingMethod] initWithName:aName andUserDefine:self];
    
    if ([self.name isEqualToString:UDN_WATER_CLARITIES])
        return [[manager managedWaterClarity] initWithName:aName andUserDefine:self];
    
    NSLog(@"Invalid user define name in [CMAUserDefine emptyObjectNamed].");
    return nil;
}

#pragma mark - Sorting

- (void)sortByNameProperty {
    NSMutableOrderedSet *activeSet = [self activeSet];
    
    NSArray *sortedArray = [activeSet sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2){
        return [[o1 name] compare:[o2 name]];
    }];
    
    [self setActiveSet:[NSMutableOrderedSet orderedSetWithArray:sortedArray]];
}

@end
