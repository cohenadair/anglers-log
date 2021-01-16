//
//  CMAWeatherData.m
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//
//  Uses OpenWeatherMapAPI
//  https://github.com/adba/OpenWeatherMapAPI
//

#import "CMAWeatherData.h"
#import "CMAJSONWriter.h"

NSString *const kAPIKey = @"35f69a23678dead2c75e0599eadbb4e1";

@implementation CMAWeatherData

@dynamic entry;
@dynamic temperature;
@dynamic windSpeed;
@dynamic skyConditions;
@dynamic imageURL;

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

- (UIImage *)imageURLAsUIImage {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitWeatherData:self];
}

@end
