//
//  CMAUserDefineObject.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-26.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <CoreData/CoreData.h>

@class CMAUserDefine, CMAEntry;

@interface CMAUserDefineObject : NSManagedObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)CMAUserDefine *userDefine;

- (void)addEntry:(CMAEntry *)anEntry;

@end