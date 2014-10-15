//
//  CMAUserDefinesTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CMAUserStrings.h"
#import "CMAUserLocations.h"

@interface CMAUserDefinesTestCase : XCTestCase

@end

@implementation CMAUserDefinesTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddEditRemove {
    // Strings
    CMAUserStrings *userStrings = [CMAUserStrings new];
    NSMutableString *aName = [NSMutableString stringWithString:@"Black Spoon"];
    
    [userStrings addObject:aName];
    XCTAssert([userStrings count] == 1, @"Add object failed; count should be 1");
    
    [userStrings editObjectNamed:aName newObject:@"Blue Spoon"];
    XCTAssert([userStrings.objects containsObject:aName], @"Edit string failed; someName should still exist");
    XCTAssert([userStrings stringNamed:@"Blue Spoon"] != nil, @"Edit string failed; should be a string with named Another String");
    
    [userStrings removeObjectNamed:@"Blue Spoon"];
    XCTAssert([userStrings count] == 0, @"Remove object failed; count should be 0");
    
    // CMALocations
    CMAUserLocations *userLocations = [CMAUserLocations new];
    CMALocation *aLocation = [CMALocation withName:@"Port Albert"];
    
    [userLocations addObject:aLocation];
    [userLocations editObjectNamed:@"Port Albert" newObject:[CMALocation withName:@"Goderich"]];
    XCTAssert([userLocations.objects containsObject:aLocation], @"Edit location failed, aLocation should still exist");
    XCTAssert([userLocations locationNamed:@"Goderich"] != nil, @"Edit location failed; should be a location with name Goderich");
    
    [userLocations removeObjectNamed:@"Goderich"];
    XCTAssert([userLocations count] == 0, @"Remove object failed; count should be 0");
}

@end
