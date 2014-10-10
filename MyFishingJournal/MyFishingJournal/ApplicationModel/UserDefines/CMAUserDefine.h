//
//  CMAUserDefine.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAUserDefine : NSObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableSet *objects;

// instance creation
+ (CMAUserDefine *)withName: (NSString *)aName;

// initializing
- (CMAUserDefine *)initWithName: (NSString *)aName;

// setting
- (void)addObject: (id)anObject;
- (void)removeObject: (id)anObject;

// accessing
- (NSInteger)count;

@end
