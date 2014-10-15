//
//  CMAJournal.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournal.h"

@implementation CMAJournal

// initializing
- (CMAJournal *)init {
    _entries = [NSMutableSet set];
    _userDefines = [NSMutableDictionary dictionary];
    [_userDefines setValue:[CMAUserStrings new] forKey:@"Species"];
    [_userDefines setValue:[CMAUserStrings new] forKey:@"Baits"];
    [_userDefines setValue:[CMAUserStrings new] forKey:@"Fishing Methods"];
    [_userDefines setValue:[CMAUserLocations new] forKey:@"Locations"];
    
    return self;
}

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

- (id)userDefineNamed: (NSString *)aName {
    return [self.userDefines objectForKey:aName];
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
