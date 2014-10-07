//
//  CMALocationTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import "CMALocation.h"
#import "CMAFishingSpot.h"


@interface CMALocationTestCase : XCTestCase

@end

@implementation CMALocationTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (CMALocation *)sampleLocation {
    return [CMALocation withName:@"Port Albert"];
}

- (void)testAddRemoveFishingSpot {
    CMALocation *myLocation = [self sampleLocation];
    
    CLLocation *loc1 = [CLLocation new];
    loc1 = [loc1 initWithLatitude:1.0000 longitude:3.0000];
    CLLocation *loc2 = [CLLocation new];
    loc2 = [loc2 initWithLatitude:5.0000 longitude:8.0000];
    CLLocation *loc3 = [CLLocation new];
    loc3 = [loc3 initWithLatitude:2.3456 longitude:6.1872];
    
    CMAFishingSpot *mySpot1 = [CMAFishingSpot withName:@"Little Hole"];
    mySpot1.location = loc1;
    CMAFishingSpot *mySpot2 = [CMAFishingSpot withName:@"Beaver Dam"];
    mySpot2.location = loc2;
    CMAFishingSpot *mySpot3 = [CMAFishingSpot withName:@"Rock Wall"];
    mySpot3.location = loc3;
    
    // addFishingSpot
    XCTAssert([myLocation fishingSpotCount] == 0, @"Wrong fishing spot count; should be 0");
    [myLocation addFishingSpot:mySpot1];
    XCTAssert([myLocation fishingSpotCount] == 1, @"Wrong fishing spot count; should be 1");
    [myLocation addFishingSpot:mySpot2];
    [myLocation addFishingSpot:mySpot3];
    XCTAssert([myLocation fishingSpotCount] == 3, @"Wrong fishing spot count; should be 3");
    
    // duplicate fishing spot
    XCTAssert(![myLocation addFishingSpot:mySpot2], @"Duplicate fishing spot should not be added");
    
    // removeFishingSpotByName
    [myLocation removeFishingSpot:mySpot1];
    XCTAssert([myLocation fishingSpotCount] == 2, @"Wrong fishing spot count; should be 2");
    [myLocation removeFishingSpot:mySpot3];
    [myLocation removeFishingSpot:mySpot2];
    XCTAssert([myLocation fishingSpotCount] == 0, @"Wrong fishing spot count; should be 0");
}

- (void)testEditFishingSpot {
    CMALocation *myLocation = [self sampleLocation];
    
    CLLocation *loc1 = [CLLocation new];
    loc1 = [loc1 initWithLatitude:2.3456 longitude:6.1872];
    CLLocation *loc2 = [CLLocation new];
    loc2 = [loc2 initWithLatitude:3.2245 longitude:7.2235];
    
    CMAFishingSpot *mySpot1 = [CMAFishingSpot withName:@"Little Hole"];
    mySpot1.location = loc1;
    CMAFishingSpot *mySpot2 = [CMAFishingSpot withName:@"Beaver Dam"];
    mySpot2.location = loc2;
    
    [myLocation addFishingSpot:mySpot1];
    [myLocation editFishingSpot:mySpot1 newFishingSpot:mySpot2];
    XCTAssert([[myLocation fishingSpots] containsObject:mySpot2], @"Edit fishing spot failed; mySpot2 fishing spot should exist");
    
    CMAFishingSpot *myFishingSpot = [myLocation.fishingSpots member:mySpot2];
    XCTAssert([myFishingSpot coordinate].latitude == 3.2245, @"Edit fishing spot failed; latitude should have changed");
    XCTAssert([myFishingSpot coordinate].longitude == 7.2235, @"Edit fishing spot failed; longitute should have changed");
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
