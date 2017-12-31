//
//  CMAUserDefineTest.m
//  AnglersLogTests
//
//  Created by Cohen Adair on 2017-12-31.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAStorageManager.h"

@interface CMAUserDefineTest : XCTestCase
@end

@implementation CMAUserDefineTest

/**
 * Tests that searching a bait for text returns the correct result.
 */
- (void)testSearching {
    CMAFishingMethod *spot = [CMAStorageManager.sharedManager managedFishingMethod];
    spot.name = @"Test user define";
    
    XCTAssertTrue([spot containsSearchText:@"user define"]);
    XCTAssertFalse([spot containsSearchText:@"nothing"]);
}

@end
