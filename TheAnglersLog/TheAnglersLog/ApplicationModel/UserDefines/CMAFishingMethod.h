//
//  CMAFishingMethod.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMAFishingMethod : CMAUserDefineObject </*NSCoding, */CMAUserDefineProtocol>

// initialization
- (CMAFishingMethod *)initWithName:(NSString *)aName;
- (void)validateProperties;

// archiving
//- (id)initWithCoder:(NSCoder *)aDecoder;
//- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMAFishingMethod *)aNewFishingMethod;

@end
