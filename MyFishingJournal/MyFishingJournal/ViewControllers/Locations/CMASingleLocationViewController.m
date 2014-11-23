//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"
#import "CMAAddLocationViewController.h"
#import "CMAConstants.h"

@interface CMASingleLocationViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic)MKMapView *mapView;
@property (weak, nonatomic)UIView *loadingMapView;

@property (nonatomic)BOOL didSetRegion;
@property (nonatomic)BOOL isReadOnly;

@end

NSInteger const SECTION_MAP = 0;
NSInteger const SECTION_FISHING_SPOT = 1;

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didSetRegion = NO;
    self.isReadOnly = self.previousViewID == CMAViewControllerID_SingleEntry;
    
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initializeMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureForReadOnly {
    [self.mapView selectAnnotation:[self annotationWithTitle:self.fishingSpotFromSingleEntry.name] animated:YES];
    [self.mapView setUserInteractionEnabled:NO];
    
    [self.tableView selectRowAtIndexPath:self.selectedFishingSpotFromSingleEntry animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.tableView setAllowsSelection:NO];
}

#pragma mark - Table View Initializing

- (NSIndexPath *)indexPathForLabelText:(NSString *)textLabelText {
    NSIndexPath *result = nil;
    
    for (int i = 0; i < [self.tableView numberOfRowsInSection:SECTION_FISHING_SPOT]; i++) {
        result = [NSIndexPath indexPathForItem:i inSection:SECTION_FISHING_SPOT];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:result];
        
        if ([cell.textLabel.text isEqualToString:textLabelText])
            return result;
    }
    
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return tableView.frame.size.width * 0.75;
    }
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_MAP)
        return 1;
    
    if (section == SECTION_FISHING_SPOT)
        return [self.location fishingSpotCount];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // map
    if (indexPath.section == SECTION_MAP) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell" forIndexPath:indexPath];
        self.mapView = (MKMapView *)[cell viewWithTag:100];
        self.loadingMapView = (UIView *)[cell viewWithTag:200];
        
        return cell;
    }
    
    // fishing spots
    if (indexPath.section == SECTION_FISHING_SPOT) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fishingSpotCell" forIndexPath:indexPath];
        
        CMAFishingSpot *fishingSpot = [self.location.fishingSpots objectAtIndex:indexPath.item];
        [cell.textLabel setText:fishingSpot.name];
        
        if (self.previousViewID == CMAViewControllerID_SingleEntry && [fishingSpot.name isEqualToString:self.fishingSpotFromSingleEntry.name])
            self.selectedFishingSpotFromSingleEntry = indexPath;
        
        NSString *coordinateText = [NSString stringWithFormat:@"Latitude: %f, Longitude: %f", fishingSpot.location.coordinate.latitude, fishingSpot.location.coordinate.longitude];
        [cell.detailTextLabel setText:coordinateText];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unwind to Add Entry view after selecting a fishing spot
    if (indexPath.section == SECTION_FISHING_SPOT && self.isSelectingForAddEntry) {
        self.addEntryLabelText = [NSString stringWithFormat:@"%@%@%@", [self.location name], TOKEN_LOCATION, [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromSingleLocation" sender:self];
    }
    
    if (indexPath.section == SECTION_FISHING_SPOT && !self.isSelectingForAddEntry) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        [self.mapView selectAnnotation:[self annotationWithTitle:cell.textLabel.text] animated:YES];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!(self.previousViewID == CMAViewControllerID_SingleEntry)) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.mapView selectAnnotation:[self annotationWithTitle:cell.textLabel.text] animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleLocationToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_SingleLocation;
        destination.location = self.location;
    }
}

- (IBAction)unwindToSingleLocation:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromAddLocation"]) {
        CMAAddLocationViewController *source = segue.sourceViewController;
        self.location = source.location;
        source.location = nil;
        [self.tableView reloadData];
        [self mapViewReset];
    }
}

#pragma mark - Map Initializing

// Used to reset the map after editing the location.
- (void)mapViewReset {
    [self.mapView removeAnnotations:[self.mapView annotations]]; // remove old annotations
    [self addFishingSpotsToMap:self.mapView];                    // add new annotations
    [self.mapView setRegion:[self getMapRegion] animated:NO];    // reset map's region
}

// Returns an MKPointAnnotation with aTitle.
- (MKPointAnnotation *)annotationWithTitle:(NSString *)aTitle {
    for (MKPointAnnotation *annotation in [self.mapView annotations])
        if ([annotation.title isEqualToString:aTitle])
            return annotation;
    
    return nil;
}

// Adds an annotation to the map for each fishing spot in the location.
- (void)addFishingSpotsToMap: (MKMapView *)mapView {
    for (int i = 0; i < [self.location.fishingSpots count]; i++) {
        MKPointAnnotation *p = [MKPointAnnotation new];
        [p setCoordinate:[self.location.fishingSpots[i] coordinate]];
        [p setTitle:[self.location.fishingSpots[i] name]];
        
        [mapView addAnnotation:p];
    }
}

// Returns the map's region based on the location's fishing spot coordinates.
- (MKCoordinateRegion)getMapRegion {
    self.didSetRegion = YES;
    return [self.location mapRegion];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self.mapView setHidden:NO];
    [self.loadingMapView setHidden:YES];
    
    if (self.isReadOnly)
        [self configureForReadOnly];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self.tableView selectRowAtIndexPath:[self indexPathForLabelText:view.annotation.title] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)initializeMapView {
    if ([self.mapView.annotations count] <= 0)
        [self addFishingSpotsToMap:self.mapView];
    
    if (!self.didSetRegion)
        [self.mapView setRegion:[self getMapRegion] animated:NO];
}

@end
