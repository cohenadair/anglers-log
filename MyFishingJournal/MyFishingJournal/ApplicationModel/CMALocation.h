//
//  CMALocation.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CMALocation : NSObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableDictionary *fishingSpots;

// instance creation
+ (CMALocation *)withName: (NSString *)aName;

// initializing
- (id)initWithName: (NSString *)aName;

// setting
- (void)addFishingSpot: (NSString *)aName location: (CLLocation *)aLocation;
- (void)removeFishingSpotByName: (NSString *)aName;
- (void)editFishingSpot: (NSString *)aName newName: (NSString *)aNewName newLocation: (CLLocation *)aNewLocation;

// accessing
- (NSInteger)fishingSpotCount;

@end
