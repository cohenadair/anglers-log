//
//  CMABait.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAConstants.h"
#import "CMAUserDefineObject.h"

@interface CMABait : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)NSString *baitDescription;
@property (strong, nonatomic)NSData *image;
@property (strong, nonatomic)NSNumber *fishCaught;
@property (strong, nonatomic)NSString *size;
@property (nonatomic)CMABaitType baitType;

// initialization
- (CMABait *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMABait *)aNewBait;
- (CMABait *)copy;
- (void)incFishCaught: (NSInteger)incBy;
- (void)decFishCaught: (NSInteger)decBy;

// other
- (BOOL)removedFromUserDefines;

@end
