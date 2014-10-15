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

// accessing
- (CMALocation *)locationNamed: (NSString *)aName;

@end
