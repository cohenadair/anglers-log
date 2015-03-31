//
//  CMALocation.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMALocation.h"
#import "CMAConstants.h"
#import "CMAAppDelegate.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"

@implementation CMALocation

@dynamic fishingSpots;

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - Initialization

- (CMALocation *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine {
    self.name = [NSMutableString stringWithString:[aName capitalizedString]];
    self.fishingSpots = [NSMutableOrderedSet orderedSet];
    self.entries = [NSMutableSet set];
    self.userDefine = aUserDefine;
    
    return self;
}

#pragma mark - Editing

- (BOOL)addFishingSpot: (CMAFishingSpot *)aFishingSpot {
    NSLog(@"CMALocation's addFishingSpot should never be called. Setting a CMAFishingSpot's myLocation property automatically adds said fishing spot to the location. This is thanks to Core Data.");
    return NO;
}

- (void)removeFishingSpotNamed: (NSString *)aName {
    CMAFishingSpot *spot = [self fishingSpotNamed:aName];
    
    // remove from core data
    [[CMAStorageManager sharedManager] deleteManagedObject:spot saveContext:YES];
    
    [self.fishingSpots removeObject:spot];
}

- (void)editFishingSpotNamed: (NSString *)aName newProperties: (CMAFishingSpot *)aNewFishingSpot; {
    [[self fishingSpotNamed:aName] edit:aNewFishingSpot];
}

// updates self's properties with aNewLocation's properties
- (void)edit:(CMALocation *)aNewLocation {
    [self setName:[aNewLocation.name capitalizedString]];
    [self setFishingSpots:aNewLocation.fishingSpots];
}

#pragma mark - Accessing

- (NSInteger)fishingSpotCount {
    return [self.fishingSpots count];
}

// returns nil if a fishing spot with aName does not exist, otherwise returns a pointer to the existing fishing spot
- (CMAFishingSpot *)fishingSpotNamed: (NSString *)aName {
    for (CMAFishingSpot *spot in self.fishingSpots)
        if ([spot.name isEqualToString:[CMAUtilities capitalizedString:aName]])
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
        
        // handle really small spans
        if (result.span.latitudeDelta < 0.001220)
            result.span.latitudeDelta = 0.009220;
        
        if (result.span.longitudeDelta < 0.001120)
            result.span.longitudeDelta = 0.009120;
    }

    return result;
}

#pragma mark - Sorting

- (void)sortFishingSpotsByName {
    NSArray *sortedArray = [self.fishingSpots sortedArrayUsingComparator:^NSComparisonResult(CMAFishingSpot *s1, CMAFishingSpot *s2){
        return [s1.name compare:s2.name];
    }];
    
    self.fishingSpots = [NSMutableOrderedSet orderedSetWithArray:sortedArray];
}

@end
