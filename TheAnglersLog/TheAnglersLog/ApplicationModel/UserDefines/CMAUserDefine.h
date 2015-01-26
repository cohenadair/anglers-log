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

// Objects within this array have to extend CMAUserDefineObject and abide by the CMAUserDefineProtocol
@property (strong, nonatomic)NSMutableOrderedSet *objects;

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
- (NSInteger)count;
- (id)objectNamed:(NSString *)aName;
- (BOOL)isSetOfStrings;

// object types
- (id)emptyObjectNamed:(NSString *)aName;

// sorting
- (void)sortByNameProperty;

@end
