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
#import "CMAWaterClarity.h"
#import "CMAWeatherData.h"

@interface CMAEntry : NSObject <NSCoding>

// date and time
@property (strong, nonatomic)NSDate *date;

// photos
@property (strong, nonatomic)NSMutableSet *images;

// fish details
@property (strong, nonatomic)CMASpecies *fishSpecies;
@property (strong, nonatomic)NSNumber *fishLength;
@property (strong, nonatomic)NSNumber *fishWeight;
@property (strong, nonatomic)NSNumber *fishQuantity;

// catch details
@property (strong, nonatomic)CMABait *baitUsed;
@property (strong, nonatomic)NSMutableSet *fishingMethods;
@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)CMAFishingSpot *fishingSpot;

// weather conditions
@property (strong, nonatomic)CMAWeatherData *weatherData;

// water conditions
@property (strong, nonatomic)NSNumber *waterTemperature;
@property (strong, nonatomic)CMAWaterClarity *waterClarity;
@property (strong, nonatomic)NSNumber *waterDepth;

// notes
@property (strong, nonatomic)NSString *notes;

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
- (NSString *)locationAsString;
- (NSString *)fishingMethodsAsString;

// editing
- (void)addImage: (UIImage *)anImage;
- (void)removeImage: (UIImage *)anImage;

@end
