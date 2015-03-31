//
//  CMAFishingSpot.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMALocation;

@interface CMAFishingSpot : CMAUserDefineObject <CMAUserDefineProtocol>

@property (strong, nonatomic)CMALocation *myLocation;
@property (strong, nonatomic)CLLocation *location;
@property (strong, nonatomic)NSNumber *fishCaught;

// initialization
- (CMAFishingSpot *)initWithName:(NSString *)aName;

// editing
- (void)setCoordinates:(CLLocationCoordinate2D)coordinates;
- (void)edit:(CMAFishingSpot *)aNewFishingSpot;
- (void)incFishCaught:(NSInteger)incBy;
- (void)decFishCaught:(NSInteger)decBy;

// accessing
- (CLLocationCoordinate2D)coordinate;
- (NSString *)locationAsString;

@end
