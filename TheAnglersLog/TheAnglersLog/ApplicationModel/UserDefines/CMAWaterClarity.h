//
//  CMAWaterClarity.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMAEntry;

@interface CMAWaterClarity : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)CMAEntry *entry;

// initialization
- (CMAWaterClarity *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit:(CMAWaterClarity *)aNewWaterClarity;

@end
