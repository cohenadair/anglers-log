//
//  CMAWaterClarity.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"

@interface CMAWaterClarity : NSObject <NSCoding, CMAUserDefineProtocol>

@property (strong, nonatomic)NSString *name;

// instance creation
+ (CMAWaterClarity *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;
- (void)validateProperties;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMAWaterClarity *)aNewWaterClarity;

@end
