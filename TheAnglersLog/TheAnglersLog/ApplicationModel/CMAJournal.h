//
//  CMAJournal.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAUserDefine.h"

@interface CMAJournal : NSManagedObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableOrderedSet *entries;
@property (strong, nonatomic)NSMutableSet *userDefines;
@property (nonatomic)CMAMeasuringSystemType measurementSystem;
@property (nonatomic)CMAEntrySortMethod entrySortMethod;
@property (nonatomic)CMASortOrder entrySortOrder;

// initializing
- (CMAJournal *)initWithName:(NSString *)aName;
- (void)handleModelUpdate;
- (void)initProperties;

- (void)archive;

// editing
- (BOOL)addEntry:(CMAEntry *)anEntry;
- (void)removeEntryDated:(NSDate *)aDate;
- (void)editEntryDated:(NSDate *)aDate newProperties:(CMAEntry *)aNewEntry;

- (BOOL)addUserDefine:(NSString *)aDefineName objectToAdd:(id)anObject;
- (void)removeUserDefine:(NSString *)aDefineName objectNamed:(NSString *)anObjectName;
- (void)editUserDefine:(NSString *)aDefineName objectNamed:(id)aName newProperties:(id)aNewObject;

// accessing
- (CMAUserDefine *)userDefineNamed:(NSString *)aName;
- (NSInteger)entryCount;
- (CMAEntry *)entryDated:(NSDate *)aDate;
- (NSString *)lengthUnitsAsString:(BOOL)shorthand;
- (NSString *)weightUnitsAsString:(BOOL)shorthand;
- (NSString *)depthUnitsAsString:(BOOL)shorthand;
- (NSString *)temperatureUnitsAsString:(BOOL)shorthand;
- (NSString *)speedUnitsAsString:(BOOL)shorthand;

// sorting
- (void)sortEntriesBy:(CMAEntrySortMethod)aSortMethod order:(CMASortOrder)aSortOrder;

// filtering
- (NSMutableOrderedSet *)filterEntries:(NSString *)searchText;

@end
