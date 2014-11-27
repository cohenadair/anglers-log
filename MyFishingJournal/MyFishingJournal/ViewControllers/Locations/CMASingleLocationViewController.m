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

@property (weak, nonatomic)IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UILabel *fishingSpotLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *loadingMapView;

@property (nonatomic)BOOL didSetRegion;
@property (nonatomic)BOOL isReadOnly;

@end

#define kSectionSelectFishingSpot 0
#define kSectionMap 1

#define kDefaultCellHeight 44

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didSetRegion = NO;
    self.isReadOnly = self.previousViewID == CMAViewControllerID_SingleEntry;
    
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isReadOnly)
        [self configureForReadOnly];
    
    [self initializeMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureForReadOnly {
    [self.fishingSpotLabel setText:self.fishingSpotFromSingleEntry.name];
    [self.mapView setUserInteractionEnabled:NO];
    [self.tableView setAllowsSelection:NO];
    
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kSectionSelectFishingSpot]] setAccessoryType:UITableViewCellAccessoryNone];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionMap)
        return tableView.frame.size.height - kDefaultCellHeight;
    
    return kDefaultCellHeight;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleLocationToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_SingleLocation;
        destination.location = self.location;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleLocationToSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_SingleLocation;
        destination.location = self.location;
    }
}

- (IBAction)unwindToSingleLocation:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromAddLocation"]) {
        CMAAddLocationViewController *source = segue.sourceViewController;
        
        self.location = source.location;
        [self mapViewReset];
        
        source.location = nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *source = segue.sourceViewController;
        
        [self.fishingSpotLabel setText:source.selectedCellLabelText];
        [self.mapView selectAnnotation:[self annotationWithTitle:source.selectedCellLabelText] animated:YES];
        
        source.location = nil;
        source.selectedCellLabelText = nil;
    }
}

#pragma mark - Map Initializing

- (void)selectInitialAnnotation {
    
}

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
    for (CMAFishingSpot *spot in self.location.fishingSpots) {
        MKPointAnnotation *p = [MKPointAnnotation new];
        [p setCoordinate:spot.coordinate];
        [p setTitle:spot.name];
        [p setSubtitle:[NSString stringWithFormat:@"%@ Fish Caught", [spot.fishCaught stringValue]]];
        
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
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.fishingSpotLabel.text = view.annotation.title;
}

- (void)initializeMapView {
    if ([self.mapView.annotations count] <= 0)
        [self addFishingSpotsToMap:self.mapView];
    
    if (!self.didSetRegion)
        [self.mapView setRegion:[self getMapRegion] animated:NO];
    
    // select initial annotation
    if (self.fishingSpotFromSingleEntry)
        [self.mapView selectAnnotation:[self annotationWithTitle:self.fishingSpotFromSingleEntry.name] animated:YES];
    else
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
}

@end
