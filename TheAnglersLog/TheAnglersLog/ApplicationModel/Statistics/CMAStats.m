//
//  CMABaitStats.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/25/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAStats.h"

@implementation CMAStats

#pragma mark - Initilize For Baits Used

+ (CMAStats *)forCaughtWithJournal:(CMAJournal *)aJournal {
    return [[self alloc] initWithJournal:aJournal forDataType:CMAPieChartDataTypeCaught];
}

+ (CMAStats *)forWeightWithJournal:(CMAJournal *)aJournal {
    return [[self alloc] initWithJournal:aJournal forDataType:CMAPieChartDataTypeWeight];
}

+ (CMAStats *)forBaitWithJournal:(CMAJournal *)aJournal {
    return [[self alloc] initWithJournal:aJournal forDataType:CMAPieChartDataTypeBait];
}

+ (CMAStats *)forLocationWithJournal:(CMAJournal *)aJournal {
    return [[self alloc] initWithJournal:aJournal forDataType:CMAPieChartDataTypeLocation];
}

- (id)initWithJournal:(CMAJournal *)aJournal forDataType:(CMAPieChartDataType)aDataType {
    if (self = [super init]) {
        _journal = aJournal;
        _totalValue = 0;
        _pieChartDataType = aDataType;
        _totalDescription = @"Fish Caught";
        _detailDescription = @"Caught";
        
        switch (_pieChartDataType) {
            case CMAPieChartDataTypeCaught:
                self.userDefineName = UDN_SPECIES;
                [self initForCaught];
                break;
                
            case CMAPieChartDataTypeWeight:
                self.userDefineName = UDN_SPECIES;
                _totalDescription = [NSString stringWithFormat:@"%@ Caught", [self.journal weightUnitsAsString:NO]];
                _detailDescription = [self.journal weightUnitsAsString:YES];
                
                if (self.journal.measurementSystem == CMAMeasuringSystemTypeImperial)
                    _detailDescription2 = UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND;
                
                [self initForWeight];
                break;
                
            case CMAPieChartDataTypeBait:
                self.userDefineName = UDN_BAITS;
                _detailDescription = @"Fish Caught";
                [self initForBait];
                break;
                
            case CMAPieChartDataTypeLocation:
                self.userDefineName = UDN_LOCATIONS;
                [self initForLocation];
                break;
                
            default:
                NSLog(@"Invalid CMAPieChartDataType in initWithJournal");
                break;
        }
    }
    
    return self;
}

- (void)initForCaught {
    NSMutableArray *result = [NSMutableArray array];
    
    for (CMASpecies *species in [[self.journal userDefineNamed:UDN_SPECIES] activeSet]) {
        CMAStatsObject *obj = [CMAStatsObject new];
        
        [obj setName:species.name];
        [obj setValue:[species.numberCaught integerValue]];
        self.totalValue += [species.numberCaught integerValue];
        
        [result addObject:obj];
    }
    
    self.sliceObjects = result;
}

- (void)initForWeight {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger ounces = 0;
    
    for (CMASpecies *species in [[self.journal userDefineNamed:UDN_SPECIES] activeSet]) {
        CMAStatsObject *obj = [CMAStatsObject new];
        
        [obj setName:species.name];
        [obj setValue:[species.weightCaught integerValue]];
        [obj setDetailValue:[species.ouncesCaught integerValue]];
        self.totalValue += [species.weightCaught integerValue];
        
        ounces += [species.ouncesCaught integerValue];
        if (ounces >= OUNCES_PER_POUND) {
            self.totalValue += 1;
            ounces -= OUNCES_PER_POUND;
        }
        
        [result addObject:obj];
    }
    
    self.sliceObjects = result;
}

- (void)initForLocation {
    NSMutableArray *result = [NSMutableArray array];
    
    for (CMALocation *loc in [[self.journal userDefineNamed:UDN_LOCATIONS] activeSet]) {
        CMAStatsObject *obj = [CMAStatsObject new];
        
        for (CMAFishingSpot *spot in loc.fishingSpots)
            obj.value += [spot.fishCaught integerValue];
        
        [obj setName:loc.name];
        self.totalValue += obj.value;
        
        [result addObject:obj];
    }
    
    self.sliceObjects = result;
}

- (void)initForBait {
    NSMutableArray *result = [NSMutableArray array];
    
    for (CMABait *bait in [[self.journal userDefineNamed:UDN_BAITS] activeSet]) {
        CMAStatsObject *obj = [CMAStatsObject new];
        
        [obj setName:bait.name];
        [obj setValue:[bait.fishCaught integerValue]];
        self.totalValue += [bait.fishCaught integerValue];
        
        [result addObject:obj];
    }
    
    self.sliceObjects = result;
}

- (NSInteger)highestValueIndex {
    NSInteger highest = 0;
    NSInteger index = 0;
    NSInteger result = 0;
    
    for (CMAStatsObject *o in self.sliceObjects) {
        if (o.value > highest) {
            highest = o.value;
            result = index;
        }
        
        index++;
    }
    
    return result;
}

- (NSInteger)indexForName:(NSString *)aName {
    NSInteger index = 0;
    
    for (CMAStatsObject *s in self.sliceObjects) {
        if ([aName isEqualToString:s.name])
            return index;
        
        index++;
    }
    
    return -1;
}

- (NSInteger)valueForSliceAtIndex:(NSInteger)anIndex {
    return [(CMAStatsObject *)[self.sliceObjects objectAtIndex:anIndex] value];
}

- (NSInteger)valueForPercentAtIndex:(NSInteger)anIndex {
    NSInteger result = 0;
    
    if ([self.sliceObjects count] > 0) {
        CMAStatsObject *obj = (CMAStatsObject *)[self.sliceObjects objectAtIndex:anIndex];
        result = round((float)obj.value / (float)self.totalValue * 100.0f);
    }
    
    if (result > 0)
        return result;
    
    return 0;
}

- (NSString *)stringForPercentAtIndex:(NSInteger)anIndex {
    return [NSString stringWithFormat:@"%ld%%", (long)[self valueForPercentAtIndex:anIndex]];
}

- (NSString *)nameAtIndex:(NSInteger)anIndex {
    if ([self.sliceObjects count] > 0)
        return [(CMAStatsObject *)[self.sliceObjects objectAtIndex:anIndex] name];
    
    return [NSString stringWithFormat:@"No Recorded %@", self.userDefineName];
}

- (NSString *)detailTextAtIndex:(NSInteger)anIndex {
    CMAStatsObject *obj;
    
    if ([self.sliceObjects count] > 0)
        obj = (CMAStatsObject *)[self.sliceObjects objectAtIndex:anIndex];
    else {
        obj = [CMAStatsObject new];
        obj.value = 0;
    }
    
    if (self.detailDescription2)
        return [NSString stringWithFormat:@"%ld%@ %ld%@", (long)obj.value, self.detailDescription, (long)obj.detailValue, self.detailDescription2];
    else
        return [NSString stringWithFormat:@"%ld %@", (long)obj.value, self.detailDescription];
}

- (NSInteger)sliceObjectCount {
    return [self.sliceObjects count];
}

- (NSDate *)earliestEntryDate {
    CMASortOrder oldOrder = [self.journal entrySortOrder];
    
    [self.journal sortEntriesBy:CMAEntrySortMethodDate order:CMASortOrderAscending];
    NSDate *result = [[self.journal.entries objectAtIndex:0] date];
    [self.journal sortEntriesBy:self.journal.entrySortMethod order:oldOrder];
    
    return result;
}

- (CMAEntry *)highCatchEntryFor:(NSInteger)lengthOrWeight {
    CMAEntry *result = nil;
    NSInteger high = 0;
    NSInteger val = 0;
    
    for (CMAEntry *entry in self.journal.entries) {
        if (lengthOrWeight == kHighCatchEntryLength)
            val = [entry.fishLength integerValue];
        else
            val = [entry.fishWeight integerValue];
        
        if (val > high) {
            high = val;
            result = entry;
        }
    }
    
    return result;
}

@end
