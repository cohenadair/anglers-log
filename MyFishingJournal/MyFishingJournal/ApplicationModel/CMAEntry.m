//
//  CMAEntry.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"

@implementation CMAEntry

// instance creation
+ (CMAEntry *)onDate: (NSDate *)aDate {
    return [[self alloc] initWithDate:aDate];
}

// initializing
- (id)initWithDate: (NSDate *)aDate {
    if (self = [super init]) {
        _entryDate = aDate;
        _images = [NSMutableSet setWithCapacity:0];
    }
    
    return self;
}

- (NSInteger)imageCount {
    return [self.images count];
}

- (NSInteger)fishingMethodCount {
    return [self.fishingMethods count];
}

- (void)addImage: (NSURL *)imageURL {
    [self.images addObject:imageURL];
}

- (void)removeImage: (NSURL *)imageURL {
    [self.images removeObject:(imageURL)];
}

@end
