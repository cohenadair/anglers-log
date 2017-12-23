//
//  CMAJSONReaderTest.m
//  AnglersLogTests
//
//  Created by Cohen Adair on 2017-12-20.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAJSONReader.h"
#import "CMAStorageManager.h"

@interface CMAJSONReaderTest : XCTestCase
@end

@implementation CMAJSONReaderTest {
    NSBundle *mBundle;
    CMAJournal *mJournal;
}

- (void)setUp {
    [super setUp];
    mBundle = [NSBundle bundleForClass:self.class];
    mJournal = [CMAStorageManager.sharedManager managedJournal];
}

- (void)tearDown {
    mBundle = nil;
    mJournal = nil;
    [super tearDown];
}

- (void)loadJournalFromFile:(NSString *)file {
    NSString *filePath = [mBundle pathForResource:file ofType:@".json"];
    NSString *error = nil;
    
    [CMAJSONReader JSONToJournal:mJournal jsonFilePath:filePath error:&error];
    
    XCTAssertNil(error);
    XCTAssertTrue(mJournal.entryCount > 0);
}

/**
 * Tests importing Entry date's from backup files created on old iOS. Old clients backed up in a
 * date format string accurate to the minute.
 */
- (void)testImportEntryDateFromIOSLegacy {
    [self assertDatesNotNilForFile:@"backup_ios_legacy"];
}

/**
 * Tests importing Entry date's from backup files created on iOS. iOS backs up in a date format
 * string accurate to the minute.
 */
- (void)testImportEntryDateFromIOS {
    [self assertDatesNotNilForFile:@"backup_ios"];
}

/**
 * Tests importing Entry date's from backup files created on Android. Android backs up in a date
 * format as a timestamp in millisections.
 */
- (void)testImportEntryDateFromAndroid {
    [self assertDatesNotNilForFile:@"backup_android"];
}

- (void)assertDatesNotNilForFile:(NSString *)file {
    [self loadJournalFromFile:file];
    for (CMAEntry *entry in mJournal.entries) {
        XCTAssertNotNil(entry.date);
    }
}

@end
