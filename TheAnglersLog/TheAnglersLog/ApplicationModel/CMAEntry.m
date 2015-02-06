//
//  CMAEntry.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"
#import "CMAConstants.h"

@implementation CMAEntry

@dynamic date;
@dynamic images;
@dynamic fishSpecies;
@dynamic fishLength;
@dynamic fishWeight;
@dynamic fishOunces;
@dynamic fishQuantity;
@dynamic fishResult;
@dynamic baitUsed;
@dynamic fishingMethods;
@dynamic location;
@dynamic fishingSpot;
@dynamic weatherData;
@dynamic waterTemperature;
@dynamic waterClarity;
@dynamic waterDepth;
@dynamic notes;
@dynamic journal;

#pragma mark - Initialization

- (id)initWithDate:(NSDate *)aDate {
    self.date = aDate;
    self.images = [NSMutableOrderedSet orderedSet];
    
    return self;
}

// Used for compatibility purposes.
- (void)validateProperties {
    
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

- (NSString *)fishResultAsString {
    if (self.fishResult == CMAFishResultKept)
        return @"Kept";
    else if (self.fishResult == CMAFishResultReleased)
        return @"Released";
    else
        NSLog(@"Invalid CMAFishResult in [CMAEntryInstance fishResultAsString].");
    
    return @"";
}

#pragma mark - Editing

- (void)edit:(CMAEntry *)aNewEntry {
    self.date = aNewEntry.date;
    self.images = aNewEntry.images;
    self.fishSpecies = aNewEntry.fishSpecies;
    self.fishLength = aNewEntry.fishLength;
    self.fishWeight = aNewEntry.fishWeight;
    self.fishOunces = aNewEntry.fishOunces;
    self.fishQuantity = aNewEntry.fishQuantity;
    self.fishResult = aNewEntry.fishResult;
    self.baitUsed = aNewEntry.baitUsed;
    self.fishingMethods = aNewEntry.fishingMethods;
    self.location = aNewEntry.location;
    self.fishingSpot = aNewEntry.fishingSpot;
    self.weatherData = aNewEntry.weatherData;
    self.waterTemperature = aNewEntry.waterTemperature;
    self.waterClarity = aNewEntry.waterClarity;
    self.waterDepth = aNewEntry.waterDepth;
    self.notes = aNewEntry.notes;
}

- (void)addImage:(CMAImage *)anImage {
    [self.images addObject:anImage];
}

- (void)removeImage:(CMAImage *)anImage {
    [self.images removeObject:anImage];
}

@end
