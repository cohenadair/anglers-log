//
//  CMAJournalStats.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"
#import "CMASpeciesStats.h"

@interface CMAJournalStats : NSObject

@property (strong, nonatomic)CMAJournal *journal;
@property (strong, nonatomic)NSArray *speciesCaughtStats;
@property (nonatomic)NSInteger totalFishCaught;
@property (nonatomic)NSInteger mostCaughtSpeciesIndex; // index in self.speciesCaughtStats

+ (CMAJournalStats *)withJournal: (CMAJournal *)aJournal;
- (id)initWithJournal: (CMAJournal *)aJournal;

- (CMASpeciesStats *)speciesStatsAtIndex: (NSInteger)anIndex;
- (NSInteger)speciesCaughtStatsIndexForName: (NSString *)aName;
- (NSInteger)speciesCaughtStatsCount;

- (NSDate *)earliestEntryDate;

@end
