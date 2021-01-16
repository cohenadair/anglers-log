//
//  CMAWeatherData.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-19.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMAConstants.h"

@class CMAEntry;

@interface CMAWeatherData : NSManagedObject

@property (strong, nonatomic)CMAEntry *entry;
@property (strong, nonatomic)NSNumber *temperature;
@property (strong, nonatomic)NSString *windSpeed;
@property (strong, nonatomic)NSString *skyConditions;
@property (strong, nonatomic)NSString *imageURL;

- (void)print;

- (NSString *)temperatureAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)windSpeedAsStringWithUnits:(NSString *)aUnitString;
- (NSString *)skyConditionsAsString;
- (UIImage *)imageURLAsUIImage;

// visiting
- (void)accept:(id)aVisitor;

@end
