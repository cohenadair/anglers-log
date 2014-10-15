//
//  CMAJournal.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAEntry.h"
#import "CMAUserStrings.h"
#import "CMAUserLocations.h"

@interface CMAJournal : NSObject

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)NSMutableDictionary *userDefines;

// setting
- (void)addEntry: (CMAEntry *)anEntry;
- (void)removeEntryDated: (NSDate *)aDate;
- (void)editEntryDated: (NSDate *)aDate newProperties: (CMAEntry *)aNewEntry;

- (id)userDefineNamed: (NSString *)aName;
- (void)addUserDefine: (NSString *)aDefineName objectToAdd: (id)anObject;
- (void)removeUserDefine: (NSString *)aDefineName objectNamed: (NSString *)anObjectName;
- (void)editUserDefine: (NSString *)aDefineName objectNamed: (id)aName newProperties: (id)aNewObject;

// accessing
- (NSInteger)entryCount;
- (CMAEntry *)entryDated: (NSDate *)aDate;

@end
