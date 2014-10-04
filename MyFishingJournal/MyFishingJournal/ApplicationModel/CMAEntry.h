//
//  CMAEntry.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMALocation.h"

@interface CMAEntry : NSObject

@property (strong, nonatomic)NSDate *entryDate;
@property (strong, nonatomic)NSString *fishSpecies;
@property (strong, nonatomic)NSString *notes;
@property (strong, nonatomic)NSString *baitUsed;
@property (strong, nonatomic)NSString *trip;

@property (nonatomic)NSInteger fishLength;
@property (nonatomic)NSInteger fishWeight;

@property (strong, nonatomic)NSMutableArray *images;
@property (strong, nonatomic)NSArray *fishingMethods;

@property (strong, nonatomic)CMALocation *location;

// instance creation
+ (CMAEntry *)onDate: (NSDate *)aDate;

// initializing
- (id)initWithDate: (NSDate *)aDate;

// accessing
- (NSInteger)imageCount;
- (NSInteger)fishingMethodCount;

// setting
- (void)addImage: (NSURL *)imageURL;
- (void)removeImage: (NSURL *)imageURL;

@end
