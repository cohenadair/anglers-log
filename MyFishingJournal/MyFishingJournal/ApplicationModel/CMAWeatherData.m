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

#pragma mark - Initialization

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate andJournal:(CMAMeasuringSystemType)aMeasurementSystemType {
    if (self = [super init]) {
        [self initOpenWeatherMapAPIForJournal:aMeasurementSystemType];
        [self initWeatherPropertiesWithCoordinate:coordinate];
    }
    
    return self;
}

- (void)initOpenWeatherMapAPIForJournal:(CMAMeasuringSystemType)aMeasurementSystemType {
    self._weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:API_KEY];
    
    if (aMeasurementSystemType == CMAMeasuringSystemTypeImperial)
        self._weatherAPI.temperatureFormat = kOWMTempFahrenheit;
    else
        self._weatherAPI.temperatureFormat = kOWMTempCelcius;
}

- (void)initWeatherPropertiesWithCoordinate:(CLLocationCoordinate2D)coordinate {
    [self._weatherAPI currentWeatherByCoordinate:coordinate withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            NSLog(@"Error in initWeatherPropertiesWithCoordinates");
            return;
        }

        NSArray *weatherArray = result[@"weather"];
        
        if ([weatherArray count] > 0) {
            NSString *imageString = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", result[@"weather"][0][@"icon"]];
            [self setWeatherImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]]]];
            [self setSkyConditions:result[@"weather"][0][@"main"]];
        } else {
            [self setWeatherImage:[UIImage imageNamed:@"no_image.png"]];
            [self setSkyConditions:@"N/A"];
        }
        
        [self setTemperature:(NSNumber *)result[@"main"][@"temp"]]; // [3][3]
        [self setWindSpeed:result[@"wind"][@"speed"]]; // [1][0]
        
        [self print];
    }];
}

#pragma mark - Debugging

- (void)print {
    NSLog(@"Temperature: %ld\nWindSpeed: %@\n@Sky: %@", (long)[self.temperature integerValue], self.windSpeed, self.skyConditions);
}

@end
