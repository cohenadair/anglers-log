//
//  CMAEntryTest.m
//  AnglersLogTests
//
//  Created by Cohen Adair on 2017-12-22.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAStorageManager.h"

@interface CMAEntryTest : XCTestCase
@end

@implementation CMAEntryTest

/**
 * Tests the correct result when an entry's length is requested for display.
 */
- (void)testLengthAsString {
    CMAEntry *entry = [CMAStorageManager.sharedManager managedEntry];
    entry.fishLength = @50;
    
    NSString *shortMetric =
            [entry lengthAsStringWithMeasurementSystem:CMAMeasuringSystemTypeMetric
                                             shorthand:YES];
    XCTAssertEqualObjects(shortMetric, @"50.00 cm");
    
    NSString *shortImperial =
            [entry lengthAsStringWithMeasurementSystem:CMAMeasuringSystemTypeImperial
                                             shorthand:YES];
    XCTAssertEqualObjects(shortImperial, @"50.00\"");
}

@end
