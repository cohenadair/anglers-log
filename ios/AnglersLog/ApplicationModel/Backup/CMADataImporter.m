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
#import "CMAUtilities.h"

@implementation CMADataImporter

+ (BOOL)importToJournal:(CMAJournal *)aJournal fromFilePath:(NSString *)aPath error:(NSString **)anErrorMsg  {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    // extract archive
    NSString *zipDestPath = [[CMAStorageManager sharedManager] documentsDirectory].path;
    zipDestPath = [zipDestPath stringByAppendingPathComponent:@"Images/"];
    [SSZipArchive unzipFileAtPath:aPath toDestination:zipDestPath];
    
    NSError *e;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:zipDestPath error:&e];
    if (e) NSLog(@"Error getting files at directory %@: %@", zipDestPath, e.localizedDescription);
    
    NSString *jsonPath = zipDestPath;
    
    // get .json file path
    for (int i = 0; i < [files count]; i++) {
        NSString *f = [files objectAtIndex:i];
        if ([f hasSuffix:@".json"]) {
            jsonPath = [jsonPath stringByAppendingPathComponent:f];
            break;
        }
    }
    
    // if there is no json file in the archive
    if ([jsonPath isEqualToString:zipDestPath]) {
        *anErrorMsg = ERROR_INVALID_FILE;
        return NO;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSLog(@"JSON file not found at path: %@", jsonPath);
        *anErrorMsg = ERROR_FILE_NOT_FOUND;
        return NO;
    }
    
    // parse JSON
    BOOL success = [CMAJSONReader JSONToJournal:aJournal jsonFilePath:jsonPath error:anErrorMsg];
    if (success) {
        [aJournal initProperties];
        [aJournal sortEntriesBy:aJournal.entrySortMethod order:aJournal.entrySortOrder];
        [aJournal archive];
        
        // remove .json file as it's no longer needed
        [CMAUtilities deleteFileAtPath:jsonPath];
        
        NSLog(@"Imported data in %f seconds.", CFAbsoluteTimeGetCurrent() - start);
    }
    
    return success;
}

@end
