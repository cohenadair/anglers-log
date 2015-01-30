//
//  CMAWaterClarity.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMAUserDefine, CMAEntry;

@interface CMAWaterClarity : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)CMAUserDefine *userDefine;

// initialization
- (CMAWaterClarity *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;
- (void)validateProperties;

// editing
- (void)edit:(CMAWaterClarity *)aNewWaterClarity;
- (void)addEntry:(CMAEntry *)anEntry;

@end
