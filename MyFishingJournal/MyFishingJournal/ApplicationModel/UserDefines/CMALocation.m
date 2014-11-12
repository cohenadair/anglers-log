//
//  CMALocation.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMALocation.h"

@implementation CMALocation

#pragma mark - Instance Creation

+ (CMALocation *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = [NSMutableString stringWithString:[aName capitalizedString]];
        _fishingSpots = [NSMutableArray array];
    }
    
    return self;
}

- (id)init {
    if (self = [super init]) {
        _name = [NSMutableString string];
        _fishingSpots = [NSMutableArray array];
    }
    
    return self;
}

- (void)setName:(NSMutableString *)name {
    _name = [[name capitalizedString] mutableCopy];
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMALocationName"];
        _fishingSpots = [aDecoder decodeObjectForKey:@"CMALocationFishingSpots"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMALocationName"];
    [aCoder encodeObject:self.fishingSpots forKey:@"CMALocationFishingSpots"];
}

#pragma mark - Editing

- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot {
    if ([self fishingSpotNamed:aFishingSpot.name] != nil) {
        NSLog(@"Fishing spot with name %@ already exists", aFishingSpot.name);
        return NO;
    }

    [self.fishingSpots addObject:aFishingSpot];
    return YES;
}

- (void)removeFishingSpotNamed: (NSString *)aName {
    [self.fishingSpots removeObject:[self fishingSpotNamed:aName]];
}

- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot; {
    [[self fishingSpotNamed:aName] edit:aNewFishingSpot];
}

// updates self's properties with aNewLocation's properties
- (void)edit: (CMALocation *)aNewLocation {
    [self.name setString:aNewLocation.name];
    
    // no need to mess with fishing spots since there are separate methods for that
}

#pragma mark - Accessing

- (NSInteger)fishingSpotCount {
    return [self.fishingSpots count];
}

// returns nil if a fishing spot with aName does not exist, otherwise returns a pointer to the existing fishing spot
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName {
    for (CMAFishingSpot *spot in self.fishingSpots)
        if ([spot.name isEqualToString:aName])
            return spot;
    
    return nil;
}

// Returns a MKCoordinateRegion for this location. Used for display on a MKMapView.
- (MKCoordinateRegion)mapRegion {
    MKCoordinateRegion result;

    if ([self fishingSpotCount] > 0) {
        CMAFishingSpot *fishingSpot = [[self fishingSpots] objectAtIndex:0];
        
        CLLocationDegrees maxLatitude = fishingSpot.coordinate.latitude;
        CLLocationDegrees minLatitude = fishingSpot.coordinate.latitude;
        CLLocationDegrees maxLongitude = fishingSpot.coordinate.longitude;
        CLLocationDegrees minLongitude = fishingSpot.coordinate.longitude;
        
        for (CMAFishingSpot *p in [self fishingSpots]) {
            if (p.coordinate.latitude < minLatitude)
                minLatitude = p.coordinate.latitude;
            
            if (p.coordinate.latitude > maxLatitude)
                maxLatitude = p.coordinate.latitude;
            
            if (p.coordinate.longitude < minLongitude)
                minLongitude = p.coordinate.longitude;
            
            if (p.coordinate.longitude > maxLongitude)
                maxLongitude = p.coordinate.longitude;
        }
        
        result.center.latitude = minLatitude + ((maxLatitude - minLatitude) / 2);
        result.center.longitude = minLongitude + ((maxLongitude - minLongitude) / 2);
        
        // add some padding to the region
        result.span.latitudeDelta = (maxLatitude - minLatitude) * 3.0;
        result.span.longitudeDelta = (maxLongitude - minLongitude) * 3.0;
    }

    return result;
}

- (CMALocation *)copy {
    CMALocation *result = [CMALocation new];
    
    [result setName:self.name];
    
    for (CMAFishingSpot *f in self.fishingSpots)
        [result addFishingSpot:f];
    
    return result;
}

@end
