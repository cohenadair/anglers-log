//
//  CMASpeciesStats.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/24/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMASpeciesStats : NSObject

@property (strong, nonatomic)NSString *name;
@property (nonatomic)NSInteger numberCaught;
@property (nonatomic)NSInteger weightCaught;
@property (nonatomic)NSInteger percentOfTotalCaught;
@property (nonatomic)NSInteger percentOfTotalWeight;

@end
