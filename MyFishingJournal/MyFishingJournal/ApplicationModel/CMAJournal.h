//
//  CMAJournal.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAUserDefine.h"

@interface CMAJournal : NSObject

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)NSMutableDictionary *userDefines;
@property (nonatomic)CMAMeasuringSystemType measurementSystem;

// editing
- (void)addEntry: (CMAEntry *)anEntry;
- (void)removeEntryDated: (NSDate *)aDate;
- (void)editEntryDated: (NSDate *)aDate newProperties: (CMAEntry *)aNewEntry;

- (void)addUserDefine: (NSString *)aDefineName objectToAdd: (id)anObject;
- (void)removeUserDefine: (NSString *)aDefineName objectNamed: (NSString *)anObjectName;
- (void)editUserDefine: (NSString *)aDefineName objectNamed: (id)aName newProperties: (id)aNewObject;

// accessing
- (CMAUserDefine *)userDefineNamed: (NSString *)aName;
- (NSInteger)entryCount;
- (CMAEntry *)entryDated: (NSDate *)aDate;

@end
