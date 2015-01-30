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

@class CMAUserDefine, CMAEntry;

@interface CMALocation : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)CMAUserDefine *userDefine;

@property (strong, nonatomic)NSMutableOrderedSet *fishingSpots;

// initializing
- (CMALocation *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot;
- (void)removeFishingSpotNamed: (NSString *)aName;
- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot;
- (void)edit:(CMALocation *)aNewLocation;
- (void)addEntry:(CMAEntry *)anEntry;

// accessing
- (NSInteger)fishingSpotCount;
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName;
- (MKCoordinateRegion)mapRegion;

// sorting
- (void)sortFishingSpotsByName;

@end
