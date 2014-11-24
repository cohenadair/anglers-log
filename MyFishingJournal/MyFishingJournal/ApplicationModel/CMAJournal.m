//
//  CMAJournal.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournal.h"
#import "CMAConstants.h"
#import "CMAUserDefine.h"
#import "CMASpecies.h"
#import "CMABait.h"
#import "CMAFishingMethod.h"

@implementation CMAJournal

#pragma mark - Initialization

- (CMAJournal *)init {
    _entries = [NSMutableArray array];
    _userDefines = [NSMutableDictionary dictionary];
    
    [_userDefines setValue:[CMAUserDefine withName:SET_SPECIES] forKey:SET_SPECIES];
    [_userDefines setValue:[CMAUserDefine withName:SET_BAITS] forKey:SET_BAITS];
    [_userDefines setValue:[CMAUserDefine withName:SET_FISHING_METHODS] forKey:SET_FISHING_METHODS];
    [_userDefines setValue:[CMAUserDefine withName:SET_LOCATIONS] forKey:SET_LOCATIONS];
    
    [self setMeasurementSystem:CMAMeasuringSystemType_Imperial];
    [self setEntrySortMethod:CMAEntrySortMethod_Date];
    [self setEntrySortOrder:CMASortOrder_Descending];
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _entries = [aDecoder decodeObjectForKey:@"CMAJournalEntries"];
        _userDefines = [aDecoder decodeObjectForKey:@"CMAJournalUserDefines"];
        _measurementSystem = [aDecoder decodeIntegerForKey:@"CMAJournalMeasurmentSystem"];
        _entrySortMethod = [aDecoder decodeIntegerForKey:@"CMAJournalEntrySortMethod"];
        _entrySortOrder = [aDecoder decodeIntegerForKey:@"CMAJournalEntrySortOrder"];
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

- (BOOL)archive {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths firstObject];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@", docsPath, ARCHIVE_FILE_NAME];
    
    if ([NSKeyedArchiver archiveRootObject:self toFile:archivePath]) {
        NSLog(@"Successfully archived Journal.");
        return YES;
    } else
        NSLog(@"Failed to archive Journal.");
    
    return NO;
}

#pragma mark - Editing

- (BOOL)addEntry: (CMAEntry *)anEntry {
    if ([self entryDated:anEntry.date] != nil) {
        NSLog(@"Duplicate entry date.");
        return NO;
    }
    
    [self.entries addObject:anEntry];
    [self sortEntriesBy:self.entrySortMethod order:self.entrySortOrder];
    return YES;
}

- (void)removeEntryDated: (NSDate *)aDate {
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
}

- (void)editUserDefine: (NSString *)aDefineName objectNamed: (NSString *)objectName newProperties: (id)aNewObject {
    [[self userDefineNamed:aDefineName] editObjectNamed:objectName newObject:aNewObject];
}

#pragma mark - Accessing

- (CMAUserDefine *)userDefineNamed: (NSString *)aName {
    return [self.userDefines objectForKey:aName];
}

- (NSInteger)entryCount {
    return [self.entries count];
}

// returns nil if no entry with aDate exist, otherwise returns entry with aDate
- (CMAEntry *)entryDated: (NSDate *)aDate {
    // calender stuff is needed so only certain date units are compared
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger calendarComponents = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit);
    
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
    if (self.measurementSystem == CMAMeasuringSystemType_Imperial) {
        if (shorthand)
            return @"\"";
        else
            return @"Inches";
    }
    
    if (shorthand)
        return @" cm";
    else
        return @"Centimeters";
}

- (NSString *)weightUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemType_Imperial) {
        if (shorthand)
            return @" lbs.";
        else
            return @"Pounds";
    }
    
    if (shorthand)
        return @" kg";
    else
        return @"Kilograms";
}

#pragma mark - Sorting

- (void)sortEntriesBy: (CMAEntrySortMethod)aSortMethod order: (CMASortOrder)aSortOrder {
    self.entrySortOrder = aSortOrder;
    self.entrySortMethod = aSortMethod;
    
    switch (self.entrySortMethod) {
        case CMAEntrySortMethod_Date:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.date compare:e2.date];
            }] mutableCopy];
            break;
            
        case CMAEntrySortMethod_Species:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishSpecies.name compare:e2.fishSpecies.name];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethod_Location:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                NSString *fullLoc1 = [NSString stringWithFormat:@"%@%@%@", e1.location.name, TOKEN_LOCATION, e1.fishingSpot.name];
                NSString *fullLoc2 = [NSString stringWithFormat:@"%@%@%@", e2.location.name, TOKEN_LOCATION, e2.fishingSpot.name];
                return [fullLoc1 compare:fullLoc2];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethod_Length:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishLength compare:e2.fishLength];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethod_Weight:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishWeight compare:e2.fishWeight];
            }] mutableCopy];
            break;
        
        case CMAEntrySortMethod_BaitUsed:
            self.entries = [[self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.baitUsed.name compare:e2.baitUsed.name];
            }] mutableCopy];
            break;
            
        default:
            NSLog(@"Invalid CMASortMethod in [aCMAJournal sortEntriesBy].");
            break;
    }
    
    // reverse the array order if needed
    if (self.entrySortOrder == CMASortOrder_Descending)
       self.entries = [[[self.entries reverseObjectEnumerator] allObjects] mutableCopy];
}

@end
