//
//  CMASpecies.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASpecies.h"

@implementation CMASpecies

#pragma mark - Instance Creation

+ (CMASpecies *)withName: (NSString *)aName {
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
        _name = [aDecoder decodeObjectForKey:@"CMASpeciesName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMASpeciesName"];
}

#pragma mark - Editing

- (void)edit: (CMASpecies *)aNewSpecies {
    [self setName:[aNewSpecies.name capitalizedString]];
}

@end
