//
//  CMAFishingMethod.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMAUserDefine;

@interface CMAFishingMethod : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)CMAUserDefine *userDefine;

// initialization
- (CMAFishingMethod *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMAFishingMethod *)aNewFishingMethod;

@end
