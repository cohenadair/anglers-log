//
//  CMADataExport.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-08.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMADataExporter.h"
#import "CMAStorageManager.h"
#import "CMAJSONWriter.h"
#import "SSZipArchive.h"
#import "CMAUtilities.h"

@implementation CMADataExporter

+ (NSURL *)exportJournal:(CMAJournal *)aJournal {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    NSString *documentsDirectory = [[CMAStorageManager sharedManager] documentsDirectory].path;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM-dd-yyyy_h-mm_a";
    
    // archive file name/path
    NSString *zipFileName = [dateFormatter stringFromDate:[NSDate date]];
    zipFileName = [@"AngersLogBackup_" stringByAppendingString:zipFileName];
    zipFileName = [zipFileName stringByAppendingString:@".zip"];
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:zipFileName];
    
    // JSON file name/path
    NSString *jsonFileName = [dateFormatter stringFromDate:[NSDate date]];
    jsonFileName = [@"Images/AnglersLogData_" stringByAppendingString:jsonFileName];
    jsonFileName = [jsonFileName stringByAppendingString:@".json"];
    NSString *jsonFilePath = [documentsDirectory stringByAppendingPathComponent:jsonFileName];
    
    // export aJournal to JSON
    [CMAJSONWriter journalToJSON:aJournal atFilePath:jsonFilePath];
    
    // archive entire images and JSON
    [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:[documentsDirectory stringByAppendingPathComponent:@"Images/"]];
    
    // remove .json file as it's no longer needed
    [CMAUtilities deleteFileAtPath:jsonFilePath];
    
    NSLog(@"Exported data in %f seconds.", CFAbsoluteTimeGetCurrent() - start);
    
    return [NSURL fileURLWithPath:zipFilePath];
}

@end
