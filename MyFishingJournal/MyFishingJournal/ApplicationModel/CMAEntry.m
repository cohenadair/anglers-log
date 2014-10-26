//
//  CMAEntry.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntry.h"

@implementation CMAEntry

#pragma mark - Instance Creation

+ (CMAEntry *)onDate: (NSDate *)aDate {
    return [[self alloc] initWithDate:aDate];
}

#pragma mark - Initialization

- (id)initWithDate: (NSDate *)aDate {
    if (self = [super init]) {
        _date = aDate;
        _images = [NSMutableSet set];
    }
    
    return self;
}

#pragma mark - Accessing

- (NSInteger)imageCount {
    return [self.images count];
}

- (NSInteger)fishingMethodCount {
    return [self.fishingMethods count];
}

#pragma mark - Editing

- (void)addImage: (UIImage *)anImage {
    [self.images addObject:anImage];
}

- (void)removeImage: (UIImage *)anImage {
    [self.images removeObject:(anImage)];
}

@end
