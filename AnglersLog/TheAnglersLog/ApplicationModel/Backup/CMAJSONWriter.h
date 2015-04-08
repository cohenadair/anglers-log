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

+ (void)journalToJSON:(CMAJournal *)aJournal;

// visiting
- (void)visitJournal:(CMAJournal *)aJournal;
- (void)visitEntry:(CMAEntry *)anEntry;
- (void)visitImage:(CMAImage *)anImage;
- (void)visitFishingMethod:(CMAFishingMethod *)aFishingMethod;
- (void)visitWeatherData:(CMAWeatherData *)someWeatherData;
- (void)visitUserDefne:(CMAUserDefine *)aUserDefine;

@end
