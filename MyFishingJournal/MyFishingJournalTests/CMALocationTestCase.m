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
    
    // addFishingSpot
    XCTAssert([myLocation fishingSpotCount] == 0, @"Wrong fishing spot count; should be 0");
    [myLocation addFishingSpot:@"Little Hole" location:loc1];
    XCTAssert([myLocation fishingSpotCount] == 1, @"Wrong fishing spot count; should be 1");
    [myLocation addFishingSpot:@"Beaver Dam" location:loc2];
    [myLocation addFishingSpot:@"Rock Wall" location:loc3];
    XCTAssert([myLocation fishingSpotCount] == 3, @"Wrong fishing spot count; should be 3");
    
    // removeFishingSpotByName
    [myLocation removeFishingSpotByName:@"Little Hole"];
    XCTAssert([myLocation fishingSpotCount] == 2, @"Wrong fishing spot count; should be 2");
    [myLocation removeFishingSpotByName:@"Rock Wall"];
    [myLocation removeFishingSpotByName:@"Beaver Dam"];
    XCTAssert([myLocation fishingSpotCount] == 0, @"Wrong fishing spot count; should be 0");
}

- (void)testEditFishingSpot {
    CMALocation *myLocation = [self sampleLocation];
    
    CLLocation *loc1 = [CLLocation new];
    loc1 = [loc1 initWithLatitude:2.3456 longitude:6.1872];
    CLLocation *loc2 = [CLLocation new];
    loc2 = [loc2 initWithLatitude:3.2245 longitude:7.2235];
    
    [myLocation addFishingSpot:@"Little Hole" location:loc1];
    [myLocation editFishingSpot:@"Little Hole" newName:@"Willow Overgrown" newLocation:loc2];
    XCTAssert([[myLocation fishingSpots] objectForKey:@"Willow Overgrown"], @"Edit fishing spot failed; name should have changed");
    
    CLLocation *loc = [myLocation.fishingSpots objectForKey:@"Willow Overgrown"];
    XCTAssert([loc coordinate].latitude == 3.2245, @"Edit fishing spot failed; latitude should have changed");
    XCTAssert([loc coordinate].longitude == 7.2235, @"Edit fishing spot failed; longitute should have changed");
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
