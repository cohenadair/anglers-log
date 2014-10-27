//
//  CMABait.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMABait : NSObject

// instance creation
+ (CMABait *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// editing
- (void)edit: (NSString *)aNewBait;

@property (strong, nonatomic)NSString *name;

@end
