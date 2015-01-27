//
//  CMAUserDefine.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineObject.h"

@class CMAJournal;

@interface CMAUserDefine : CMAUserDefineObject /*<NSCoding>*/

@property (strong, nonatomic)CMAJournal *journal;

// Objects within these sets have to extend CMAUserDefineObject and abide by the CMAUserDefineProtocol
// There is a different property for each user define to map the Core Data model.
// Only one of these will not be NULL.
@property (strong, nonatomic)NSMutableOrderedSet *baits;
@property (strong, nonatomic)NSMutableOrderedSet *fishingMethods;
@property (strong, nonatomic)NSMutableOrderedSet *locations;
@property (strong, nonatomic)NSMutableOrderedSet *species;
@property (strong, nonatomic)NSMutableOrderedSet *waterClarities;

// initialization
- (CMAUserDefine *)initWithName:(NSString *)aName andJournal:(CMAJournal *)aJournal;

// validation
- (void)validateObjects;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (BOOL)addObject:(id)anObject;
- (void)removeObjectNamed:(NSString *)aName;
- (void)editObjectNamed:(NSString *)aName newObject: (id)aNewObject;

// accessing
- (NSMutableOrderedSet *)activeSet;
- (void)setActiveSet:(NSMutableOrderedSet *)aMutableOrderedSet;
- (NSInteger)count;
- (id)objectNamed:(NSString *)aName;
- (id)objectAtIndex:(NSInteger)anIndex;
- (BOOL)isSetOfStrings;

// object types
- (id)emptyObjectNamed:(NSString *)aName;

// sorting
- (void)sortByNameProperty;

@end
