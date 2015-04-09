//
//  CMADataImporter.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMADataImporter.h"
#import "CMAStorageManager.h"
#import "SSZipArchive.h"
#import "CMAJSONReader.h"

@implementation CMADataImporter

+ (void)importToJournal:(CMAJournal *)aJournal fromFilePath:(NSString *)aPath {
    // extract archive
    NSString *zipDestPath = [[CMAStorageManager sharedManager] documentsDirectory].path;
    zipDestPath = [zipDestPath stringByAppendingPathComponent:@"Images/"];
    [SSZipArchive unzipFileAtPath:aPath toDestination:zipDestPath];
    
    // parse JSON
    [CMAJSONReader JSONToJournal:aJournal jsonFilePath:aPath];
}

@end
