//
//  CMAFishingSpot.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingSpot.h"
#import "CMAUtilities.h"
#import "CMAJSONWriter.h"

@implementation CMAFishingSpot

@dynamic myLocation;
@dynamic location;
@dynamic fishCaught;

#pragma mark - Initialization

- (CMAFishingSpot *)initWithName:(NSString *)aName {
    self.name = [NSMutableString stringWithString:[CMAUtilities capitalizedString: aName]];
    self.location = [CLLocation new];
    self.fishCaught = [NSNumber numberWithInteger:0];
    self.entries = [NSMutableSet set];
    
    return self;
}

- (CMAFishingSpot *)initWithFishingSpot:(CMAFishingSpot *)aSpot {
    self.name = [aSpot.name mutableCopy];
    self.location = [CLLocation new];
    [self setCoordinates:aSpot.location.coordinate];
    self.fishCaught = aSpot.fishCaught;
    self.entries = aSpot.entries;
    
    return self;
}

#pragma mark - Editing

- (void)setCoordinates: (CLLocationCoordinate2D)coordinates {
    self.location = [self.location initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
}

// updates self's properties with aNewFishinSpot's attributes
- (void)edit: (CMAFishingSpot *)aNewFishingSpot {
    self.name = [[CMAUtilities capitalizedString:aNewFishingSpot.name] mutableCopy];
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

- (NSString *)locationAsString {
    return [NSString stringWithFormat:@"Latitude %f, Longitude %f", self.location.coordinate.latitude, self.location.coordinate.longitude];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitFishingSpot:self];
}

@end
