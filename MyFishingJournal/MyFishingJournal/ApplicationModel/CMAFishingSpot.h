//
//  CMAFishingSpot.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CMAFishingSpot : NSObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)CLLocation *location;

// instance creation
+ (CMAFishingSpot *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// accessing
- (CLLocationCoordinate2D)coordinate;

@end
