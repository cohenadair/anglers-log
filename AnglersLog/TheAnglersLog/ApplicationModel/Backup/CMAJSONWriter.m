//
//  CMAJSONWriter.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-07.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"

@implementation CMAJSONWriter

#pragma mark - Class Methods

+ (void)journalToJSON:(CMAJournal *)aJournal {
    CMAJSONWriter *writer = [self new];
    
    [writer writeString:@"{\n"];
    [writer tabIn];
    [aJournal accept:writer];
    [writer tabOut];
    [writer writeString:@"}"];
    
    [writer.outFile closeFile];
}

#pragma mark - Initializing

- (id)init {
    if (self = [super init]) {
        _outFile = [self getFileForWriting];
        _currentTab = 0;
    }
    
    return self;
}

- (NSFileHandle *)getFileForWriting {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yyyy_h-mm_a";
    
    NSString *fileName = [dateFormatter stringFromDate:[NSDate date]];
    fileName = [fileName stringByAppendingString:@".json"];
    
    NSString *filePath = [[[CMAStorageManager sharedManager] documentsDirectory].path stringByAppendingPathComponent:fileName];
    
    NSLog(@"JSON file path: %@", filePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    return [NSFileHandle fileHandleForWritingAtPath:filePath];
}

#pragma mark - Writing

// does not add new line; adds tabs
- (void)writeString:(NSString *)aString {
    NSMutableString *tabs = [NSMutableString string];
    for (int i = 0; i < self.currentTab; i++)
        [tabs appendString:@"\t"];
    
    aString = [tabs stringByAppendingString:aString];
    [self.outFile writeData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}

// "aKey": "aString"
// adds new line
- (void)writeKeyValueString:(NSString *)aKey andString:(NSString *)aString andComma:(BOOL)comma {
    if (aString == nil)
        aString = @"";
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

- (void)writeKeyValueData:(NSString *)aKey andData:(NSData *)data andComma:(BOOL)comma {
    NSString *valueString = @"";
    if (data != nil) {
        valueString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    [self writeKeyValueString:aKey andString:valueString andComma:comma];
}

// adds new line
- (void)writeKey:(NSString *)aKey withOpenToken:(NSString *)anOpenToken {
    [self writeString:[NSString stringWithFormat:@"\"%@\": %@\n", aKey, anOpenToken]];
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
    [self writeString:@"{\n"];
    [self tabIn];
}

// does not add tabs; does not add new line; only writes a comma
- (void)writeComma {
    [self.outFile writeData:[@"," dataUsingEncoding:NSUTF8StringEncoding]];
}

// does not add tabs
- (void)writeNewLine {
    [self.outFile writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
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
    for (CMAImage *i in anEntry.images)
        [i accept:self];
    [self writeArrayCloseWithComma:YES];
    
    [self writeKeyValueString:@"fishSpecies" andString:anEntry.fishSpecies.name andComma:YES];
    [self writeKeyValueNumber:@"fishLength" andNumber:anEntry.fishLength andComma:YES];
    [self writeKeyValueNumber:@"fishWeight" andNumber:anEntry.fishWeight andComma:YES];
    [self writeKeyValueNumber:@"fishOunces" andNumber:anEntry.fishOunces andComma:YES];
    [self writeKeyValueNumber:@"fishQuantity" andNumber:anEntry.fishQuantity andComma:YES];
    [self writeKeyValueInteger:@"fishResult" andInteger:anEntry.fishResult andComma:YES];
    [self writeKeyValueString:@"baitUsed" andString:anEntry.baitUsed.name andComma:YES];
    
    [self writeArrayKey:@"fishingMethods"];
    for (CMAFishingMethod *m in anEntry.fishingMethods)
        [m accept:self];
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
    [self writeOpen];
    [self writeCloseWithComma:anImage != [anImage.entry.images lastObject]];
}

- (void)visitFishingMethod:(CMAFishingMethod *)aFishingMethod {
    [self writeOpen];
    [self writeCloseWithComma:aFishingMethod != [aFishingMethod.userDefine.fishingMethods lastObject]];
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
    [self writeCloseWithComma:aUserDefine != [[aUserDefine.journal.userDefines allObjects] lastObject]];
}

@end
