//
//  CMASpecies.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMASpecies : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)NSNumber *numberCaught;
@property (strong, nonatomic)NSNumber *weightCaught;
@property (strong, nonatomic)NSNumber *ouncesCaught;

// initialization
- (CMASpecies *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMASpecies *)aNewSpecies;
- (void)incNumberCaught: (NSInteger)incBy;
- (void)decNumberCaught: (NSInteger)decBy;
- (void)incWeightCaught: (NSInteger)incBy;
- (void)decWeightCaught: (NSInteger)decBy;
- (void)incOuncesCaught: (NSInteger)incBy;
- (void)decOuncesCaught: (NSInteger)decBy;

// other
- (BOOL)removedFromUserDefines;

@end
