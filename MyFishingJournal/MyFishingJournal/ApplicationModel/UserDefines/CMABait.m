//
//  CMABait.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMABait.h"

@implementation CMABait

#pragma mark - Instance Creation

+ (CMABait *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
    }
    
    return self;
}

#pragma mark - Editing

- (void)edit: (CMABait *)aNewBait {
    [self setName:aNewBait.name];
}

@end
