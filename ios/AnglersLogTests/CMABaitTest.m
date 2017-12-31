//
//  CMABaitTest.m
//  AnglersLogTests
//
//  Created by Cohen Adair on 2017-12-27.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAStorageManager.h"

@interface CMABaitTest : XCTestCase
@end

@implementation CMABaitTest

/**
 * Tests that searching a bait for text returns the correct result.
 */
- (void)testSearching {
    CMABait *bait = [CMAStorageManager.sharedManager managedBait];
    bait.name = @"Test bait";
    bait.color = @"Green";
    bait.size = @"Large";
    bait.baitType = CMABaitTypeReal;
    bait.baitDescription = @"A bait description that means nothing.";
    
    XCTAssertTrue([bait containsSearchText:@"Test bait"]);
    XCTAssertTrue([bait containsSearchText:@"Green"]);
    XCTAssertTrue([bait containsSearchText:@"large"]);
    XCTAssertTrue([bait containsSearchText:@"real"]);
    XCTAssertTrue([bait containsSearchText:@"means nothing"]);
    
    XCTAssertFalse([bait containsSearchText:@"Rapala"]);
    XCTAssertFalse([bait containsSearchText:@"Blue"]);
    XCTAssertFalse([bait containsSearchText:@"small"]);
    XCTAssertFalse([bait containsSearchText:@"Live"]);
    XCTAssertFalse([bait containsSearchText:@"Tipped with minnow."]);
}

/**
 * Tests that searching a bait for text returns the correct result, even when that bait has nil
 * property values.
 */
- (void)testSearchingNilValues {
    CMABait *bait = [CMAStorageManager.sharedManager managedBait];
    bait.name = @"Test bait";
    XCTAssertTrue([bait containsSearchText:@"Test bait"]);
}

@end
