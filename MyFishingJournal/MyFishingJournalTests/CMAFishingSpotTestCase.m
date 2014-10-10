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

- (void)testEdit {
    CMAFishingSpot *mySpot1 = [CMAFishingSpot withName:@"Little Hole"];
    mySpot1.location = [mySpot1.location initWithLatitude:2.3456 longitude:6.1872];
    CMAFishingSpot *mySpot2 = [CMAFishingSpot withName:@"Beaver Dam"];
    mySpot2.location = [mySpot2.location initWithLatitude:5.0000 longitude:1.0000];
    
    [mySpot1 edit:mySpot2];
    XCTAssert([mySpot1.name isEqualToString:@"Beaver Dam"], @"Fishing spot edit failed; name should equal Beaver Dam");
    XCTAssert([mySpot1 coordinate].latitude == 5.0000, @"Edit fishing spot failed; latitude should have changed");
    XCTAssert([mySpot1 coordinate].longitude == 1.0000, @"Edit fishing spot failed; longitute should have changed");
}

@end
