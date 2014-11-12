//
//  CMABait.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMABait : NSObject <NSCoding>

@property (strong, nonatomic)NSString *name;

// instance creation
+ (CMABait *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMABait *)aNewBait;

@end
