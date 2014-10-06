//
//  CMAFishingSpotTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CMAFishingSpot.h"

@interface CMAFishingSpotTestCase : XCTestCase

@end

@implementation CMAFishingSpotTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCoordinates {
    CMAFishingSpot *mySpot1 = [CMAFishingSpot withName:@"Little Hole"];
    mySpot1.location = [mySpot1.location initWithLatitude:2.3456 longitude:6.1872];
    
    XCTAssert([mySpot1.name isEqualToString:@"Little Hole"], @"Name should be Little Hold");
    XCTAssert([mySpot1 coordinate].longitude == 6.1872, @"Longitude should be 6.1872");
    XCTAssert([mySpot1 coordinate].latitude == 2.3456, @"Latitude should be 2.3456");
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
 */

@end
