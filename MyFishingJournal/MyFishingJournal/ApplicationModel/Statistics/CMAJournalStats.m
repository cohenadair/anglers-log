//
//  CMAJournalStats.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournalStats.h"

@implementation CMAJournalStats

#pragma mark - Initializing

+ (CMAJournalStats *)withJournal: (CMAJournal *)aJournal {
    return [[self alloc] initWithJournal:aJournal];
}

- (id)initWithJournal: (CMAJournal *)aJournal {
    if (self = [super init]) {
        _journal = aJournal;
        _totalFishCaught = [self initTotalFishCaught];
        _totalFishWeight = [self initTotalFishWeight];
        _speciesCaughtStats = [self getSpeciesCaughtStats];
        _mostCaughtSpeciesIndex = [self initMostCaughtSpeciesIndex];
        _mostWeightSpeciesIndex = [self initMostWeightSpeciesIndex];
    }
    
    return self;
}

- (CMASpeciesStats *)speciesStatsAtIndex: (NSInteger)anIndex {
    return [self.speciesCaughtStats objectAtIndex:anIndex];
}

- (NSInteger)speciesCaughtStatsIndexForName: (NSString *)aName {
    NSInteger index = 0;
    
    for (CMASpeciesStats *s in self.speciesCaughtStats) {
        if ([aName isEqualToString:s.name])
            return index;
    
        index++;
    }
    
    return -1;
}

- (NSInteger)speciesCaughtStatsCount {
    return [self.speciesCaughtStats count];
}

#pragma mark - Species Stats

// returns an array of CMASpeciesStats objects for the species that have > 0 numberCaught
- (NSArray *)getSpeciesCaughtStats {
    NSMutableArray *result = [NSMutableArray array];
    
    for (CMASpecies *species in [[self.journal userDefineNamed:SET_SPECIES] objects]) {
        CMASpeciesStats *obj = [CMASpeciesStats new];
        [obj setName:species.name];
        [obj setNumberCaught:[species.numberCaught integerValue]];
        [obj setWeightCaught:[species.weightCaught integerValue]];
        [result addObject:obj];
    }
    
    return [self setSpeciesPercentages:result];
}

// sets the percent of total fix caught for each CMASpeciesStats in anArray
- (NSArray *)setSpeciesPercentages: (NSArray *)anArray {
    NSArray *result = [anArray copy];
    
    for (CMASpeciesStats *s in result) {
        [s setPercentOfTotalCaught:round((float)s.numberCaught / (float)self.totalFishCaught * 100.0f)];
        [s setPercentOfTotalWeight:round((float)s.weightCaught / (float)self.totalFishWeight * 100.0f)];
    }
    
    return result;
}

// returns the total number of fish caught
- (NSInteger)initTotalFishCaught {
    NSInteger result = 0;
    
    for (CMASpecies *s in [[self.journal userDefineNamed:SET_SPECIES] objects])
        result += [s.numberCaught integerValue];
    
    return result;
}

// returns the index of the most caught species in self.speciesCaughtStats
// used for an XYPieChart data source
- (NSInteger)initMostCaughtSpeciesIndex {
    NSInteger highest = 0;
    NSInteger result = 0;
    int i = 0;
    
    for (CMASpeciesStats *s in self.speciesCaughtStats) {
        if (s.numberCaught > highest) {
            highest = s.numberCaught;
            result = i;
        }
        
        i++;
    }
    
    return result;
}

- (NSInteger)initTotalFishWeight {
    NSInteger result = 0;
    
    for (CMASpecies *s in [[self.journal userDefineNamed:SET_SPECIES] objects])
        result += [s.weightCaught integerValue];
    
    return result;
}

- (NSInteger)initMostWeightSpeciesIndex {
    NSInteger highest = 0;
    NSInteger result = 0;
    int i = 0;
    
    for (CMASpeciesStats *s in self.speciesCaughtStats) {
        if (s.weightCaught > highest) {
            highest = s.weightCaught;
            result = i;
        }
        
        i++;
    }
    
    return result;
}

- (NSDate *)earliestEntryDate {
    [self.journal sortEntriesBy:CMAEntrySortMethod_Date order:CMASortOrder_Descending];
    NSDate *result = [[self.journal.entries objectAtIndex:0] date];
    [self.journal sortEntriesBy:self.journal.entrySortMethod order:self.journal.entrySortOrder];
    
    return result;
}


@end
