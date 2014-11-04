//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"
#import "CMAConstants.h"

@interface CMASingleLocationViewController ()

@property (weak, nonatomic)MKMapView *mapView;
@property (nonatomic)BOOL didSetRegion;

@property (strong, nonatomic)NSArray *fishingSpots;

@end

NSInteger const FISHING_SPOT_SECTION = 2;

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didSetRegion = NO;
    [self setFishingSpots:[[self.location fishingSpots] allObjects]];
        
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return tableView.frame.size.width * 0.75;
    }
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == FISHING_SPOT_SECTION)
        return [self.location fishingSpotCount];
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // location name
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationNameCell" forIndexPath:indexPath];
        
        [cell.textLabel setText:[self.location name]];
        return cell;
    }
    
    // map
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell" forIndexPath:indexPath];
        self.mapView = (MKMapView *)[cell viewWithTag:100];
        
        return cell;
    }
    
    // fishing spots
    if (indexPath.section == FISHING_SPOT_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fishingSpotCell" forIndexPath:indexPath];
        
        CMAFishingSpot *fishingSpot = [self.fishingSpots objectAtIndex:indexPath.item];
        [cell.textLabel setText:fishingSpot.name];
        
        NSString *coordinateText = [NSString stringWithFormat:@"Latitude: %f, Longitude: %f", fishingSpot.location.coordinate.latitude, fishingSpot.location.coordinate.longitude];
        [cell.detailTextLabel setText:coordinateText];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unwind to Add Entry view after selecting a fishing spot
    if (indexPath.section == FISHING_SPOT_SECTION && self.isSelectingForAddEntry) {
        self.addEntryLabelText = [NSString stringWithFormat:@"%@%@%@", [self.location name], TOKEN_LOCATION, [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromSingleLocation" sender:self];
    }
    
    if (indexPath.section == FISHING_SPOT_SECTION && !self.isSelectingForAddEntry) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        [self.mapView selectAnnotation:[self annotationWithTitle:cell.textLabel.text] animated:YES];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.mapView selectAnnotation:[self annotationWithTitle:cell.textLabel.text] animated:YES];
}

#pragma mark - Map Initializing

// Returns an MKPointAnnotation with aTitle.
- (MKPointAnnotation *)annotationWithTitle:(NSString *)aTitle {
    for (MKPointAnnotation *annotation in [self.mapView annotations])
        if ([annotation.title isEqualToString:aTitle])
            return annotation;
    
    return nil;
}

// Adds an annotation to the map for each fishing spot in the location.
- (void)addFishingSpotsToMap: (MKMapView *)mapView {
    for (int i = 0; i < [self.fishingSpots count]; i++) {
        MKPointAnnotation *p = [MKPointAnnotation new];
        [p setCoordinate:[self.fishingSpots[i] coordinate]];
        [p setTitle:[self.fishingSpots[i] name]];
        
        [mapView addAnnotation:p];
    }
}

// Returns the map's region based on the location's fishing spot coordinates.
- (MKCoordinateRegion)getMapRegion {
    MKCoordinateRegion result;
    
    CMAFishingSpot *fishingSpot = [[self.location fishingSpots] anyObject];
    
    CLLocationDegrees maxLatitude = fishingSpot.coordinate.latitude;
    CLLocationDegrees minLatitude = fishingSpot.coordinate.latitude;
    CLLocationDegrees maxLongitude = fishingSpot.coordinate.longitude;
    CLLocationDegrees minLongitude = fishingSpot.coordinate.longitude;
    
    for (MKPointAnnotation *p in [self.mapView annotations]) {
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
    
    self.didSetRegion = YES;
    return result;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if ([self.mapView.annotations count] <= 0)
        [self addFishingSpotsToMap:self.mapView];
    
    if (!self.didSetRegion)
        [self.mapView setRegion:[self getMapRegion] animated:NO];
}

@end
