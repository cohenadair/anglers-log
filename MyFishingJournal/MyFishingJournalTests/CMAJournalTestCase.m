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
    result.fishLength = 15;
    result.fishWeight = 3.0;
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
    result.fishLength = 43;
    result.fishWeight = 20;
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
    XCTAssert([myJournal.entries containsObject:anEntry], @"Edit entry failed; anEntry should still exist");
    XCTAssert([myJournal entryDated:anotherEntry.date] != nil, @"Edit entry failed; should be an entry with anotherEntry's date");
    
    [myJournal removeEntryDated:anotherEntry.date];
    XCTAssert([myJournal entryCount] == 0, @"Remove entry failed; entry count should be 0");
}

- (void)testAddEditRemoveUserDefine {
    CMAJournal *myJournal = [CMAJournal new];
    
    // adding
    [myJournal addUserDefine:@"Species" objectToAdd:@"Largemouth Bass"];
    XCTAssert([myJournal.species count] == 1);
    
    [myJournal addUserDefine:@"Baits" objectToAdd:@"Black Twisty Tail"];
    XCTAssert([myJournal.baits count] == 1);
    
    [myJournal addUserDefine:@"Fishing Methods" objectToAdd:@"Shore"];
    XCTAssert([myJournal.fishingMethods count] == 1);
    
    [myJournal addUserDefine:@"Locations" objectToAdd:[CMALocation withName:@"The Maitland River"]];
    XCTAssert([myJournal.locations count] == 1);
    
    // editing
    NSMutableString *editStr = [myJournal.species stringNamed:@"Largemouth Bass"];
    [myJournal editUserDefine:@"Species" objectToEdit:editStr newProperties:@"Smallmouth Bass"];
    XCTAssert([myJournal.species.objects containsObject:editStr]);
    XCTAssert([myJournal.species stringNamed:@"Smallmouth Bass"] != nil);
    
    editStr = [myJournal.baits stringNamed:@"Black Twisty Tail"];
    [myJournal editUserDefine:@"Baits" objectToEdit:editStr newProperties:@"Green Twisty Tail"];
    XCTAssert([myJournal.baits.objects containsObject:editStr]);
    XCTAssert([myJournal.baits stringNamed:@"Green Twisty Tail"] != nil);
    
    editStr = [myJournal.fishingMethods stringNamed:@"Shore"];
    [myJournal editUserDefine:@"Fishing Methods" objectToEdit:editStr newProperties:@"Casting"];
    XCTAssert([myJournal.fishingMethods.objects containsObject:editStr]);
    XCTAssert([myJournal.fishingMethods stringNamed:@"Casting"] != nil);
    
    CMALocation *editLoc = [myJournal.locations locationNamed:@"The Maitland River"];
    [myJournal editUserDefine:@"Locations" objectToEdit:editLoc newProperties:@"The Nine Mile River"];
    XCTAssert([myJournal.locations.objects containsObject:editLoc]);
    XCTAssert([myJournal.locations locationNamed:@"The Nine Mile River"] != nil);
    
    // removing
    [myJournal removeUserDefine:@"Species" objectToRemove:[myJournal.species stringNamed:@"Smallmouth Bass"]];
    XCTAssert([myJournal.species count] == 0);
    
    [myJournal removeUserDefine:@"Baits" objectToRemove:[myJournal.baits stringNamed:@"Green Twisty Tail"]];
    XCTAssert([myJournal.baits count] == 0);
    
    [myJournal removeUserDefine:@"Fishing Methods" objectToRemove:[myJournal.fishingMethods stringNamed:@"Casting"]];
    XCTAssert([myJournal.fishingMethods count] == 0);
    
    [myJournal removeUserDefine:@"Locations" objectToRemove:[myJournal.locations locationNamed:@"The Nine Mile River"]];
    XCTAssert([myJournal.locations count] == 0);
}

@end
