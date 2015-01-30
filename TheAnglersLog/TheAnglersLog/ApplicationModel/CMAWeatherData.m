//
//  CMAWeatherData.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//
//  Uses OpenWeatherMapAPI
//  https://github.com/adba/OpenWeatherMapAPI
//

#import "CMAWeatherData.h"

NSString *const kAPIKey = @"35f69a23678dead2c75e0599eadbb4e1";

@implementation CMAWeatherData

@synthesize weatherAPI;
@synthesize coordinate;

@dynamic entry;
@dynamic temperature;
@dynamic windSpeed;
@dynamic skyConditions;
@dynamic weatherImage;

#pragma mark - Initialization

- (id)initWithCoordinates:(CLLocationCoordinate2D)aCoordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType {
    self.weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:kAPIKey];
    self.coordinate = aCoordinate;
    
    if (aMeasurementSystemType == CMAMeasuringSystemTypeImperial)
        self.weatherAPI.temperatureFormat = kOWMTempFahrenheit;
    else
        self.weatherAPI.temperatureFormat = kOWMTempCelcius;
    
    return self;
}

#pragma mark - Debugging

- (void)print {
    NSLog(@"\nTemperature: %ld\nWind Speed: %@\nSky Conditions: %@", (long)[self.temperature integerValue], self.windSpeed, self.skyConditions);
}

#pragma mark - Accessing

- (NSString *)temperatureAsStringWithUnits:(NSString *)aUnitString {
    return [NSString stringWithFormat:@"%ld%@", (long)[self.temperature integerValue], aUnitString];
}

- (NSString *)windSpeedAsStringWithUnits:(NSString *)aUnitString {
    return [NSString stringWithFormat:@"Wind Speed: %ld %@", (long)[self.windSpeed integerValue], aUnitString];
}

- (NSString *)skyConditionsAsString {
    return [NSString stringWithFormat:@"Sky: %@", self.skyConditions];
}

@end
