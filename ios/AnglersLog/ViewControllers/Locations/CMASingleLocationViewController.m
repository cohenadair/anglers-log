//
//  CMASingleLocationViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"
#import "CMAAddLocationViewController.h"
#import "CMASelectFishingSpotViewController.h"
#import "CMAConstants.h"
#import "CMAInstagramActivity.h"
#import "CMAStorageManager.h"
#import "CMAAlerts.h"

@interface CMASingleLocationViewController ()

@property (strong, nonatomic)UIBarButtonItem *actionButton;
@property (strong, nonatomic)UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishingSpotLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishCaughtLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

@property (strong, nonatomic)CMAFishingSpot *currentFishingSpot;
@property (strong, nonatomic)NSMutableArray *fishingSpotAnnotations;
@property (nonatomic)BOOL isReadOnly;
@property (nonatomic)BOOL mapDidRender;
@property (nonatomic)BOOL showRenderError;

@end

#define kSectionInfo 0
#define kRowLocationName 0
#define kRowFishingSpot 1

#define kSectionMap 1

#define kLocationNameHeight 44
#define kFishingSpotHeight 72

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationNameLabel.text = self.location.name;
    self.mapDidRender = NO;
    self.showRenderError = YES;
    self.isReadOnly = self.previousViewID == CMAViewControllerIDSingleEntry;
    
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItems = nil;
    
    [self initNavigationBarItems];
    [self initMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isReadOnly)
        [self configureForReadOnly];
    
    if (self.fishingSpotFromSingleEntry)
        [self initCurrentFishingSpot:self.fishingSpotFromSingleEntry];
    else if (!self.currentFishingSpot)
        if ([self.location.fishingSpots count] > 0)
            [self initCurrentFishingSpot:[self.location.fishingSpots objectAtIndex:0]];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UILabel *legal = [self.mapView.subviews objectAtIndex:1];
    legal.center = CGPointMake(legal.center.x, legal.center.y - self.mapTypeControl.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureForReadOnly {
    [self.tableView setAllowsSelection:NO];
    [self disableTapRecognizerForMapView:self.mapView];

    NSIndexPath *fishingSpot =
            [NSIndexPath indexPathForItem:kRowFishingSpot inSection:kSectionInfo];
    [self.tableView cellForRowAtIndexPath:fishingSpot].accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Table View Initializing

- (void)initCurrentFishingSpot:(CMAFishingSpot *)currentFishingSpot {
    self.currentFishingSpot = currentFishingSpot;
    
    if (currentFishingSpot) {
        self.fishingSpotLabel.text = self.currentFishingSpot.name;
        self.coordinateLabel.text = [self.currentFishingSpot locationAsString];
        self.fishCaughtLabel.text = [NSString stringWithFormat:@"%@ Fish Caught", [self.currentFishingSpot.fishCaught stringValue]];
        
        // select map annotation
        [self.mapView selectAnnotation:[self annotationWithTitle:self.currentFishingSpot.name] animated:YES];
        
        // Zoom into the annotation.
        MKCoordinateRegion viewRegion =
                MKCoordinateRegionMakeWithDistance(self.currentFishingSpot.coordinate, 100, 100);
        [self.mapView setRegion:viewRegion animated:YES];
    } else {
        self.fishingSpotLabel.text = @"No Fishing Spot Selected";
        self.coordinateLabel.text = @"Latitude 0.00000, Longitude 0.00000";
        self.fishCaughtLabel.text = @"0 Fish Caught";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionInfo) {
        if (indexPath.row == kRowLocationName) {
            return kLocationNameHeight;
        }
        
        if (indexPath.row == kRowFishingSpot) {
            return kFishingSpotHeight;
        }
    }
    
    if (indexPath.section == kSectionMap) {
        return tableView.frame.size.height - kFishingSpotHeight - kLocationNameHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Events

- (void)clickActionButton {
    [self shareLocation];
}

- (void)clickEditButton {
    [self performSegueWithIdentifier:@"fromSingleLocationToAddLocation" sender:self];
}

- (IBAction)mapTypeControlChange:(UISegmentedControl *)sender {
    [self.mapView setMapType:sender.selectedSegmentIndex];
    [[CMAStorageManager sharedManager] setUserMapType:sender.selectedSegmentIndex];
    self.mapDidRender = NO;
    self.showRenderError = YES;
}

// Shares a screenshot of the current map view canvas.
- (void)shareLocation {
    NSMutableArray *shareItems = [NSMutableArray array];
    
    // create UIImage of self.mapView
    CMAFishingSpot *tempFishingSpot = self.currentFishingSpot;
    if ([[self.mapView selectedAnnotations] count] > 0)
        [self.mapView deselectAnnotation:[[self.mapView selectedAnnotations] objectAtIndex:0] animated:NO];
    
    UIGraphicsBeginImageContextWithOptions(self.mapView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.mapView drawViewHierarchyInRect:self.mapView.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self initCurrentFishingSpot:tempFishingSpot];
    
    // initialize share options
    [shareItems addObject:image];
    [shareItems addObject:[NSString stringWithFormat:@"Location: %@", self.location.name]];
    [shareItems addObject:SHARE_MESSAGE];
    
    CMAInstagramActivity *instagramActivity = [CMAInstagramActivity new];
    [instagramActivity setPresentView:self.view];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:@[instagramActivity]];
    activityController.popoverPresentationController.sourceView = self.view;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeAddToReadingList];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)initNavigationBarItems {
    self.actionButton =
        [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                    target:self
                                                    action:@selector(clickActionButton)];
    if (!self.isReadOnly) {
        self.editButton =
            [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                        target:self
                                                        action:@selector(clickEditButton)];
        self.navigationItem.rightBarButtonItems = @[self.editButton, self.actionButton];
    } else
        self.navigationItem.rightBarButtonItem = self.actionButton;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleLocationToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleLocation;
        destination.location = self.location;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleLocationToSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *destination = segue.destinationViewController;
        destination.previousViewID = CMAViewControllerIDSingleLocation;
        destination.location = self.location;
    }
}

- (IBAction)unwindToSingleLocation:(UIStoryboardSegue *)segue {
    // reset map annotations in case fishing spots were changed
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self addFishingSpotsToMap:self.mapView];
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromAddLocation"]) {
        CMAAddLocationViewController *source = segue.sourceViewController;
        
        self.location = source.location;
        self.locationNameLabel.text = self.location.name;
        source.location = nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *source = segue.sourceViewController;
        [self initCurrentFishingSpot:[self.location fishingSpotNamed:source.selectedCellLabelText]];
        
        source.location = nil;
        source.selectedCellLabelText = nil;
    }
}

#pragma mark - Map Initializing

- (void)initMapView {
    [self.mapTypeControl.layer setCornerRadius:5.0f];
    [self.mapTypeControl setSelectedSegmentIndex:[[CMAStorageManager sharedManager] getUserMapType]];
    [self.mapView setMapType:self.mapTypeControl.selectedSegmentIndex];
    [self.mapView setLayoutMargins:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    [self.mapTypeControl.superview bringSubviewToFront:self.mapTypeControl];
    
    [self addFishingSpotsToMap:self.mapView];
    [self setMapRegion];
}

// Completely disables the default UITapGestureRecogizer in mapView.
- (void)disableTapRecognizerForMapView:(MKMapView *)mapView {
    if ([self.mapView.subviews count] <= 0)
        return;
    
    NSArray *a = [[self.mapView.subviews objectAtIndex:0] gestureRecognizers];
    
    for (id gesture in a)
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            [gesture setEnabled:NO];
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
    self.fishingSpotAnnotations = [NSMutableArray new];
    
    for (CMAFishingSpot *spot in self.location.fishingSpots) {
        MKPointAnnotation *p = [MKPointAnnotation new];
        [p setCoordinate:spot.coordinate];
        [p setTitle:spot.name];

        [self.fishingSpotAnnotations addObject:p];
        [mapView addAnnotation:p];
    }
    
    [self setMapRegion];
}

- (void)setMapRegion {
    [self.mapView showAnnotations:self.fishingSpotAnnotations animated:NO];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    for (id<MKAnnotation> a in mapView.annotations) {
        MKAnnotationView *v = [mapView viewForAnnotation:a];
        [v setEnabled:!self.isReadOnly];
    }
    
    self.mapDidRender = YES;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.isReadOnly)
        return;
    
    [self initCurrentFishingSpot:[self.location fishingSpotNamed:view.annotation.title]];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (self.isReadOnly)
        return;
    
    if ([[mapView selectedAnnotations] count] == 0)
        [self initCurrentFishingSpot:nil];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"Failed to load map: %@.", error.localizedDescription);
    
    if (!self.mapDidRender && self.showRenderError) {
        [CMAAlerts errorAlert:@"Failed to render map. Please try again later, zoom out, or select a different map type." presentationViewController:self];
        self.showRenderError = NO;
    }
}

@end
