//
//  CMAUserLocations.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMALocation.h"

@interface CMAUserLocations : CMAUserDefine

// instance creation
+ (CMAUserLocations *)withName: (NSString *)aName;

// initializing
- (CMAUserLocations *)initWithName: (NSString *)aName;

// setting
- (void)editLocation: (CMALocation *)aLocation newLocation: (CMALocation *)aNewLocation;

// accessing
- (CMALocation *)locationNamed: (NSString *)aName;

@end
