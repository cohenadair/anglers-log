//
//  CMAJournalTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CMAJournal.h"
#import "CMASpecies.h"
#import "CMABait.h"
#import "CMAFishingMethod.h"

@interface CMAJournalTestCase : XCTestCase

@end

@implementation CMAJournalTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (CMAEntry *)sampleEntryOne {
    CMAEntry *result = [CMAEntry onDate:[NSDate date]];
    result.fishSpecies = @"Smallmouth Bass";
    result.notes = @"Slow jig on the bottom";
    result.baitUsed = @"Black twisty tail";
    result.fishLength = [NSNumber numberWithInt:15];
    result.fishWeight = [NSNumber numberWithInt:3];
    result.fishingMethods = [NSSet setWithObjects:@"Shore", @"Casting", nil];
    result.location = [CMALocation withName:@"The Nine Mile River"];
    [result.location addFishingSpot:[CMAFishingSpot withName:@"Beaver Dam"]];
    
    return result;
}

- (CMAEntry *)sampleEntryTwo {
    CMAEntry *result = [CMAEntry onDate:[NSDate dateWithTimeIntervalSinceNow:1200]];
    result.fishSpecies = @"Pike";
    result.notes = @"Small, quick jerks of fly";
    result.baitUsed = @"Minnow Fly (Giant)";
    result.fishLength = [NSNumber numberWithInt:43];
    result.fishWeight = [NSNumber numberWithInt:20];
    result.fishingMethods = [NSSet setWithObjects:@"Boat", @"Fly", nil];
    result.location = [CMALocation withName:@"Wildwood Lake"];
    [result.location addFishingSpot:[CMAFishingSpot withName:@"Dam"]];
    
    return result;
}

- (void)testAddEditRemoveEntry {
    CMAJournal *myJournal = [CMAJournal new];
    CMAEntry *anEntry = [self sampleEntryOne];
    CMAEntry *anotherEntry = [self sampleEntryTwo];
    
    [myJournal addEntry:anEntry];
    XCTAssert([myJournal entryCount] == 1, @"Add entry failed; entry count should be 1");
    
    [myJournal editEntryDated:anEntry.date newProperties:anotherEntry];
    XCTAssert([myJournal entryDated:anotherEntry.date] != nil, @"Edit entry failed; should be an entry with anotherEntry's date");
    
    [myJournal removeEntryDated:anotherEntry.date];
    XCTAssert([myJournal entryCount] == 0, @"Remove entry failed; entry count should be 0");
}

- (void)testAddEditRemoveUserDefine {
    CMAJournal *myJournal = [CMAJournal new];
    
    // adding
    [myJournal addUserDefine:@"Species" objectToAdd:[CMASpecies withName:@"Largemouth Bass"]];
    XCTAssert([[myJournal userDefineNamed:@"Species"] count] == 1);
    
    [myJournal addUserDefine:@"Baits" objectToAdd:[CMABait withName:@"Spoon"]];
    XCTAssert([[myJournal userDefineNamed:@"Baits"] count] == 1);
    
    [myJournal addUserDefine:@"Fishing Methods" objectToAdd:[CMAFishingMethod withName:@"Shore"]];
    XCTAssert([[myJournal userDefineNamed:@"Fishing Methods"] count] == 1);
    
    [myJournal addUserDefine:@"Locations" objectToAdd:[CMALocation withName:@"The Maitland River"]];
    XCTAssert([[myJournal userDefineNamed:@"Locations"] count] == 1);
    
    // editing
    NSMutableString *editStr = [[myJournal userDefineNamed:@"Species"] objectNamed:@"Largemouth Bass"];
    [myJournal editUserDefine:@"Species" objectNamed:@"Largemouth Bass" newProperties:@"Smallmouth Bass"];
    XCTAssert([[[myJournal userDefineNamed:@"Species"] objects] containsObject:editStr]);
    XCTAssert([[myJournal userDefineNamed:@"Species"] objectNamed:@"Smallmouth Bass"] != nil);
    
    editStr = [[myJournal userDefineNamed:@"Baits"] objectNamed:@"Spoon"];
    [myJournal editUserDefine:@"Baits" objectNamed:@"Spoon" newProperties:@"Jig"];
    NSLog(@"editStr: %@", editStr);
    NSLog(@"Baits: %@", [[myJournal userDefineNamed:@"Baits"] objects]);
    XCTAssert([[[myJournal userDefineNamed:@"Baits"] objects] containsObject:editStr]);
    XCTAssert([[myJournal userDefineNamed:@"Baits"] objectNamed:@"Jig"] != nil);
    
    editStr = [[myJournal userDefineNamed:@"Fishing Methods"] objectNamed:@"Shore"];
    [myJournal editUserDefine:@"Fishing Methods" objectNamed:@"Shore" newProperties:@"Casting"];
    XCTAssert([[[myJournal userDefineNamed:@"Fishing Methods"] objects] containsObject:editStr]);
    XCTAssert([[myJournal userDefineNamed:@"Fishing Methods"] objectNamed:@"Casting"] != nil);
    
    CMALocation *editLoc = [[myJournal userDefineNamed:@"Locations"] objectNamed:@"The Maitland River"];
    [myJournal editUserDefine:@"Locations" objectNamed:@"The Maitland River" newProperties:[CMALocation withName:@"The Nine Mile River"]];
    XCTAssert([[[myJournal userDefineNamed:@"Locations"] objects] containsObject:editLoc]);
    XCTAssert([[myJournal userDefineNamed:@"Locations"] objectNamed:@"The Nine Mile River"] != nil);
    
    // removing
    [myJournal removeUserDefine:@"Species" objectNamed:@"Smallmouth Bass"];
    XCTAssert([[myJournal userDefineNamed:@"Species"] count] == 0);
    
    [myJournal removeUserDefine:@"Baits" objectNamed:@"Jig"];
    XCTAssert([[myJournal userDefineNamed:@"Baits"] count] == 0);
    
    [myJournal removeUserDefine:@"Fishing Methods" objectNamed:@"Casting"];
    XCTAssert([[myJournal userDefineNamed:@"Fishing Methods"] count] == 0);
    
    [myJournal removeUserDefine:@"Locations" objectNamed:@"The Nine Mile River"];
    XCTAssert([[myJournal userDefineNamed:@"Locations"] count] == 0);
}

@end
