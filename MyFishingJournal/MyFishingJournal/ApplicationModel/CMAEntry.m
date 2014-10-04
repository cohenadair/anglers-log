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
        _images = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

// accessing
- (NSInteger)imageCount {
    return [self.images count];
}

- (NSInteger)fishingMethodCount {
    return [self.fishingMethods count];
}

// settings
- (void)addImage: (NSURL *)imageURL {
    [self.images addObject:imageURL];
}

- (void)removeImage: (NSURL *)imageURL {
    [self.images removeObject:(imageURL)];
}

@end
