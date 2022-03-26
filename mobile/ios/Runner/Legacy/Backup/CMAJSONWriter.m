//
//  CMAJSONWriter.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-07.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"
#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"

@implementation CMAJSONWriter

#pragma mark - Class Methods

+ (NSString *)journalToJSON:(CMAJournal *)aJournal {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    CMAJSONWriter *writer = [CMAJSONWriter new];
    
    [writer writeOpen];
    [aJournal accept:writer];
    [writer writeCloseWithComma:NO];
    
    NSLog(@"Wrote JSON in %f seconds.", CFAbsoluteTimeGetCurrent() - start);
    
    return writer.outString;
}

#pragma mark - Initializing

- (id)init {
    if (self = [super init]) {
        _outString = [NSMutableString new];
        _currentTab = 0;
    }
    
    return self;
}

- (NSFileHandle *)getFileForWritingAtPath:(NSString *)aFilePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:aFilePath])
        [[NSFileManager defaultManager] createFileAtPath:aFilePath contents:nil attributes:nil];
    
    return [NSFileHandle fileHandleForWritingAtPath:aFilePath];
}

#pragma mark - Writing

- (NSString *)escapeString:(NSString *)aString {
    NSData *json = [NSJSONSerialization dataWithJSONObject:@[aString] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    
    // Remove [] and "" from the beginning and end of encoded string.
    return [[jsonString substringToIndex:[jsonString length] - 2] substringFromIndex:2];
}

// does not add new line; adds tabs
- (void)writeString:(NSString *)aString {
    [self.outString appendString:aString];
}

// "aKey": "aString"
// adds new line
- (void)writeKeyValueString:(NSString *)aKey andString:(NSString *)aString andComma:(BOOL)comma {
    if (aString == nil)
        aString = @"";
    else
        aString = [self escapeString:aString];
    
    [self writeString:[NSString stringWithFormat:@"\"%@\": \"%@\"", aKey, aString]];
    if (comma)
        [self writeComma];
    [self writeNewLine];
}

// "aKey": aNumber.integerValue
// adds new line
- (void)writeKeyValueNumber:(NSString *)aKey andNumber:(NSNumber *)aNumber andComma:(BOOL)comma {
    if (aNumber == nil)
        aNumber = [NSNumber numberWithInteger:-1];
    [self writeString:[NSString stringWithFormat:@"\"%@\": %zd", aKey, aNumber.integerValue]];
    if (comma)
        [self writeComma];
    [self writeNewLine];
}

- (void)writeKeyValueInteger:(NSString *)aKey andInteger:(NSInteger)anInteger andComma:(BOOL)comma {
    [self writeKeyValueNumber:aKey andNumber:[NSNumber numberWithInteger:anInteger] andComma:comma];
}

- (void)writeKeyValueFloat:(NSString *)aKey andFloat:(CGFloat)aFloat andComma:(BOOL)comma {
    [self writeKeyValueString:aKey andString:[NSString stringWithFormat:@"%f", aFloat] andComma:comma];
}

- (void)writeKeyValueData:(NSString *)aKey andData:(NSData *)data andComma:(BOOL)comma {
    NSString *valueString = @"";
    if (data != nil) {
        valueString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    [self writeKeyValueString:aKey andString:valueString andComma:comma];
}

// adds new line
- (void)writeKey:(NSString *)aKey withOpenToken:(NSString *)anOpenToken {
    [self writeString:[NSString stringWithFormat:@"\"%@\": %@", aKey, anOpenToken]];
    [self tabIn];
}

// adds new line
- (void)writeCloseWithComma:(BOOL)comma andCloseToken:(NSString *)aCloseToken {
    [self tabOut];
    [self writeString:aCloseToken];
    if (comma)
        [self writeComma];
    [self writeNewLine];
}

// "aKey": {
- (void)writeKey:(NSString *)aKey {
    [self writeKey:aKey withOpenToken:@"{"];
}

// "aKey": [
- (void)writeArrayKey:(NSString *)aKey {
    [self writeKey:aKey withOpenToken:@"["];
}

// "aString"
// adds new line
- (void)writeValueString:(NSString *)aString withComma:(BOOL)comma {
    [self writeString:[NSString stringWithFormat:@"\"%@\"", aString]];
    if (comma)
        [self writeComma];
    [self writeNewLine];
}

// }
// },
- (void)writeCloseWithComma:(BOOL)comma {
    [self writeCloseWithComma:comma andCloseToken:@"}"];
}

// ]
// ],
- (void)writeArrayCloseWithComma:(BOOL)comma {
    [self writeCloseWithComma:comma andCloseToken:@"]"];
}

// adds new line
- (void)writeOpen {
    [self writeString:@"{"];
    [self tabIn];
}

// does not add tabs; does not add new line; only writes a comma
- (void)writeComma {
    [self.outString appendString:@","];
}

// does not add tabs
- (void)writeNewLine {
}

- (void)tabIn {
    self.currentTab++;
}

- (void)tabOut {
    self.currentTab--;
}

#pragma mark - Visiting

- (void)visitJournal:(CMAJournal *)aJournal {
    [self writeKey:@"journal"];
    
    [self writeKeyValueString:@"name" andString:aJournal.name andComma:YES];

    [self writeArrayKey:@"entries"];
    for (CMAEntry *e in aJournal.entries)
        [e accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeArrayKey:@"userDefines"];
    for (CMAUserDefine *d in aJournal.userDefines)
        [d accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeKeyValueInteger:@"measurementSystem" andInteger:aJournal.measurementSystem andComma:YES];
    [self writeKeyValueInteger:@"entrySortMethod" andInteger:aJournal.entrySortMethod andComma:YES];
    [self writeKeyValueInteger:@"entrySortOrder" andInteger:aJournal.entrySortOrder andComma:NO];
    
    [self writeCloseWithComma:NO];
}

- (void)visitEntry:(CMAEntry *)anEntry {
    [self writeOpen];
    
    [self writeKeyValueString:@"date" andString:[anEntry dateAsFileNameString] andComma:YES];
    
    [self writeArrayKey:@"images"];
    for (CMAImage *i in anEntry.images) { // open and close need to be here because images aren't always written as an array (see visitBait:)
        [self writeOpen];
        [i accept:self];
        [self writeCloseWithComma:i != [i.entry.images lastObject]];
    }
    [self writeArrayCloseWithComma:YES];
    
    [self writeKeyValueString:@"fishSpecies" andString:anEntry.fishSpecies.name andComma:YES];
    [self writeKeyValueNumber:@"fishLength" andNumber:anEntry.fishLength andComma:YES];
    [self writeKeyValueNumber:@"fishWeight" andNumber:anEntry.fishWeight andComma:YES];
    [self writeKeyValueNumber:@"fishOunces" andNumber:anEntry.fishOunces andComma:YES];
    [self writeKeyValueNumber:@"fishQuantity" andNumber:anEntry.fishQuantity andComma:YES];
    [self writeKeyValueInteger:@"fishResult" andInteger:anEntry.fishResult andComma:YES];
    [self writeKeyValueString:@"baitUsed" andString:anEntry.baitUsed.name andComma:YES];
    
    [self writeArrayKey:@"fishingMethodNames"];
    for (CMAFishingMethod *m in anEntry.fishingMethods)
        [self writeValueString:m.name withComma:(m != [[anEntry.fishingMethods allObjects] lastObject])];
    [self writeArrayCloseWithComma:YES];
    
    [self writeKeyValueString:@"location" andString:anEntry.location.name andComma:YES];
    [self writeKeyValueString:@"fishingSpot" andString:anEntry.fishingSpot.name andComma:YES];
    
    [self writeKey:@"weatherData"];
    [anEntry.weatherData accept:self];
    [self writeCloseWithComma:YES];
    
    [self writeKeyValueNumber:@"waterTemperature" andNumber:anEntry.waterTemperature andComma:YES];
    [self writeKeyValueString:@"waterClarity" andString:anEntry.waterClarity.name andComma:YES];
    [self writeKeyValueNumber:@"waterDepth" andNumber:anEntry.waterDepth andComma:YES];
    [self writeKeyValueString:@"notes" andString:anEntry.notes andComma:YES];
    [self writeKeyValueString:@"journal" andString:anEntry.journal.name andComma:NO];
    
    [self writeCloseWithComma:anEntry != [anEntry.journal.entries lastObject]];
}

- (void)visitImage:(CMAImage *)anImage {
    [self writeKeyValueString:@"imagePath" andString:[anImage localImagePath] andComma:YES];
    [self writeKeyValueString:@"entryDate" andString:[anImage.entry dateAsFileNameString] andComma:YES];
    [self writeKeyValueString:@"baitName" andString:anImage.bait.name andComma:NO];
}

- (void)visitWeatherData:(CMAWeatherData *)someWeatherData {
    [self writeKeyValueString:@"entry" andString:[someWeatherData.entry dateAsFileNameString] andComma:YES];
    [self writeKeyValueNumber:@"temperature" andNumber:someWeatherData.temperature andComma:YES];
    [self writeKeyValueString:@"windSpeed" andString:someWeatherData.windSpeed andComma:YES];
    [self writeKeyValueString:@"skyConditions" andString:someWeatherData.skyConditions andComma:YES];
    [self writeKeyValueString:@"imageURL" andString:someWeatherData.imageURL andComma:NO];
}

- (void)visitUserDefne:(CMAUserDefine *)aUserDefine {
    [self writeOpen];
    
    [self writeKeyValueString:@"name" andString:aUserDefine.name andComma:YES];
    [self writeKeyValueString:@"journal" andString:aUserDefine.journal.name andComma:YES];
    
    [self writeArrayKey:@"baits"];
    for (CMABait *b in aUserDefine.baits)
        [b accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeArrayKey:@"fishingMethods"];
    for (CMAFishingMethod *m in aUserDefine.fishingMethods)
        [m accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeArrayKey:@"locations"];
    for (CMALocation *l in aUserDefine.locations)
        [l accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeArrayKey:@"species"];
    for (CMASpecies *s in aUserDefine.species)
        [s accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeArrayKey:@"waterClarities"];
    for (CMAWaterClarity *c in aUserDefine.waterClarities)
        [c accept:self];
    [self writeArrayCloseWithComma:NO];
    
    [self writeCloseWithComma:aUserDefine != [[aUserDefine.journal.userDefines allObjects] lastObject]];
}

- (void)visitBait:(CMABait *)aBait {
    [self writeOpen];
    
    [self writeKeyValueString:@"name" andString:aBait.name andComma:YES];
    [self writeKeyValueString:@"baitDescription" andString:aBait.baitDescription andComma:YES];
    
    [self writeKey:@"image"];
    [aBait.imageData accept:self];
    [self writeCloseWithComma:YES];
    
    [self writeKeyValueNumber:@"fishCaught" andNumber:aBait.fishCaught andComma:YES];
    [self writeKeyValueString:@"size" andString:aBait.size andComma:YES];
    [self writeKeyValueString:@"color" andString:aBait.color andComma:YES];
    [self writeKeyValueInteger:@"baitType" andInteger:aBait.baitType andComma:NO];
    
    [self writeCloseWithComma:aBait != [aBait.userDefine.baits lastObject]];
}

- (void)visitFishingMethod:(CMAFishingMethod *)aFishingMethod {
    [self writeOpen];
    [self writeKeyValueString:@"name" andString:aFishingMethod.name andComma:NO];
    [self writeCloseWithComma:aFishingMethod != [aFishingMethod.userDefine.fishingMethods lastObject]];
}

- (void)visitLocation:(CMALocation *)aLocation {
    [self writeOpen];
    
    [self writeKeyValueString:@"name" andString:aLocation.name andComma:YES];
    
    [self writeArrayKey:@"fishingSpots"];
    for (CMAFishingSpot *s in aLocation.fishingSpots)
        [s accept:self];
    [self writeArrayCloseWithComma:NO];
    
    [self writeCloseWithComma:aLocation != [aLocation.userDefine.locations lastObject]];
}

- (void)visitFishingSpot:(CMAFishingSpot *)aFishingSpot {
    [self writeOpen];
    
    [self writeKeyValueString:@"name" andString:aFishingSpot.name andComma:YES];
    [self writeKeyValueNumber:@"fishCaught" andNumber:aFishingSpot.fishCaught andComma:YES];
    
    [self writeKey:@"coordinates"];
    [self writeKeyValueFloat:@"latitude" andFloat:aFishingSpot.location.coordinate.latitude andComma:YES];
    [self writeKeyValueFloat:@"longitude" andFloat:aFishingSpot.location.coordinate.longitude andComma:NO];
    [self writeCloseWithComma:YES];
    
    [self writeKeyValueString:@"location" andString:aFishingSpot.myLocation.name andComma:NO];
    
    [self writeCloseWithComma:aFishingSpot != [aFishingSpot.myLocation.fishingSpots lastObject]];
}

- (void)visitSpecies:(CMASpecies *)aSpecies {
    [self writeOpen];
    
    [self writeKeyValueString:@"name" andString:aSpecies.name andComma:YES];
    [self writeKeyValueNumber:@"numberCaught" andNumber:aSpecies.numberCaught andComma:YES];
    [self writeKeyValueNumber:@"weightCaught" andNumber:aSpecies.weightCaught andComma:YES];
    [self writeKeyValueNumber:@"ouncesCaught" andNumber:aSpecies.ouncesCaught andComma:NO];
    
    [self writeCloseWithComma:aSpecies != [aSpecies.userDefine.species lastObject]];
}

- (void)visitWaterClarity:(CMAWaterClarity *)aWaterClarity {
    [self writeOpen];
    [self writeKeyValueString:@"name" andString:aWaterClarity.name andComma:NO];
    [self writeCloseWithComma:aWaterClarity != [aWaterClarity.userDefine.waterClarities lastObject]];
}

@end
