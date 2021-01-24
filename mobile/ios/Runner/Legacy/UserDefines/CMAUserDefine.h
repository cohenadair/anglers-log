//
//  CMAUserDefine.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineObject.h"

@class CMABait;
@class CMAJournal;

@interface CMAUserDefine : NSManagedObject

@property (strong, nonatomic)CMAJournal *journal;
@property (strong, nonatomic)NSString *name;

// Objects within these sets have to extend CMAUserDefineObject and abide by the CMAUserDefineProtocol
// There is a different property for each user define to map the Core Data model.
// Only one of these will not be NULL.
@property (strong, nonatomic)NSMutableOrderedSet<CMABait *> *baits;
@property (strong, nonatomic)NSMutableOrderedSet *fishingMethods;
@property (strong, nonatomic)NSMutableOrderedSet *locations;
@property (strong, nonatomic)NSMutableOrderedSet *species;
@property (strong, nonatomic)NSMutableOrderedSet *waterClarities;

// visiting
- (void)accept:(id)aVisitor;

@end
