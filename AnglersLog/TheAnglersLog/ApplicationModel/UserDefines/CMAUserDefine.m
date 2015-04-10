//
//  CMAUserDefine.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAUserDefine.h"
#import "CMALocation.h"
#import "CMABait.h"
#import "CMASpecies.h"
#import "CMAFishingMethod.h"
#import "CMAWaterClarity.h"
#import "CMAConstants.h"
#import "CMAStorageManager.h"
#import "CMAJSONWriter.h"

@implementation CMAUserDefine

@dynamic journal;
@dynamic name;
@dynamic baits;
@dynamic locations;
@dynamic fishingMethods;
@dynamic species;
@dynamic waterClarities;

#pragma mark - Initialization

- (CMAUserDefine *)initWithName:(NSString *)aName andJournal:(CMAJournal *)aJournal {
    self.name = aName;
    self.journal = aJournal;
    
    self.baits = [NSMutableOrderedSet orderedSet];
    self.fishingMethods = [NSMutableOrderedSet orderedSet];
    self.locations = [NSMutableOrderedSet orderedSet];
    self.species = [NSMutableOrderedSet orderedSet];
    self.waterClarities = [NSMutableOrderedSet orderedSet];
    
    return self;
}

#pragma Editing

// Does nothing if an object with the same name already exists in self.objects.
- (BOOL)addObject:(id)anObject {
    if (anObject == nil)
        return NO;
    
    //[anObject setUserDefine:self];
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
    if ([self.name isEqualToString:UDN_BAITS])
        return self.baits;
    else if ([self.name isEqualToString:UDN_FISHING_METHODS])
        return self.fishingMethods;
    else if ([self.name isEqualToString:UDN_LOCATIONS])
        return self.locations;
    else if ([self.name isEqualToString:UDN_SPECIES])
        return self.species;
    else if ([self.name isEqualToString:UDN_WATER_CLARITIES])
        return self.waterClarities;
    
    NSLog(@"Invalid user define name!");
    return nil;
}

- (void)setActiveSet:(NSMutableOrderedSet *)aMutableOrderedSet {
    if ([self.name isEqualToString:UDN_BAITS])
        self.baits = aMutableOrderedSet;
    else if ([self.name isEqualToString:UDN_FISHING_METHODS])
        self.fishingMethods = aMutableOrderedSet;
    else if ([self.name isEqualToString:UDN_LOCATIONS])
        self.locations = aMutableOrderedSet;
    else if ([self.name isEqualToString:UDN_SPECIES])
        self.species = aMutableOrderedSet;
    else if ([self.name isEqualToString:UDN_WATER_CLARITIES])
        self.waterClarities = aMutableOrderedSet;
}

- (NSInteger)count {
    return [[self activeSet] count];
}

- (id)objectNamed:(NSString *)aName {
    for (id obj in [self activeSet])
        if ([[obj name] isEqualToString:[aName capitalizedString]])
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
    if ([self objectNamed:aName] != nil) {
        NSLog(@"Duplicate object name.");
        return nil;
    }
    
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

- (BOOL)isSetOfBaits {
    return [self.name isEqualToString:UDN_BAITS];
}

- (BOOL)isSetOfLocations {
    return [self.name isEqualToString:UDN_LOCATIONS];
}

- (BOOL)isSetOfFishingMethods {
    return [self.name isEqualToString:UDN_FISHING_METHODS];
}

- (BOOL)isSetOfWaterClarities {
    return [self.name isEqualToString:UDN_WATER_CLARITIES];
}

- (BOOL)isSetOfSpecies {
    return [self.name isEqualToString:UDN_SPECIES];
}

#pragma mark - Sorting

- (void)sortByNameProperty {
    NSMutableOrderedSet *activeSet = [self activeSet];
    
    NSArray *sortedArray = [activeSet sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2){
        return [[o1 name] compare:[o2 name]];
    }];
    
    [self setActiveSet:[NSMutableOrderedSet orderedSetWithArray:sortedArray]];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitUserDefne:self];
}

@end
