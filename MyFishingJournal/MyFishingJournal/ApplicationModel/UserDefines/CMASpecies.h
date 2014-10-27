//
//  CMASpecies.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMASpecies : NSObject

// instance creation
+ (CMASpecies *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// editing
- (void)edit: (NSString *)aNewSpecies;

@property (strong, nonatomic)NSString *name;

@end
