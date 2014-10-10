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
    // NSStrings
    CMAUserStrings *userStrings = [CMAUserStrings withName:@"Example"];
    NSMutableString *someName = [NSMutableString stringWithString:@"Some Name"];
    NSString *anotherName = @"Another Name";
    
    [userStrings addObject:someName];
    XCTAssert([userStrings objectCount] == 1, @"Add object failed; count should be 1");
    
    [userStrings editString:someName newString:anotherName];
    XCTAssert([userStrings.objects containsObject:someName], @"Edit string failed; someName should still exist");
    XCTAssert([userStrings stringNamed:@"Another Name"] != nil, @"Edit string failed; should be a string with named Another String");
    
    [userStrings removeObject:someName];
    XCTAssert([userStrings objectCount] == 0, @"Remove object failed; count should be 0");
    
    // CMALocations
    CMAUserLocations *userLocations = [CMAUserLocations withName:@"Another Example"];
    CMALocation *aLocation = [CMALocation withName:@"Port Albert"];
    CMALocation *anotherLocation = [CMALocation withName:@"Goderich"];
    
    [userLocations addObject:aLocation];
    [userLocations editLocation:aLocation newLocation:anotherLocation];
    XCTAssert([userLocations.objects containsObject:aLocation], @"Edit location failed, aLocation should still exist");
    XCTAssert([userLocations locationNamed:@"Goderich"] != nil, @"Edit location failed; should be a location with name Goderich");
}

@end
