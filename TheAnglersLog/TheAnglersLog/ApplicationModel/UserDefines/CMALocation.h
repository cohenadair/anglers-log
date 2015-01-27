//
//  CMALocation.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CMAFishingSpot.h"
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMALocation : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)NSMutableOrderedSet *fishingSpots;

// initializing
- (CMALocation *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot;
- (void)removeFishingSpotNamed: (NSString *)aName;
- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot;
- (void)edit: (CMALocation *)aNewLocation;

// accessing
- (NSInteger)fishingSpotCount;
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName;
- (MKCoordinateRegion)mapRegion;
- (CMALocation *)copy;

// sorting
- (void)sortFishingSpotsByName;

// other
- (BOOL)removedFromUserDefines;

@end
