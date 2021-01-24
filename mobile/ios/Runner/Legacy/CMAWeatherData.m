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

@implementation CMAWeatherData

@dynamic entry;
@dynamic temperature;
@dynamic windSpeed;
@dynamic skyConditions;
@dynamic imageURL;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitWeatherData:self];
}

@end
