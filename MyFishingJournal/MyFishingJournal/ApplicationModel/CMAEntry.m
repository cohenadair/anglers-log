//
//  CMAEntry.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"
#import "CMAConstants.h"

@implementation CMAEntry

#pragma mark - Instance Creation

+ (CMAEntry *)onDate: (NSDate *)aDate {
    return [[self alloc] initWithDate:aDate];
}

#pragma mark - Initialization

- (id)initWithDate: (NSDate *)aDate {
    if (self = [super init]) {
        _date = aDate;
        _images = [NSMutableSet set];
    }
    
    return self;
}

- (id)init {
    if (self = [super init])
        _images = [NSMutableSet set];
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:@"CMAEntryDate"];
        
        _images = [aDecoder decodeObjectForKey:@"CMAEntryImages"];
        
        _fishSpecies = [aDecoder decodeObjectForKey:@"CMAEntryFishSpecies"];
        _fishLength = [aDecoder decodeObjectForKey:@"CMAEntryFishLength"];
        _fishWeight = [aDecoder decodeObjectForKey:@"CMAEntryFishWeight"];
        _fishOunces = [aDecoder decodeObjectForKey:@"CMAEntryFishOunces"];
        _fishQuantity = [aDecoder decodeObjectForKey:@"CMAEntryFishQuantity"];
        
        _baitUsed = [aDecoder decodeObjectForKey:@"CMAEntryBaitUsed"];
        _fishingMethods = [aDecoder decodeObjectForKey:@"CMAEntryFishingMethods"];
        _location = [aDecoder decodeObjectForKey:@"CMAEntryLocation"];
        _fishingSpot = [aDecoder decodeObjectForKey:@"CMAEntryFishingSpot"];
        
        _weatherData = [aDecoder decodeObjectForKey:@"CMAEntryWeatherData"];
        
        _waterTemperature = [aDecoder decodeObjectForKey:@"CMAEntryWaterTemerature"];
        _waterClarity = [aDecoder decodeObjectForKey:@"CMAEntryWaterClarity"];
        _waterDepth = [aDecoder decodeObjectForKey:@"CMAEntryWaterDeptch"];
        
        _notes = [aDecoder decodeObjectForKey:@"CMAEntryNotes"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.date forKey:@"CMAEntryDate"];
    
    [aCoder encodeObject:self.images forKey:@"CMAEntryImages"];
    
    [aCoder encodeObject:self.fishSpecies forKey:@"CMAEntryFishSpecies"];
    [aCoder encodeObject:self.fishLength forKey:@"CMAEntryFishLength"];
    [aCoder encodeObject:self.fishWeight forKey:@"CMAEntryFishWeight"];
    [aCoder encodeObject:self.fishOunces forKey:@"CMAEntryFishOunces"];
    [aCoder encodeObject:self.fishQuantity forKey:@"CMAEntryFishQuantity"];
    
    [aCoder encodeObject:self.baitUsed forKey:@"CMAEntryBaitUsed"];
    [aCoder encodeObject:self.fishingMethods forKey:@"CMAEntryFishingMethods"];
    [aCoder encodeObject:self.location forKey:@"CMAEntryLocation"];
    [aCoder encodeObject:self.fishingSpot forKey:@"CMAEntryFishingSpot"];
    
    [aCoder encodeObject:self.weatherData forKey:@"CMAEntryWeatherData"];
    
    [aCoder encodeObject:self.waterTemperature forKey:@"CMAEntryWaterTemerature"];
    [aCoder encodeObject:self.waterClarity forKey:@"CMAEntryWaterClarity"];
    [aCoder encodeObject:self.waterDepth forKey:@"CMAEntryWaterDeptch"];
    
    [aCoder encodeObject:self.notes forKey:@"CMAEntryNotes"];
}

#pragma mark - Accessing

- (NSInteger)imageCount {
    return [self.images count];
}

- (NSInteger)fishingMethodCount {
    return [self.fishingMethods count];
}

- (NSString *)fishingMethodsAsString {
    NSString *result = [NSString new];
    NSArray *fishingMethods = [self.fishingMethods allObjects];
    
    for (int i = 0; i < [fishingMethods count]; i++) {
        if (i == ([fishingMethods count] - 1)) {
            result = [result stringByAppendingString:[fishingMethods[i] name]];
            break;
        }
        
        result = [result stringByAppendingString:[fishingMethods[i] name]];
        result = [result stringByAppendingString:TOKEN_FISHING_METHODS];
    }
    
    return result;
}

- (NSString *)locationAsString {
    NSString *fishingSpotText;
    
    if (self.fishingSpot)
        fishingSpotText = [NSString stringWithFormat:@"%@%@", TOKEN_LOCATION, self.fishingSpot.name];
    else
        fishingSpotText = @"";
    
    return [NSString stringWithFormat:@"%@%@", self.location.name, fishingSpotText];
}

- (NSString *)weightAsStringWithMeasurementSystem:(CMAMeasuringSystemType)aMeasurementSystem shorthand:(BOOL)useShorthand {
    NSString *result = [NSString string];
    
    NSString *weightString;
    NSString *ounceString;
    
    if (aMeasurementSystem == CMAMeasuringSystemTypeImperial) {
        if (useShorthand) {
            weightString = UNIT_IMPERIAL_WEIGHT_SHORTHAND;
            ounceString = UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND;
        } else {
            weightString = [@" " stringByAppendingString:UNIT_IMPERIAL_WEIGHT];
            ounceString = [@" " stringByAppendingString:UNIT_IMPERIAL_WEIGHT_SMALL];
        }
    } else {
        if (useShorthand)
            weightString = UNIT_METRIC_WEIGHT_SHORTHAND;
        else
            weightString = [@" " stringByAppendingString:UNIT_METRIC_WEIGHT];
    }
    
    if (aMeasurementSystem == CMAMeasuringSystemTypeImperial) {
        NSString *ounces;
        
        if (self.fishOunces)
            ounces = [NSString stringWithFormat:@"%ld", (long)[self.fishOunces integerValue]];
        else
            ounces = @"0";
        
        result = [NSString stringWithFormat:@"%ld%@ %ld%@", (long)[self.fishWeight integerValue], weightString, (long)[self.fishOunces integerValue], ounceString];
    } else
        result = [NSString stringWithFormat:@"%ld%@", (long)[self.fishWeight integerValue], weightString];
    
    return result;
}

#pragma mark - Editing

- (void)addImage: (UIImage *)anImage {
    [self.images addObject:anImage];
}

- (void)removeImage: (UIImage *)anImage {
    [self.images removeObject:anImage];
}

@end
