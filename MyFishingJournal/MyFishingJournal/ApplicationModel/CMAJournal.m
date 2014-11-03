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
    _entries = [NSMutableSet set];
    _userDefines = [NSMutableDictionary dictionary];
    
    [_userDefines setValue:[CMAUserDefine withName:SET_SPECIES] forKey:SET_SPECIES];
    [_userDefines setValue:[CMAUserDefine withName:SET_BAITS] forKey:SET_BAITS];
    [_userDefines setValue:[CMAUserDefine withName:SET_FISHING_METHODS] forKey:SET_FISHING_METHODS];
    [_userDefines setValue:[CMAUserDefine withName:SET_LOCATIONS] forKey:SET_LOCATIONS];
    
    // TODO: Replace default defines with an Archiving file
    [self addUserDefine:SET_SPECIES objectToAdd:[CMASpecies withName:@"Smallmouth Bass"]];
    [self addUserDefine:SET_SPECIES objectToAdd:[CMASpecies withName:@"Largemouth Bass"]];
    [self addUserDefine:SET_SPECIES objectToAdd:[CMASpecies withName:@"Steelhead"]];
    [self addUserDefine:SET_SPECIES objectToAdd:[CMASpecies withName:@"Pike"]];
    [self addUserDefine:SET_SPECIES objectToAdd:[CMASpecies withName:@"Walleye"]];
    
    [self addUserDefine:SET_BAITS objectToAdd:[CMABait withName:@"Yellow Twisty Tail"]];
    [self addUserDefine:SET_BAITS objectToAdd:[CMABait withName:@"Crayfish"]];
    [self addUserDefine:SET_BAITS objectToAdd:[CMABait withName:@"Giant Minnow"]];
    
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:[CMAFishingMethod withName:@"Shore"]];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:[CMAFishingMethod withName:@"Fly Fishing"]];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:[CMAFishingMethod withName:@"Boat"]];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:[CMAFishingMethod withName:@"Trolling"]];
    
    CMALocation *portAlbert = [CMALocation withName:@"Port Albert"];
    [portAlbert addFishingSpot:[CMAFishingSpot withName:@"Little Hole"]];
    [portAlbert addFishingSpot:[CMAFishingSpot withName:@"Beaver Dam"]];
    [portAlbert addFishingSpot:[CMAFishingSpot withName:@"Baskets"]];
    
    CMALocation *silverLake = [CMALocation withName:@"Silver Lake"];
    [silverLake addFishingSpot:[CMAFishingSpot withName:@"Walleye Way"]];
    [silverLake addFishingSpot:[CMAFishingSpot withName:@"Lillypad Lane"]];
    
    [self addUserDefine:SET_LOCATIONS objectToAdd:portAlbert];
    [self addUserDefine:SET_LOCATIONS objectToAdd:silverLake];

    
    [self setMeasurementSystem:CMAMeasuringSystemType_Imperial];
    
    return self;
}

#pragma mark - Editing

- (void)addEntry: (CMAEntry *)anEntry {
    [self.entries addObject:anEntry];
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

@end
