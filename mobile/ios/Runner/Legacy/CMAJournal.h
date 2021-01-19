//
//  CMAJournal.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMAConstants.h"
#import "CMAUserDefine.h"

@interface CMAJournal : NSManagedObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableOrderedSet *entries;
@property (strong, nonatomic)NSMutableSet *userDefines;
@property (nonatomic)CMAMeasuringSystemType measurementSystem;
@property (nonatomic)CMAEntrySortMethod entrySortMethod;
@property (nonatomic)CMASortOrder entrySortOrder;

// visiting
- (void)accept:(id)aVisitor;

@end
