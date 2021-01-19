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

#pragma mark - Accessing

- (NSString *)dateAsFileNameString {
    return [CMAUtilities stringForDate:self.date withFormat:DATE_FILE_STRING];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitEntry:self];
}

@end
