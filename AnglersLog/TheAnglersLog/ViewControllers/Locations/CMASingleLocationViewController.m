//
//  CMASingleLocationViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMASingleLocationViewController.h"
#import "CMAAddLocationViewController.h"
#import "CMASelectFishingSpotViewController.h"
#import "CMAConstants.h"
#import "CMAInstagramActivity.h"
#import "CMAAdBanner.h"
#import "CMAStorageManager.h"

@interface CMASingleLocationViewController ()

@property (strong, nonatomic)UIBarButtonItem *actionButton;
@property (strong, nonatomic)UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *fishingSpotLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fishCaughtLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *loadingMapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

@property (strong, nonatomic)CMAAdBanner *adBanner;
@property (nonatomic)BOOL bannerIsVisible;

@property (strong, nonatomic)CMAFishingSpot *currentFishingSpot;
@property (nonatomic)BOOL isReadOnly;

@end

#define kSectionSelectFishingSpot 0
#define kSectionMap 1

#define kDefaultCellHeight 72
#define kBannerHeight 50

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isReadOnly = self.previousViewID == CMAViewControllerIDSingleEntry;
    
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItems = nil;
    else
        [self initNavigationBarItems];
    
    [self initMapView];
    [self initAdBanner];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isReadOnly)
        [self configureForReadOnly];
    
    if (self.fishingSpotFromSingleEntry)
        [self initCurrentFishingSpot:self.fishingSpotFromSingleEntry];
    else if (!self.currentFishingSpot)
        [self initCurrentFishingSpot:[self.location.fishingSpots objectAtIndex:0]];
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
    
    [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kSectionSelectFishingSpot]] setAccessoryType:UITableViewCellAccessoryNone];
}

#pragma mark - Ad Banner Initializing

- (void)initAdBanner {
    // the height of the view excluding the navigation bar and status bar
    CGFloat y = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect f = CGRectMake(0, y, self.view.frame.size.width, kBannerHeight);
    
    self.adBanner = [CMAAdBanner withFrame:f delegate:self superView:self.view];
    self.adBanner.bannerIsOnBottom = YES;
    self.adBanner.showTime = 0.25;
}

- (void)hideAdBanner {
    __block typeof(self) blockSelf = self;
    
    [self.adBanner hideWithCompletion:^(void) {
        blockSelf.bannerIsVisible = blockSelf.adBanner.bannerIsVisible;
        // so map cell's height is reset
        [blockSelf.tableView beginUpdates];
        [blockSelf.tableView endUpdates];
    }];
}

- (void)showAdBanner {
    __block typeof(self) blockSelf = self;
    
    [self.adBanner showWithCompletion:^(void) {
        blockSelf.bannerIsVisible = blockSelf.adBanner.bannerIsVisible;
        // so map cell's height is reset
        [blockSelf.tableView beginUpdates];
        [blockSelf.tableView endUpdates];
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self showAdBanner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self hideAdBanner];
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
    } else {
        self.fishingSpotLabel.text = @"No Fishing Spot Selected";
        self.coordinateLabel.text = @"Latitude 0.00000, Longitude 0.00000";
        self.fishCaughtLabel.text = @"0 Fish Caught";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionMap)
        return tableView.frame.size.height - kDefaultCellHeight - (self.bannerIsVisible * kBannerHeight);
    
    return kDefaultCellHeight;
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
}

// Shares a screenshot of the current map view canvas.
- (void)shareLocation {
    NSMutableArray *shareItems = [NSMutableArray array];
    
    // create UIImage of self.mapView
    CMAFishingSpot *tempFishingSpot = self.currentFishingSpot;
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
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickActionButton)];
    self.editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(clickEditButton)];
    
    self.navigationItem.rightBarButtonItems = @[self.editButton, self.actionButton];
}

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
    // reset map annotations in case fishing spots were changed
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self addFishingSpotsToMap:self.mapView];
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromAddLocation"]) {
        CMAAddLocationViewController *source = segue.sourceViewController;
        
        self.location = source.location;
        self.navigationItem.title = self.location.name;
        source.location = nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToSingleLocationFromSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *source = segue.sourceViewController;
        [self initCurrentFishingSpot:[self.location fishingSpotNamed:source.selectedCellLabelText]];
        
        source.location = nil;
        source.selectedCellLabelText = nil;
    }
    
    [self setMapRegion];
}

#pragma mark - Map Initializing

- (void)initMapView {
    [self.mapTypeControl.layer setCornerRadius:5.0f];
    [self.mapTypeControl setSelectedSegmentIndex:[[CMAStorageManager sharedManager] getUserMapType]];
    [self.mapView setAlpha:0.0];
    [self.mapView setMapType:self.mapTypeControl.selectedSegmentIndex];
    [self.mapTypeControl setAlpha:0.0];
    [self.loadingMapView setAlpha:1.0];
    
    [self.mapTypeControl.superview bringSubviewToFront:self.mapTypeControl];
    
    [self addFishingSpotsToMap:self.mapView];
    [self setMapRegion];
}

- (void)showMapView {
    [UIView animateWithDuration:0.3 animations:^() {
        [self.mapView setAlpha:1.0];
        [self.mapTypeControl setAlpha:0.85];
        [self.loadingMapView setAlpha:0.0];
    }];
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

        [mapView addAnnotation:p];
    }
}

- (void)setMapRegion {
    [self.mapView setRegion:[self.location mapRegion] animated:NO];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self showMapView];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.isReadOnly)
        return;
    
    [self initCurrentFishingSpot:[self.location fishingSpotNamed:view.annotation.title]];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([[mapView selectedAnnotations] count] == 0)
        [self initCurrentFishingSpot:nil];
}

@end
