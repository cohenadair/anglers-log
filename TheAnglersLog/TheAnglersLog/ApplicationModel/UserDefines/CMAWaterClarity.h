//
//  CMAWaterClarity.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMAUserDefineProtocol.h"

@interface CMAWaterClarity : NSManagedObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSString *name;

// initialization
- (CMAWaterClarity *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit:(CMAWaterClarity *)aNewWaterClarity;

@end
