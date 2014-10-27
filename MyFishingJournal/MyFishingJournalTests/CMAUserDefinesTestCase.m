//
//  CMAUserDefinesTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CMAUserDefine.h"
#import "CMASpecies.h"

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
    CMAUserDefine *define = [CMAUserDefine withName:@"Species"];
    CMASpecies *species1 = [CMASpecies withName:@"Steelhead"];
    CMASpecies *species2 = [CMASpecies withName:@"Salmon"];
    
    // add
    [define addObject:species1];
    XCTAssert([define count] == 1);
    [define addObject:species2];
    XCTAssert([define count] == 2);
    
    // edit
    [define editObjectNamed:@"Steelhead" newObject:@"Rainbow Trout"];
    [define editObjectNamed:@"Salmon" newObject:@"King Salmon"];
    XCTAssert([[define objects] containsObject:species1]);
    XCTAssert([[define objects] containsObject:species2]);
    XCTAssert([define objectNamed:@"Rainbow Trout"] != nil);
    XCTAssert([define objectNamed:@"King Salmon"] != nil);
    
    // remove
    [define removeObjectNamed:@"Rainbow Trout"];
    XCTAssert([define count] == 1);
    [define removeObjectNamed:@"King Salmon"];
    XCTAssert([define count] == 0);
}

@end
