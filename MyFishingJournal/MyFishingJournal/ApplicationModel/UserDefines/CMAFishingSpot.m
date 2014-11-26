//
//  CMAFishingSpot.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingSpot.h"

@implementation CMAFishingSpot

#pragma mark - Instance Creation

+ (CMAFishingSpot *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = [NSMutableString stringWithString:[aName capitalizedString]];
        _location = [CLLocation new];
    }
    
    return self;
}

- (id)init {
    if (self = [super init]) {
        _name = [NSMutableString string];
        _location = [CLLocation new];
    }
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMAFishingSpotName"];
        _location = [aDecoder decodeObjectForKey:@"CMAFishingSpotLocation"];
        _fishCaught = [aDecoder decodeObjectForKey:@"CMAFishingSpotFishCaught"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAFishingSpotName"];
    [aCoder encodeObject:self.location forKey:@"CMAFishingSpotLocation"];
    [aCoder encodeObject:self.fishCaught forKey:@"CMAFishingSpotFishCaught"];
}

#pragma mark - Editing

- (void)setName:(NSMutableString *)name {
    _name = [[name capitalizedString] mutableCopy];
}

- (void)setCoordinates: (CLLocationCoordinate2D)coordinates {
    self.location = [self.location initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
}

// updates self's properties with aNewFishinSpot's attributes
- (void)edit: (CMAFishingSpot *)aNewFishingSpot {
    self.name = [[aNewFishingSpot.name capitalizedString] mutableCopy];
    self.location = aNewFishingSpot.location;
}

- (void)incFishCaught: (NSInteger)incBy {
    NSInteger count = [self.fishCaught integerValue];
    count += incBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

- (void)decFishCaught: (NSInteger)decBy {
    NSInteger count = [self.fishCaught integerValue];
    count -= decBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

#pragma mark - Accessing

// returns the coordinates of the location
- (CLLocationCoordinate2D)coordinate {
    return [self.location coordinate];
}

@end
