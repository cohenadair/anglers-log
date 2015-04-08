//
//  CMAJSONWriter.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-07.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"
#import "CMAFishingMethod.h"

@interface CMAJSONWriter : NSObject

@property (strong, nonatomic)NSFileHandle *outFile;
@property (nonatomic)NSInteger currentTab;
@property (nonatomic)BOOL addComma; // used for some user defines (i.e. check if fishing method is last in an entry)

+ (void)journalToJSON:(CMAJournal *)aJournal atFilePath:(NSString *)aFilePath;

- (id)initWithFilePath:(NSString *)aFilePath;

// visiting
- (void)visitJournal:(CMAJournal *)aJournal;
- (void)visitEntry:(CMAEntry *)anEntry;
- (void)visitImage:(CMAImage *)anImage;
- (void)visitWeatherData:(CMAWeatherData *)someWeatherData;
- (void)visitUserDefne:(CMAUserDefine *)aUserDefine;
- (void)visitBait:(CMABait *)aBait;
- (void)visitFishingMethod:(CMAFishingMethod *)aFishingMethod;
- (void)visitLocation:(CMALocation *)aLocation;
- (void)visitFishingSpot:(CMAFishingSpot *)aFishingSpot;
- (void)visitSpecies:(CMASpecies *)aSpecies;
- (void)visitWaterClarity:(CMAWaterClarity *)aWaterClarity;

@end
