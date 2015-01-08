//
//  CMAWeatherData.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWMWeatherAPI.h"   
#import "CMAConstants.h"

@interface CMAWeatherData : NSObject <NSCoding>

@property (strong, nonatomic)OWMWeatherAPI *weatherAPI;
@property (nonatomic)CLLocationCoordinate2D coordinate;

@property (strong, nonatomic)NSNumber *temperature;
@property (strong, nonatomic)NSString *windSpeed;
@property (strong, nonatomic)NSString *skyConditions;
@property (strong, nonatomic)UIImage *weatherImage;

+ (CMAWeatherData *)withCoordinates:(CLLocationCoordinate2D)coordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType;

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType;
- (void)print;

- (NSString *)temperatureAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)windSpeedAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)skyConditionsAsString;

@end
