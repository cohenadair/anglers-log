//
//  CMALocation.h
//  TheAnglersLog
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

@interface CMALocation : CMAUserDefineObject <CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableOrderedSet *fishingSpots;

// initializing
- (CMALocation *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;

// editing
- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot;
- (void)removeFishingSpotNamed: (NSString *)aName;
- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot;
- (void)edit:(CMALocation *)aNewLocation;

// accessing
- (NSInteger)fishingSpotCount;
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName;
- (MKCoordinateRegion)mapRegion;

// sorting
- (void)sortFishingSpotsByName;

@end
