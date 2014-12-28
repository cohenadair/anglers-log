//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"
#import "CMAAddLocationViewController.h"
#import "CMASelectFishingSpotViewController.h"
#import "CMAConstants.h"

@interface CMASingleLocationViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UILabel *fishingSpotLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishCaughtLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *loadingMapView;

@property (strong, nonatomic)CMAFishingSpot *currentFishingSpot;
@property (nonatomic)BOOL isReadOnly;
@property (nonatomic)BOOL didUnwind;

@end

#define kSectionSelectFishingSpot 0
#define kSectionMap 1

#define kDefaultCellHeight 72

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isReadOnly = self.previousViewID == CMAViewControllerIDSingleEntry;
    
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isReadOnly)
        [self configureForReadOnly];
    
    if (self.fishingSpotFromSingleEntry)
        [self initCurrentFishingSpot:self.fishingSpotFromSingleEntry];
    else if (!self.currentFishingSpot)
        [self initCurrentFishingSpot:[self.location.fishingSpots objectAtIndex:0]];
    
    [self initializeMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureForReadOnly {
    [self.mapView setUserInteractionEnabled:NO];
    [self.tableView setAllowsSelection:NO];
    
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kSectionSelectFishingSpot]] setAccessoryType:UITableViewCellAccessoryNone];
}

#pragma mark - Table View Initializing

- (void)initCurrentFishingSpot:(CMAFishingSpot *)currentFishingSpot {
    self.currentFishingSpot = currentFishingSpot;
    
    if (currentFishingSpot) {
        self.fishingSpotLabel.text = self.currentFishingSpot.name;
        self.coordinateLabel.text = [self.currentFishingSpot locationAsString];
        self.fishCaughtLabel.text = [NSString stringWithFormat:@"%@ Fish Caught", [self.currentFishingSpot.fishCaught stringValue]];
    } else {
        self.fishingSpotLabel.text = @"No Fishing Spot Selected";
        self.coordinateLabel.text = @"Latitude 0.00000, Longitude 0.00000";
        self.fishCaughtLabel.text = @"0 Fish Caught";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionMap)
        return tableView.frame.size.height - kDefaultCellHeight;
    
    return kDefaultCellHeight;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleLocationToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleLocation;
        destination.location = self.location;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleLocationToSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleLocation;
        destination.location = self.location;
    }
}

- (IBAction)unwindToSingleLocation:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromAddLocation"]) {
        CMAAddLocationViewController *source = segue.sourceViewController;
        
        self.location = source.location;
        source.location = nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *source = segue.sourceViewController;
        [self initCurrentFishingSpot:[self.location fishingSpotNamed:source.selectedCellLabelText]];
        
        source.location = nil;
        source.selectedCellLabelText = nil;
    }
    
    [self.mapView setRegion:[self getMapRegion] animated:NO];
    [self setDidUnwind:YES];
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
    for (CMAFishingSpot *spot in self.location.fishingSpots) {
        MKPointAnnotation *p = [MKPointAnnotation new];
        [p setCoordinate:spot.coordinate];
        [p setTitle:spot.name];

        [mapView addAnnotation:p];
    }
}

// Returns the map's region based on the location's fishing spot coordinates.
- (MKCoordinateRegion)getMapRegion {
    return [self.location mapRegion];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self.mapView setHidden:NO];
    [self.loadingMapView setHidden:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self initCurrentFishingSpot:[self.location fishingSpotNamed:view.annotation.title]];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (!self.didUnwind)
        [self initCurrentFishingSpot:nil];
}

- (void)initializeMapView {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self addFishingSpotsToMap:self.mapView];
    
    // select initial annotation
    [self.mapView selectAnnotation:[self annotationWithTitle:self.currentFishingSpot.name] animated:YES];
    [self.mapView setRegion:[self getMapRegion] animated:NO];
}

@end
