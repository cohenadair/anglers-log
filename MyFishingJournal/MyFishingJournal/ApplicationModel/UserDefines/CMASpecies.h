//
//  CMASpecies.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMASpecies : NSObject <NSCoding>

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSNumber *numberCaught;
@property (strong, nonatomic)NSNumber *weightCaught;

// instance creation
+ (CMASpecies *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMASpecies *)aNewSpecies;
- (void)incNumberCaught: (NSInteger)incBy;
- (void)decNumberCaught: (NSInteger)decBy;
- (void)incWeightCaught: (NSInteger)incBy;
- (void)decWeightCaught: (NSInteger)decBy;

@end
