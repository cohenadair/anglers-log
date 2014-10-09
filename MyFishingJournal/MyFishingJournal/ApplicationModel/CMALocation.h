//
//  CMALocation.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CMAFishingSpot.h"

@interface CMALocation : NSObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableSet *fishingSpots;

// instance creation
+ (CMALocation *)withName: (NSString *)aName;

// initializing
- (id)initWithName: (NSString *)aName;

// setting
- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot;
- (void)removeFishingSpot: (CMAFishingSpot *)aFishingSpot;
- (void)editFishingSpot: (NSString *)fishingSpotName newProperties: (CMAFishingSpot *)aNewFishingSpot;

// accessing
- (NSInteger)fishingSpotCount;
- (CMAFishingSpot *)fishingSpotWithName: (NSString *)aName;

@end
