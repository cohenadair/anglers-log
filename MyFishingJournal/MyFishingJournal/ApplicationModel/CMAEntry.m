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
        _fishSpecies = [aDecoder decodeObjectForKey:@"CMAEntryFishSpecies"];
        _baitUsed = [aDecoder decodeObjectForKey:@"CMAEntryBaitUsed"];
        _notes = [aDecoder decodeObjectForKey:@"CMAEntryNotes"];
        _fishLength = [aDecoder decodeObjectForKey:@"CMAEntryFishLength"];
        _fishWeight = [aDecoder decodeObjectForKey:@"CMAEntryFishWeight"];
        _fishQuantity = [aDecoder decodeObjectForKey:@"CMAEntryFishQuantity"];
        _images = [aDecoder decodeObjectForKey:@"CMAEntryImages"];
        _fishingMethods = [aDecoder decodeObjectForKey:@"CMAEntryFishingMethods"];
        _location = [aDecoder decodeObjectForKey:@"CMAEntryLocation"];
        _fishingSpot = [aDecoder decodeObjectForKey:@"CMAEntryFishingSpot"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.date forKey:@"CMAEntryDate"];
    [aCoder encodeObject:self.fishSpecies forKey:@"CMAEntryFishSpecies"];
    [aCoder encodeObject:self.baitUsed forKey:@"CMAEntryBaitUsed"];
    [aCoder encodeObject:self.notes forKey:@"CMAEntryNotes"];
    [aCoder encodeObject:self.fishLength forKey:@"CMAEntryFishLength"];
    [aCoder encodeObject:self.fishWeight forKey:@"CMAEntryFishWeight"];
    [aCoder encodeObject:self.fishQuantity forKey:@"CMAEntryFishQuantity"];
    [aCoder encodeObject:self.images forKey:@"CMAEntryImages"];
    [aCoder encodeObject:self.fishingMethods forKey:@"CMAEntryFishingMethods"];
    [aCoder encodeObject:self.location forKey:@"CMAEntryLocation"];
    [aCoder encodeObject:self.fishingSpot forKey:@"CMAEntryFishingSpot"];
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

#pragma mark - Editing

- (void)addImage: (UIImage *)anImage {
    [self.images addObject:anImage];
}

- (void)removeImage: (UIImage *)anImage {
    [self.images removeObject:anImage];
}

@end
