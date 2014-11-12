//
//  CMAEntry.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMALocation.h"
#import "CMASpecies.h"
#import "CMABait.h"

@interface CMAEntry : NSObject <NSCoding>

@property (strong, nonatomic)NSDate *date;
@property (strong, nonatomic)CMASpecies *fishSpecies;
@property (strong, nonatomic)CMABait *baitUsed;
@property (strong, nonatomic)NSString *notes;

@property (strong, nonatomic)NSNumber *fishLength;
@property (strong, nonatomic)NSNumber *fishWeight;
@property (strong, nonatomic)NSNumber *fishQuantity;

@property (strong, nonatomic)NSMutableSet *images;
@property (strong, nonatomic)NSSet *fishingMethods;

@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)CMAFishingSpot *fishingSpot;

// instance creation
+ (CMAEntry *)onDate: (NSDate *)aDate;

// initializing
- (id)initWithDate: (NSDate *)aDate;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// accessing
- (NSInteger)imageCount;
- (NSInteger)fishingMethodCount;
- (NSString *)concatinateFishingMethods;

// editing
- (void)addImage: (UIImage *)anImage;
- (void)removeImage: (UIImage *)anImage;

@end
