//
//  CMAJournal.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournal.h"
#import "CMAConstants.h"

@implementation CMAJournal

#pragma mark - Initialization

- (CMAJournal *)init {
    _entries = [NSMutableSet set];
    _userDefines = [NSMutableDictionary dictionary];
    [_userDefines setValue:[CMAUserStrings new] forKey:SET_SPECIES];
    [_userDefines setValue:[CMAUserStrings new] forKey:SET_BAITS];
    [_userDefines setValue:[CMAUserStrings new] forKey:SET_FISHING_METHODS];
    [_userDefines setValue:[CMAUserLocations new] forKey:SET_LOCATIONS];
    
    [self addUserDefine:SET_SPECIES objectToAdd:@"Smallmouth Bass"];
    [self addUserDefine:SET_SPECIES objectToAdd:@"Largemouth Bass"];
    [self addUserDefine:SET_SPECIES objectToAdd:@"Steelhead"];
    [self addUserDefine:SET_SPECIES objectToAdd:@"Pike"];
    [self addUserDefine:SET_SPECIES objectToAdd:@"Walleye"];
    
    [self addUserDefine:SET_BAITS objectToAdd:@"Yellow Twisty Tail"];
    [self addUserDefine:SET_BAITS objectToAdd:@"Crayfish"];
    [self addUserDefine:SET_BAITS objectToAdd:@"Giant Minnow"];
    
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:@"Shore"];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:@"Fly Fishing"];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:@"Boat"];
    [self addUserDefine:SET_FISHING_METHODS objectToAdd:@"Trolling"];
    
    [self addUserDefine:SET_LOCATIONS objectToAdd:[CMALocation withName:@"Port Albert"]];
    [self addUserDefine:SET_LOCATIONS objectToAdd:[CMALocation withName:@"Silver Lake"]];
    
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

- (id)userDefineNamed: (NSString *)aName {
    return [self.userDefines objectForKey:aName];
}

- (NSInteger)entryCount {
    return [self.entries count];
}

// returns nil if no entry with aDate exist, otherwise returns entry with aDate
- (CMAEntry *)entryDated: (NSDate *)aDate {
    for (CMAEntry *entry in self.entries)
        if ([entry.date compare:aDate] == NSOrderedSame)
            return entry;
    
    return nil;
}

@end
