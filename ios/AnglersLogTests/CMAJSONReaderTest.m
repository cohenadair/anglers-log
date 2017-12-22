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
}

- (void)setUp {
    [super setUp];
    mBundle = [NSBundle bundleForClass:self.class];
}

- (void)tearDown {
    mBundle = nil;
    [super tearDown];
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
    NSString *filePath = [mBundle pathForResource:file ofType:@".json"];
    
    CMAJournal *testJournal = [CMAStorageManager.sharedManager managedJournal];
    NSString *error = nil;
    
    [CMAJSONReader JSONToJournal:testJournal jsonFilePath:filePath error:&error];
    
    XCTAssertNil(error);
    XCTAssertTrue(testJournal.entryCount > 0);
    for (CMAEntry *entry in testJournal.entries) {
        XCTAssertNotNil(entry.date);
    }
}

@end
