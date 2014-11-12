//
//  CMAUserDefine.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAUserDefine : NSObject <NSCoding>

@property (strong, nonatomic)NSString *name;

// Objects within this array have to implement the following:
//   @property (strong, nonatomic)NSString *name;
//   - (void)edit: (ClassType *)aNewObjectOfClassType; // Resets the name property to aNewObjectOfClassType's name property
@property (strong, nonatomic)NSMutableArray *objects;

// instance creation
+ (CMAUserDefine *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (BOOL)addObject: (id)anObject;
- (void)removeObjectNamed: (NSString *)aName;
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject;

// accessing
- (NSInteger)count;
- (id)objectNamed: (NSString *)aName;
- (BOOL)isSetOfStrings;

// object types
- (id)emptyObjectNamed: (NSString *)aName;

@end
