//
//  CMAWeatherData.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OWMWeatherAPI.h"   
#import "CMAConstants.h"

@class CMAEntry;

@interface CMAWeatherData : NSManagedObject

@property (strong, nonatomic)OWMWeatherAPI *weatherAPI;
@property (nonatomic)CLLocationCoordinate2D coordinate;

@property (strong, nonatomic)CMAEntry *entry;
@property (strong, nonatomic)NSNumber *temperature;
@property (strong, nonatomic)NSString *windSpeed;
@property (strong, nonatomic)NSString *skyConditions;
@property (strong, nonatomic)NSData *weatherImage;

- (void)withCoordinates:(CLLocationCoordinate2D)aCoordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType;
- (void)print;

- (NSString *)temperatureAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)windSpeedAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)skyConditionsAsString;

@end
