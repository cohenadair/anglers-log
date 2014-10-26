//
//  CMAEntry.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMALocation.h"

@interface CMAEntry : NSObject

@property (strong, nonatomic)NSDate *date;
@property (strong, nonatomic)NSString *fishSpecies;
@property (strong, nonatomic)NSString *notes;
@property (strong, nonatomic)NSString *baitUsed;

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

// accessing
- (NSInteger)imageCount;
- (NSInteger)fishingMethodCount;

// editing
- (void)addImage: (UIImage *)anImage;
- (void)removeImage: (UIImage *)anImage;

@end
