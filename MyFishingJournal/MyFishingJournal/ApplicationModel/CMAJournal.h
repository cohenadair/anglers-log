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

// user defines
@property (strong, nonatomic)CMAUserStrings *species;
@property (strong, nonatomic)CMAUserStrings *baits;
@property (strong, nonatomic)CMAUserStrings *fishingMethods;
@property (strong, nonatomic)CMAUserLocations *locations;

// setting
- (void)addEntry: (CMAEntry *)anEntry;
- (void)removeEntryDated: (NSDate *)aDate;
- (void)editEntryDated: (NSDate *)aDate newProperties: (CMAEntry *)aNewEntry;

- (void)addUserDefine: (NSString *)aName objectToAdd: (id)anObject;
- (void)removeUserDefine: (NSString *)aName objectToRemove: (id)anObject;
- (void)editUserDefine: (NSString *)aName objectToEdit: (id)anObject newProperties: (id)aNewObject;

// accessing
- (NSInteger)entryCount;
- (CMAEntry *)entryDated: (NSDate *)aDate;

@end
