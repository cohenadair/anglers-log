//
//  CMAFishingSpot.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
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

// accessing
- (CLLocationCoordinate2D)coordinate;

@end
