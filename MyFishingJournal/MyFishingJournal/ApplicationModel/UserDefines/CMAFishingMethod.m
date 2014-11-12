//
//  CMAFishingMethod.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingMethod.h"

@implementation CMAFishingMethod

#pragma mark - Instance Creation

+ (CMAFishingMethod *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
    }
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMAFishingMethodName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAFishingMethodName"];
}

#pragma mark - Editing

- (void)edit: (CMAFishingMethod *)aNewFishingMethod {
    [self setName:[aNewFishingMethod.name capitalizedString]];
}

@end
