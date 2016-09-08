//
//  CMAEntry.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAJournal.h"
#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"

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

@synthesize __observersWereAdded;

#pragma mark - Initialization

- (id)initWithDate:(NSDate *)aDate {
    self.date = aDate;
    self.images = [NSMutableOrderedSet orderedSet];
    
    [self addObservers];
    
    return self;
}

// Used for compatibility purposes.
- (void)handleModelUpdate {
    for (CMAImage *img in self.images)
        [img handleModelUpdate];
}

// Used to save memory later.
- (void)initProperties {
    for (CMAImage *img in self.images)
        [img initProperties];
    
    [self addObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id obj = [object primitiveValueForKey:keyPath];
    
    if ([obj isKindOfClass:[NSMutableSet class]]) // for fishing methods
        for (id o in obj)
            [(CMAUserDefineObject *)o addEntry:self];
    else
        [(CMAUserDefineObject *)obj addEntry:self];
}

- (void)addObservers {
    if (self.__observersWereAdded)
        return;
    
    // all these observers CMAUserDefineObjects, requiring each entry they are associated with to be added to their "entries" array
    [self addObserver:self forKeyPath:@"fishSpecies" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"baitUsed" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"fishingSpot" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"fishingMethods" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"waterClarity" options:NSKeyValueObservingOptionNew context:nil];
    
    self.__observersWereAdded = YES;
}

#pragma mark - Accessing

- (NSInteger)imageCount {
    return [self.images count];
}

- (BOOL)hasImageNamed:(NSString *)aFileName {
    for (CMAImage *img in self.images)
        if ([[img localImagePath] isEqualToString:aFileName])
            return YES;
    
    return NO;
}

- (NSInteger)fishingMethodCount {
    return [self.fishingMethods count];
}

- (NSString *)dateAsString {
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"MMMM dd, yyyy 'at' h:mm a"];
    
    return [format stringFromDate:self.date];
}

- (NSString *)dateAsFileNameString {
    return [CMAUtilities stringForDate:self.date withFormat:DATE_FILE_STRING];
}

- (NSString *)accurateDateAsFileNameString {
    return [CMAUtilities stringForDate:self.date
                            withFormat:ACCURATE_DATE_FILE_STRING];
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

// Returns "15 lbs. 8 oz." or "1 lb. 2 oz." or "2.4 kg"
- (NSString *)weightAsStringWithMeasurementSystem:(CMAMeasuringSystemType)aMeasurementSystem shorthand:(BOOL)useShorthand {
    NSString *result = @"";
    
    NSString *weightString;
    NSString *ounceString;
    
    if (aMeasurementSystem == CMAMeasuringSystemTypeImperial) {
        if (useShorthand) {
            if ([self.fishWeight integerValue] == 1)
                weightString = UNIT_IMPERIAL_WEIGHT_SINGLE_SHORTHAND;
            else
                weightString = UNIT_IMPERIAL_WEIGHT_SHORTHAND;
            
            ounceString = UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND;
        } else {
            if ([self.fishWeight integerValue] == 1)
                weightString = [@" " stringByAppendingString:UNIT_IMPERIAL_WEIGHT_SINGLE];
            else
                weightString = [@" " stringByAppendingString:UNIT_IMPERIAL_WEIGHT];
            
            ounceString = [@" " stringByAppendingString:UNIT_IMPERIAL_WEIGHT_SMALL];
        }
    } else {
        if (useShorthand)
            weightString = UNIT_METRIC_WEIGHT_SHORTHAND;
        else
            weightString = [@" " stringByAppendingString:UNIT_METRIC_WEIGHT];
    }
    
    if (aMeasurementSystem == CMAMeasuringSystemTypeImperial)
        result = [NSString stringWithFormat:@"%ld%@ %ld%@", (long)[self.fishWeight integerValue], weightString, (long)[self.fishOunces integerValue], ounceString];
    else
        result = [NSString stringWithFormat:@"%.2f%@", self.fishWeight.floatValue, weightString];
    
    return result;
}

- (NSString *)lengthAsStringWithMeasurementSystem:(CMAMeasuringSystemType)aMeasurementSystem shorthand:(BOOL)useShorthand {
    NSString *unitString;
    
    if (aMeasurementSystem == CMAMeasuringSystemTypeImperial) {
        if (useShorthand)
            unitString = UNIT_IMPERIAL_LENGTH_SHORTHAND;
        else
            unitString = UNIT_IMPERIAL_LENGTH;
    } else {
        if (useShorthand)
            unitString = UNIT_METRIC_LENGTH_SHORTHAND;
        else
            unitString = UNIT_METRIC_LENGTH;
    }
    
    return [NSString stringWithFormat:@"%.2f%@", self.fishLength.floatValue, unitString];
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

// Returns a string to be shared when sharing entries via social media.
- (NSString *)shareString {
    NSString *result = [NSString stringWithFormat:@"%@\n", self.fishSpecies.name];
    
    if ([self.fishLength integerValue] > 0) {
        NSString *lengthString = [NSString stringWithFormat:@"Length: %@\n", [self lengthAsStringWithMeasurementSystem:self.journal.measurementSystem shorthand:YES]];
        result = [result stringByAppendingString:lengthString];
    }
    
    if ([self.fishWeight integerValue] > 0) {
        NSString *weightString = [NSString stringWithFormat:@"Weight: %@\n", [self weightAsStringWithMeasurementSystem:self.journal.measurementSystem shorthand:YES]];
        result = [result stringByAppendingString:weightString];
    }
    
    if (self.baitUsed) {
        NSString *baitString = [NSString stringWithFormat:@"Bait: %@\n", self.baitUsed.name];
        result = [result stringByAppendingString:baitString];
    }
    
    return [result stringByAppendingString:SHARE_MESSAGE];
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
    if (![self hasImageNamed:anImage.imagePath])
        [anImage setEntry:self]; // thanks to core data, making this connection adds anImage to self.images
    else
        NSLog(@"An image at path already exists in this entry.");
}

- (void)removeImage:(CMAImage *)anImage {
    // removing the managed object removes it from the array as well
    [[CMAStorageManager sharedManager] deleteManagedObject:anImage saveContext:NO];
}

- (void)addFishingMethod:(CMAFishingMethod *)aFishingMethod {
    if (aFishingMethod == nil)
        return;
    
    [aFishingMethod addEntry:self];
    [self.fishingMethods addObject:aFishingMethod];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitEntry:self];
}

@end
