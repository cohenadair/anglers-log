//
//  CMAUserStrings.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"

@interface CMAUserStrings : CMAUserDefine

// instance creation
+ (CMAUserStrings *)withName: (NSString *)aName;

// initializing
- (CMAUserStrings *)initWithName: (NSString *)aName;

// setting
- (void)editString: (NSMutableString *)aString newString: (NSString *)aNewString;

// accessing
- (NSMutableString *)stringNamed: (NSString *)aName;

@end
