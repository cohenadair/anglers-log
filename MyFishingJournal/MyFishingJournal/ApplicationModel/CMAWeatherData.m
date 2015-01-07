//
//  CMAWeatherData.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//
//  Uses OpenWeatherMapAPI
//  https://github.com/adba/OpenWeatherMapAPI
//

#import "CMAWeatherData.h"

NSString *const API_KEY = @"35f69a23678dead2c75e0599eadbb4e1";

@implementation CMAWeatherData

#pragma mark - Instance Creation

+ (CMAWeatherData *)withCoordinates:(CLLocationCoordinate2D)coordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType {
    return [[self alloc] initWithCoordinates:coordinate andJournal:aMeasurementSystemType];
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _temperature = [aDecoder decodeObjectForKey:@"CMAWeatherDataTemperature"];
        _windSpeed = [aDecoder decodeObjectForKey:@"CMAWeatherDataWindSpeed"];
        _skyConditions = [aDecoder decodeObjectForKey:@"CMAWeatherDataSkyConditions"];
        _weatherImage = [aDecoder decodeObjectForKey:@"CMAWeatherDataWeatherImage"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.temperature forKey:@"CMAWeatherDataTemperature"];
    [aCoder encodeObject:self.windSpeed forKey:@"CMAWeatherDataWindSpeed"];
    [aCoder encodeObject:self.skyConditions forKey:@"CMAWeatherDataSkyConditions"];
    [aCoder encodeObject:self.weatherImage forKey:@"CMAWeatherDataWeatherImage"];
}

#pragma mark - Initialization

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType {
    if (self = [super init]) {
        //_weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:API_KEY];
        _coordinate = coordinate;
        
        /*if (aMeasurementSystemType == CMAMeasuringSystemTypeImperial)
            _weatherAPI.temperatureFormat = kOWMTempFahrenheit;
        else
            _weatherAPI.temperatureFormat = kOWMTempCelcius;*/
    }
    
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
    return [NSString stringWithFormat:@"Wind Speed: %ld%@", (long)[self.windSpeed integerValue], aUnitString];
}

- (NSString *)skyConditionsAsString {
    return [NSString stringWithFormat:@"Sky: %@", self.skyConditions];
}

@end
