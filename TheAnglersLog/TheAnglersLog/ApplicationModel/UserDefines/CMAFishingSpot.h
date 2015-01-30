//
//  CMAFishingSpot.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMALocation, CMAEntry;

@interface CMAFishingSpot : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableSet *entries;
@property (strong, nonatomic)CMALocation *myLocation;
@property (strong, nonatomic)CLLocation *location;
@property (strong, nonatomic)NSNumber *fishCaught;

// initialization
- (CMAFishingSpot *)initWithName:(NSString *)aName;
- (void)validateProperties;

// editing
- (void)setCoordinates: (CLLocationCoordinate2D)coordinates;
- (void)edit: (CMAFishingSpot *)aNewFishingSpot;
- (void)incFishCaught: (NSInteger)incBy;
- (void)decFishCaught: (NSInteger)decBy;
- (void)addEntry:(CMAEntry *)anEntry;

// accessing
- (CLLocationCoordinate2D)coordinate;
- (NSString *)locationAsString;

@end
