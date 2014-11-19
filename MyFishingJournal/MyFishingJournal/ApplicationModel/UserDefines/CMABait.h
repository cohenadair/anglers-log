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
@property (strong, nonatomic)NSString *baitDescription;
@property (strong, nonatomic)UIImage *image;

// instance creation
+ (CMABait *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// archiving
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// editing
- (void)edit: (CMABait *)aNewBait;
- (CMABait *)copy;

@end
