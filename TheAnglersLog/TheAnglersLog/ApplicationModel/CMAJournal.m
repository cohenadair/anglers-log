//
//  CMAJournal.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournal.h"
#import "CMASpecies.h"
#import "CMABait.h"
#import "CMAFishingMethod.h"
#import "CMAStorageManager.h"

@implementation CMAJournal

@dynamic entries;
@dynamic userDefines;
@dynamic measurementSystem;
@dynamic entrySortMethod;
@dynamic entrySortOrder;

#pragma mark - Initialization

- (CMAJournal *)init {
    if (self = [super init]) {
        self.entries = [NSMutableArray array];
        self.userDefines = [NSMutableArray array];
        
        [self setMeasurementSystem:CMAMeasuringSystemTypeImperial];
        [self setEntrySortMethod:CMAEntrySortMethodDate];
        [self setEntrySortOrder:CMASortOrderDescending];
        
        [self validateProperties];
    }
    
    return self;
}

- (void)validateProperties {
    [self initUserDefines];
    [self initEntries];
    [self initStatistics];
}

// Initializes user define objects if they don't already exist. Used so the same CMAJournal object can be used if new defines are added later.
- (void)initUserDefines {
    if (![self userDefineNamed:UDN_SPECIES])
        [self addUserDefineNamed:UDN_SPECIES];
    
    if (![self userDefineNamed:UDN_BAITS])
        [self addUserDefineNamed:UDN_BAITS];
    
    if (![self userDefineNamed:UDN_FISHING_METHODS])
        [self addUserDefineNamed:UDN_FISHING_METHODS];
    
    if (![self userDefineNamed:UDN_LOCATIONS])
        [self addUserDefineNamed:UDN_BAITS];
    
    if (![self userDefineNamed:UDN_WATER_CLARITIES])
        [self addUserDefineNamed:UDN_WATER_CLARITIES];
    
    for (CMAUserDefine *define in self.userDefines)
        [define validateObjects];
}

// Adds a new CMAUserDefine object to [self userDefines].
- (void)addUserDefineNamed:(NSString *)aName {
    NSManagedObjectContext *context = [[CMAStorageManager sharedManager] managedObjectContext];
    
    CMAUserDefine *define = [NSEntityDescription insertNewObjectForEntityForName:CDE_USER_DEFINE inManagedObjectContext:context];
    [define setName:UDN_SPECIES];
    [define setJournal:self];
    
    [self.userDefines addObject:define];
}

// Used for compatibility purposes if the class of a property changes.
- (void)initEntries {
    for (CMAEntry *e in self.entries)
        [e validateProperties];
}

// Loops through entries and recounts statistical information. Used for compatibility with old archives.
- (void)initStatistics {
    // reset species
    CMAUserDefine *species = [self userDefineNamed:UDN_SPECIES];
    for (CMASpecies *s in [species objects]) {
        [s setNumberCaught:[NSNumber numberWithInteger:0]];
        [s setWeightCaught:[NSNumber numberWithInteger:0]];
        [s setOuncesCaught:[NSNumber numberWithInteger:0]];
    }
    
    // reset baits
    CMAUserDefine *baits = [self userDefineNamed:UDN_BAITS];
    for (CMABait *s in [baits objects]) {
        [s setFishCaught:[NSNumber numberWithInteger:0]];
    }
    
    // reset fishing spots
    CMAUserDefine *locations = [self userDefineNamed:UDN_LOCATIONS];
    for (CMALocation *l in [locations objects])
        for (CMAFishingSpot *f in [l fishingSpots])
            [f setFishCaught:[NSNumber numberWithInteger:0]];
    
    for (CMAEntry *e in self.entries)
        [self incStatsForEntry:e];
}

#pragma mark - Archiving
/*
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.entries = [aDecoder decodeObjectForKey:@"CMAJournalEntries"];
        self.userDefines = [aDecoder decodeObjectForKey:@"CMAJournalUserDefines"];
        self.measurementSystem = [aDecoder decodeIntegerForKey:@"CMAJournalMeasurmentSystem"];
        self.entrySortMethod = [aDecoder decodeIntegerForKey:@"CMAJournalEntrySortMethod"];
        self.entrySortOrder = [aDecoder decodeIntegerForKey:@"CMAJournalEntrySortOrder"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.entries forKey:@"CMAJournalEntries"];
    [aCoder encodeObject:self.userDefines forKey:@"CMAJournalUserDefines"];
    [aCoder encodeInteger:self.measurementSystem forKey:@"CMAJournalMeasurmentSystem"];
    [aCoder encodeInteger:self.entrySortMethod forKey:@"CMAJournalEntrySortMethod"];
    [aCoder encodeInteger:self.entrySortOrder forKey:@"CMAJournalEntrySortOrder"];
}
*/
- (void)archive {
    [[CMAStorageManager sharedManager] saveJournal:self withFileName:ARCHIVE_FILE_NAME];
}

#pragma mark - Editing

- (CMAJournal *)copy {
    CMAJournal *result = [CMAJournal new];
    
    result.entries = [self.entries mutableCopy];
    result.userDefines = [self.userDefines mutableCopy];
    result.measurementSystem = self.measurementSystem;
    result.entrySortMethod = self.entrySortMethod;
    result.entrySortOrder = self.entrySortOrder;
    
    return result;
}

- (BOOL)addEntry: (CMAEntry *)anEntry {
    if ([self entryDated:anEntry.date] != nil) {
        NSLog(@"Duplicate entry date.");
        return NO;
    }
    
    [self incStatsForEntry:anEntry];
    [self.entries addObject:anEntry];
    [self sortEntriesBy:self.entrySortMethod order:self.entrySortOrder];
    
    return YES;
}

- (void)removeEntryDated: (NSDate *)aDate {
    CMAEntry *entry = [self entryDated:aDate];
    
    [self decStatsForEntry:entry];
    [self.entries removeObject:[self entryDated:aDate]];
}

// removes entry with aDate and adds aNewEntry
// no need to keep the same instance since the reference doesn't need to be kept track of
- (void)editEntryDated: (NSDate *)aDate newProperties: (CMAEntry *)aNewEntry {
    [self removeEntryDated:aDate];
    [self addEntry:aNewEntry];
}

- (void)addUserDefine: (NSString *)aDefineName objectToAdd: (id)anObject {
    [[self userDefineNamed:aDefineName] addObject:anObject];
}

- (void)removeUserDefine: (NSString *)aDefineName objectNamed: (NSString *)anObjectName {
    [[self userDefineNamed:aDefineName] removeObjectNamed:anObjectName];
    [self removeUserDefineFromEntries:aDefineName objectNamed:anObjectName];
}

// Helper method called when a user defined is deleted by the user.
// Removes the user define, anObjectName (i.e. species, location, bait, etc.) from any entries that reference it.
- (void)removeUserDefineFromEntries: (NSString *)aDefineName objectNamed: (NSString *)anObjectName {
    for (CMAEntry *entry in self.entries) {
        if ([aDefineName isEqualToString:UDN_SPECIES])
            if ([entry.fishSpecies.name isEqualToString:anObjectName]) {
                entry.fishSpecies = nil;
                entry.fishSpecies = [CMASpecies withName:REMOVED_TEXT];
            }
        
        if ([aDefineName isEqualToString:UDN_LOCATIONS])
            if ([entry.location.name isEqualToString:anObjectName]) {
                entry.location = nil;
                entry.fishingSpot = nil;
                entry.location = [CMALocation withName:REMOVED_TEXT];
            }
        
        if ([aDefineName isEqualToString:UDN_BAITS])
            if ([entry.baitUsed.name isEqualToString:anObjectName]) {
                entry.baitUsed = nil;
                entry.baitUsed = [CMABait withName:REMOVED_TEXT];
            }
        
        if ([aDefineName isEqualToString:UDN_FISHING_METHODS]) {
            NSMutableSet *tempSet = [entry.fishingMethods mutableCopy];
            
            for (CMAFishingMethod *method in entry.fishingMethods)
                if ([method.name isEqualToString:anObjectName])
                    [tempSet removeObject:method];
            
            if ([tempSet count] <= 0)
                entry.fishingMethods = nil;
            else
                entry.fishingMethods = tempSet;
        }
    }
}

- (void)editUserDefine: (NSString *)aDefineName objectNamed: (NSString *)objectName newProperties: (id)aNewObject {
    [[self userDefineNamed:aDefineName] editObjectNamed:objectName newObject:aNewObject];
}

- (void)incStatsForEntry: (CMAEntry *)anEntry {
    // fish quantity
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishSpecies incNumberCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishSpecies incNumberCaught:1];
    
    // fish weight
    if ([anEntry.fishWeight integerValue] > 0) {
        [anEntry.fishSpecies incWeightCaught:[anEntry.fishWeight integerValue]];
        
        // handle ounces for imperial users
        if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
            if ([anEntry.fishOunces integerValue] > 0) {
                [anEntry.fishSpecies incOuncesCaught:[anEntry.fishOunces integerValue]];
                
                if ([anEntry.fishSpecies.ouncesCaught integerValue] >= kOuncesInAPound) {
                    [anEntry.fishSpecies incWeightCaught:1];
                    [anEntry.fishSpecies decNumberCaught:kOuncesInAPound];
                }
            }
        }
    }
    
    // bait used
    if (anEntry.baitUsed) {
        if ([anEntry.fishQuantity integerValue] > 0)
            [anEntry.baitUsed incFishCaught:[anEntry.fishQuantity integerValue]];
        else
            [anEntry.baitUsed incFishCaught:1];
    }
    
    // location
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishingSpot incFishCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishingSpot incFishCaught:1];
}

- (void)decStatsForEntry: (CMAEntry *)anEntry {
    // quantity
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishSpecies decNumberCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishSpecies decNumberCaught:1];
    
    // weight
    if ([anEntry.fishWeight integerValue] > 0)
        [anEntry.fishSpecies decWeightCaught:[anEntry.fishWeight integerValue]];
    
    // fish weight
    if ([anEntry.fishWeight integerValue] > 0) {
        [anEntry.fishSpecies decWeightCaught:[anEntry.fishWeight integerValue]];
        
        // handle ounces for imperial users
        if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
            if ([anEntry.fishOunces integerValue] > 0) {
                [anEntry.fishSpecies decOuncesCaught:[anEntry.fishOunces integerValue]];
                
                if ([anEntry.fishSpecies.ouncesCaught integerValue] < 0) {
                    [anEntry.fishSpecies decWeightCaught:1];
                    [anEntry.fishSpecies incNumberCaught:kOuncesInAPound];
                }
            }
        }
    }
    
    // bait used
    if (anEntry.baitUsed) {
        if ([anEntry.fishQuantity integerValue] > 0)
            [anEntry.baitUsed decFishCaught:[anEntry.fishQuantity integerValue]];
        else
            [anEntry.baitUsed decFishCaught:1];
    }
    
    // location
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishingSpot decFishCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishingSpot decFishCaught:1];
}

#pragma mark - Accessing

- (CMAUserDefine *)userDefineNamed: (NSString *)aName {
    for (CMAUserDefine *define in [self userDefines])
        if ([[define name] isEqualToString:aName])
            return define;
        
    return nil;
}

- (NSInteger)entryCount {
    return [self.entries count];
}

// returns nil if no entry with aDate exist, otherwise returns entry with aDate
- (CMAEntry *)entryDated: (NSDate *)aDate {
    // calender stuff is needed so only certain date units are compared
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger calendarComponents = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *aDateComponents = [calendar components:calendarComponents fromDate:aDate];
    aDate = [calendar dateFromComponents:aDateComponents];
    
    for (CMAEntry *entry in self.entries) {
        NSDateComponents *entryDateComponents = [calendar components:calendarComponents fromDate:entry.date];
        NSDate *entryDate = [calendar dateFromComponents:entryDateComponents];
        
        if ([entryDate isEqualToDate:aDate])
            return entry;
    }
    
    return nil;
}

- (NSString *)lengthUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_LENGTH_SHORTHAND;
        else
            return UNIT_IMPERIAL_LENGTH;
    }
    
    if (shorthand)
        return UNIT_METRIC_LENGTH_SHORTHAND;
    else
        return UNIT_METRIC_LENGTH;
}

- (NSString *)weightUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_WEIGHT_SHORTHAND;
        else
            return UNIT_IMPERIAL_WEIGHT;
    }
    
    if (shorthand)
        return UNIT_METRIC_WEIGHT_SHORTHAND;
    else
        return UNIT_METRIC_WEIGHT;
}

- (NSString *)depthUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_DEPTH_SHORTHAND;
        else
            return UNIT_IMPERIAL_DEPTH;
    }
    
    if (shorthand)
        return UNIT_METRIC_DEPTH_SHORTHAND;
    else
        return UNIT_METRIC_DEPTH;
}

- (NSString *)temperatureUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_TEMPERATURE_SHORTHAND;
        else
            return UNIT_IMPERIAL_TEMPERATURE;
    }
    
    if (shorthand)
        return UNIT_METRIC_TEMPERATURE_SHORTHAND;
    else
        return UNIT_METRIC_TEMPERATURE;
}

- (NSString *)speedUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_SPEED_SHORTHAND;
        else
            return UNIT_IMPERIAL_SPEED;
    }
    
    if (shorthand)
        return UNIT_METRIC_SPEED_SHORTHAND;
    else
        return UNIT_METRIC_SPEED;
}

#pragma mark - Sorting

- (void)sortEntriesBy: (CMAEntrySortMethod)aSortMethod order: (CMASortOrder)aSortOrder {
    self.entrySortOrder = aSortOrder;
    self.entrySortMethod = aSortMethod;
    
    switch (self.entrySortMethod) {
        case CMAEntrySortMethodDate:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.date compare:e2.date];
            }] mutableCopy];
            break;
            
        case CMAEntrySortMethodSpecies:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishSpecies.name compare:e2.fishSpecies.name];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethodLocation:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                NSString *fullLoc1 = [NSString stringWithFormat:@"%@%@%@", e1.location.name, TOKEN_LOCATION, e1.fishingSpot.name];
                NSString *fullLoc2 = [NSString stringWithFormat:@"%@%@%@", e2.location.name, TOKEN_LOCATION, e2.fishingSpot.name];
                return [fullLoc1 compare:fullLoc2];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethodLength:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishLength compare:e2.fishLength];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethodWeight:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishWeight compare:e2.fishWeight];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethodBaitUsed:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.baitUsed.name compare:e2.baitUsed.name];
            }] mutableCopy];
            break;
            
        default:
            NSLog(@"Invalid CMASortMethod in [aCMAJournal sortEntriesBy].");
            break;
    }
    
    // reverse the array order if needed
    if (self.entrySortOrder == CMASortOrderDescending)
       self.entries = [[[self.entries reverseObjectEnumerator] allObjects] mutableCopy];
}

@end
