//
//  CMAAddEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAUserDefinesViewController.h"
#import "CMASingleLocationViewController.h"
#import "CMASelectFishingSpotViewController.h"
#import "CMAImagePickerViewController.h"
#import "CMAViewBaitsViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAlerts.h"
#import "CMACameraButton.h"
#import "CMACameraActionSheet.h"
#import "CMARemoveImageActionSheet.h"
#import "CMAWeatherDataView.h"
#import "CMAUtilities.h"
#import "CMAStorageManager.h"
#import "CMAImage.h"

@interface CMAAddEntryViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;

#pragma mark - Date and Time
@property (weak, nonatomic)IBOutlet UILabel *dateTimeDetailLabel;
@property (weak, nonatomic)IBOutlet UIDatePicker *datePicker;

#pragma mark - Photos
@property (weak, nonatomic)IBOutlet UICollectionView *imageCollection;

#pragma mark - Fish Details
@property (weak, nonatomic)IBOutlet UILabel *speciesDetailLabel;
@property (weak, nonatomic)IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic)IBOutlet UITextField *lengthTextField;
@property (weak, nonatomic)IBOutlet UITextField *metricWeightTextField;
@property (weak, nonatomic)IBOutlet UITextField *poundsTextField;
@property (weak, nonatomic)IBOutlet UITextField *ouncesTextField;
@property (weak, nonatomic)IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic)IBOutlet UILabel *weightLabel;
@property (weak, nonatomic)IBOutlet UITableViewCell *metricWeightCell;
@property (weak, nonatomic)IBOutlet UITableViewCell *imperialWeightCell;

#pragma mark - Catch Details
@property (weak, nonatomic)IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *baitUsedDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *methodsDetailLabel;

#pragma mark - Weather Conditions
@property (strong, nonatomic)CMAWeatherDataView *weatherDataView;
@property (strong, nonatomic)CMAWeatherData *weatherData;
@property (weak, nonatomic)IBOutlet UIButton *toggleWeatherButton;
@property (weak, nonatomic)IBOutlet UIActivityIndicatorView *weatherIndicator;
@property (strong, nonatomic)CLLocationManager *locationManager;

#pragma mark - Water Conditions
@property (weak, nonatomic)IBOutlet UILabel *waterClarityLabel;
@property (weak, nonatomic)IBOutlet UITextField *waterDepthTextField;
@property (weak, nonatomic)IBOutlet UITextField *waterTemperatureTextField;
@property (weak, nonatomic)IBOutlet UILabel *waterDepthLabel;
@property (weak, nonatomic)IBOutlet UILabel *waterTemperatureLabel;

#pragma mark - Notes
@property (weak, nonatomic)IBOutlet UITextView *notesTextView;

#pragma mark - Camera
@property (weak, nonatomic)IBOutlet CMACameraButton *cameraImage;
@property (strong, nonatomic)CMACameraActionSheet *cameraActionSheet;
@property (strong, nonatomic)CMARemoveImageActionSheet *removeImageActionSheet;

#pragma mark - Miscellaneous

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)NSIndexPath *indexPathForOptionsCell; // used after an unwind from selecting options
@property (nonatomic)BOOL isEditingDateTime;
@property (nonatomic)BOOL isEditingEntry;
@property (nonatomic)BOOL isWeatherInitialized;

@property (nonatomic)BOOL hasAttachedImages;
@property (nonatomic)NSInteger numberOfImages;
@property (strong, nonatomic)NSIndexPath *deleteImageIndexPath;
@property (strong, nonatomic)NSMutableArray *entryImages;

@end

#define kDateCellSection 0
#define kDateCellRow 0

#define kPhotoCellSection 1

#define kDatePickerHeight 225
#define kDatePickerCellSection 0
#define kDatePickerCellRow 1

#define kImagesCellHeightExpanded 150
#define kImagesCellSection 1

#define kWeatherCellSection 4

#define kFishDetailsSection 2
#define kMetricFishWeightRow 3
#define kImperialFishWeightRow 4

#define kImageViewTag 100
#define kSavePhotoTag 500

NSString *const kNotSelectedString = @"Not Selected";

@implementation CMAAddEntryViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.weatherIndicator setHidden:YES];
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMMM dd, yyyy 'at' h:mm a"];
    
    // set date detail label to the current date and time
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:[NSDate new]]];
    
    // set proper units for length, weight, depth, and temperature
    [self initUnitCells];
    
    [self.imageCollection setAllowsSelection:NO];
    [self.imageCollection setAllowsMultipleSelection:NO];
    
    self.isEditingEntry = self.previousViewID == CMAViewControllerIDSingleEntry;
    self.isEditingDateTime = NO;
    self.hasAttachedImages = NO;
    self.numberOfImages = 0;
    
    // set weather data view (needs to be called before [self initializeTableForEditing], below)
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CMAWeatherDataView" owner:self options:nil];
    self.weatherDataView = (CMAWeatherDataView *)[nib objectAtIndex:0];
    [self.weatherDataView setFrame:CGRectMake(0, 0, 0, kWeatherCellHeightExpanded)];
    [self.weatherDataView setAlpha:0.0];
    
    // if we're editing rather than adding an entry
    if (self.isEditingEntry) {
        [self initializeTableForEditing];
    
        // NO IDEA why this needs to be called here (it's already called in initializeCellsForEditing)
        // After a stupid amount of debugging I couldn't figure this out so this is left here as a temporary solution
        // The species detail label will only when editing an entry that required a new species to be added
        // This only happens with species; no other properties
        // Also, this bug came out of no where (worked one day, and not the next); checked logs but found nothing that would cause this
        if (![self.entry.fishSpecies removedFromUserDefines])
            [self.speciesDetailLabel setText:self.entry.fishSpecies.name];
        else
            [self.speciesDetailLabel setText:kNotSelectedString];
    }
    
    [self.cameraImage myInit:self action:@selector(tapCameraImage)];
    
    // location manager
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    [self initCameraActionSheet];
    [self initRemoveImageActionSheet];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (void)initUnitCells {
    [self.lengthLabel setText:[NSString stringWithFormat:@"Length (%@)", [[self journal] lengthUnitsAsString:NO]]];
    [self.waterDepthLabel setText:[NSString stringWithFormat:@"Depth (%@)", [[self journal] depthUnitsAsString:NO]]];
    [self.waterTemperatureLabel setText:[NSString stringWithFormat:@"Temperature (%@)", [[self journal] temperatureUnitsAsString:NO]]];
    
    if ([[self journal] measurementSystem] == CMAMeasuringSystemTypeImperial)
        [self.metricWeightCell setHidden:YES];
    else
        [self.imperialWeightCell setHidden:YES];
}

- (void)initializeTableForEditing {
    [self initializeCellsForEditing];
    
    self.navigationItem.title = @"Edit Entry";
    self.entryImages = [[self.entry.images array] mutableCopy];
    self.numberOfImages = [self.entryImages count];
    self.hasAttachedImages = (self.numberOfImages > 0);
    
    if (self.entry.weatherData) {
        self.isWeatherInitialized = YES;
        self.weatherData = self.entry.weatherData;
    }
}

- (void)initializeCellsForEditing {
    // date
    [self.datePicker setDate:[self.entry date]];
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:[self.entry date]]];
    
    // pictures
    [self.imageCollection reloadData];
    
    // species
    if (![self.entry.fishSpecies removedFromUserDefines])
        [self.speciesDetailLabel setText:self.entry.fishSpecies.name];
    else
        [self.speciesDetailLabel setText:kNotSelectedString];

    // fish quantity
    if (self.entry.fishQuantity && ([self.entry.fishQuantity integerValue] != -1))
        [self.quantityTextField setText:self.entry.fishQuantity.stringValue];
    
    // fish length
    if (self.entry.fishLength && ([self.entry.fishLength integerValue] != -1))
        [self.lengthTextField setText:self.entry.fishLength.stringValue];
    
    // fish weight
    if (self.entry.fishWeight && ([self.entry.fishWeight integerValue] != -1)) {
        if ([[self journal] measurementSystem] == CMAMeasuringSystemTypeMetric)
            [self.metricWeightTextField setText:self.entry.fishWeight.stringValue];
        else {
            [self.poundsTextField setText:self.entry.fishWeight.stringValue];
            
            if (self.entry.fishOunces)
                [self.ouncesTextField setText:self.entry.fishOunces.stringValue];
            else
                [self.ouncesTextField setText:@"0"];
        }
    }
    
    // bait used
    if (self.entry.baitUsed) {
        if (![self.entry.baitUsed removedFromUserDefines])
            [self.baitUsedDetailLabel setText:self.entry.baitUsed.name];
        else
            [self.baitUsedDetailLabel setText:kNotSelectedString];
    }
    
    // fishing methods
    if ([self.entry.fishingMethods count] > 0)
        [self.methodsDetailLabel setText:[self.entry fishingMethodsAsString]];
    
    // location and fishing spot
    if (self.entry.location) {
        if (![self.entry.location removedFromUserDefines])
            [self.locationDetailLabel setText:[self.entry locationAsString]];
        else
            [self.locationDetailLabel setText:kNotSelectedString];
    }
    
    // weather conditions
    if (self.entry.weatherData) {
        [self setIsWeatherInitialized:YES];
        [self initWeatherDataViewWithData:self.entry.weatherData];
        [self toggleWeatherDataCell];
    }
    
    // water temperature
    if (self.entry.waterTemperature && ([self.entry.waterTemperature integerValue] != -1))
        [self.waterTemperatureTextField setText:self.entry.waterTemperature.stringValue];
    
    // water clarity
    if (self.entry.waterClarity)
        [self.waterClarityLabel setText:self.entry.waterClarity.name];
    else
        [self.speciesDetailLabel setText:kNotSelectedString];
    
    // water depth
    if (self.entry.waterDepth && ([self.entry.waterDepth integerValue] != -1))
        [self.waterDepthTextField setText:self.entry.waterDepth.stringValue];
    
    // notes
    if (self.entry.notes)
        [self.notesTextView setText:self.entry.notes];
}

- (void)toggleDatePickerCellHidden:(UITableView *)aTableView selectedPath:(NSIndexPath *)anIndexPath {
    self.isEditingDateTime = !self.isEditingDateTime;
    
    if (self.isEditingDateTime)
        [UIView animateWithDuration:0.5 animations:^{
            [self.datePicker setAlpha:1.0f];
        }];
    else {
        [UIView animateWithDuration:0.15 animations:^{
            [self.datePicker setAlpha:0.0f];
        }];
        
        [aTableView deselectRowAtIndexPath:anIndexPath animated:NO];
    }
    
    // use begin/endUpdates to animate changes
    [aTableView beginUpdates];
    [aTableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections] - 1)
        return kTableFooterHeight;
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // set height of the date picker cell
    if (indexPath.section == kDatePickerCellSection && indexPath.row == kDatePickerCellRow) {
        if (self.isEditingDateTime)
            return kDatePickerHeight;
        else
            return 0;
    }
    
    // for the images collection cell
    if (indexPath.section == kImagesCellSection) {
        if (self.hasAttachedImages)
            return kImagesCellHeightExpanded;
        else
            return 44;
    }
    
    // if weather data is added
    if (indexPath.section == kWeatherCellSection) {
        if (self.isWeatherInitialized)
            return kWeatherCellHeightExpanded;
        else
            return 44;
    }
    
    // fish weight cell
    if (indexPath.section == kFishDetailsSection) {
        if (indexPath.row == kMetricFishWeightRow && [[self journal] measurementSystem] == CMAMeasuringSystemTypeImperial)
            return 0;
        
        if (indexPath.row == kImperialFishWeightRow && [[self journal] measurementSystem] == CMAMeasuringSystemTypeMetric)
            return 0;
    }
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // weather cell
    if (indexPath.section == kWeatherCellSection) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width - 50, cell.frame.size.height)];
        [bgView addSubview:self.weatherDataView];

        [cell addSubview:bgView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row == 0) ||
        (indexPath.section == kFishDetailsSection && indexPath.row == kMetricFishWeightRow && [[self journal] measurementSystem] == CMAMeasuringSystemTypeMetric)) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setPreservesSuperviewLayoutMargins:NO];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // show the date picker cell when the date display cell is selected
    if (indexPath.section == kDateCellSection && indexPath.row == kDateCellRow)
        [self toggleDatePickerCellHidden:tableView selectedPath:indexPath];
    else
        // hide the date picker cell when any other cell is selected
        if (self.isEditingDateTime)
            [self toggleDatePickerCellHidden:tableView selectedPath:indexPath];
}

#pragma mark - Events

- (IBAction)clickedDone:(UIBarButtonItem *)sender {
    // add new event to journal
    CMAEntry *entryToAdd = [[CMAStorageManager sharedManager] managedEntry];
    
    if ([self checkUserInputAndSetEntry:entryToAdd]) {
        if (self.isEditingEntry) {
            [[self journal] editEntryDated:[self.entry date] newProperties:entryToAdd];
            [[CMAStorageManager sharedManager] deleteManagedObject:entryToAdd];
        } else {
            if (![[self journal] addEntry:entryToAdd]) {
                [CMAAlerts errorAlert:@"An entry with that date and time already exists. Please select a new date or edit the existing entry." presentationViewController:self];
                [[CMAStorageManager sharedManager] deleteManagedObject:entryToAdd];
                return;
            }

            self.entry = nil;
        }
        
        [[self journal] archive];
        [self performSegueToPreviousView];
    } else
        [[CMAStorageManager sharedManager] deleteManagedObject:entryToAdd];
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    if (!self.isEditingEntry) {
        if (self.weatherData) {
            [[CMAStorageManager sharedManager] deleteManagedObject:self.weatherData];
            self.weatherData = nil;
        }
        
        [self setEntry:nil];
    }
    
    [self performSegueToPreviousView];
}

- (IBAction)changedDatePicker:(UIDatePicker *)sender {
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:sender.date]];
}

- (void)tapCameraImage {
    [self.cameraActionSheet showInViewController:self];
}

- (IBAction)tapToggleWeatherButton:(UIButton *)sender {
    [self toggleWeatherData];
}

- (IBAction)longPressedImageInCollection:(UILongPressGestureRecognizer *)sender {
    // only show at the beginning of the gesture
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.deleteImageIndexPath = [self.imageCollection indexPathForItemAtPoint:[sender locationInView:self.imageCollection]];
        [self.removeImageActionSheet showInViewController:self];
    }
}

#pragma mark - Action Sheets

- (void)initCameraActionSheet {
    __weak id weakSelf = self;
    
    self.cameraActionSheet =
        [CMACameraActionSheet alertControllerWithTitle:nil
                                               message:nil
                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.cameraActionSheet.attachPhotoBlock = ^void(UIAlertAction *action) {
        [weakSelf presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    };
    
    self.cameraActionSheet.takePhotoBlock = ^void(UIAlertAction *action) {
        if ([CMAImagePickerViewController cameraAvailable:weakSelf])
            [weakSelf presentImagePicker:UIImagePickerControllerSourceTypeCamera];
    };
    
    [self.cameraActionSheet addActions];
}

- (void)initRemoveImageActionSheet {
    __weak typeof(self) weakSelf = self;
    
    self.removeImageActionSheet =
        [CMARemoveImageActionSheet alertControllerWithTitle:nil
                                                    message:nil
                                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.removeImageActionSheet.deleteActionBlock = ^void(UIAlertAction *action) {
        if (weakSelf.deleteImageIndexPath != nil) {
            [weakSelf deleteImageFromCollectionAtIndexPath:weakSelf.deleteImageIndexPath];
            weakSelf.deleteImageIndexPath = nil;
        }
    };
    
    [self.removeImageActionSheet addActions];
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerIDViewEntries:
            [self performSegueWithIdentifier:@"unwindToViewEntriesFromAddEntry" sender:self];
            break;
            
        case CMAViewControllerIDSingleEntry:
            [self performSegueWithIdentifier:@"unwindToSingleEntryFromAddEntry" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // bait used
    if ([segue.identifier isEqualToString:@"fromAddEntryToViewBaits"]) {
        CMAViewBaitsViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.isSelectingForAddEntry = YES;
        
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow]; // so it knows which cell to edit after the unwind
        return;
    }
    
    BOOL isSetting = NO;
    NSString *userDefineName;
    
    // species
    if ([segue.identifier isEqualToString:@"fromAddEntrySpeciesToEditSettings"]) {
        isSetting = YES;
        userDefineName = UDN_SPECIES;
    }
    
    // location
    if ([segue.identifier isEqualToString:@"fromAddEntryLocationToEditSettings"]) {
        isSetting = YES;
        userDefineName = UDN_LOCATIONS;
    }
    
    // methods
    if ([segue.identifier isEqualToString:@"fromAddEntryMethodsToEditSettings"]) {
        isSetting = YES;
        userDefineName = UDN_FISHING_METHODS;
    }
    
    // water clarities
    if ([segue.identifier isEqualToString:@"fromAddEntryWaterClarityToEditSettings"]) {
        isSetting = YES;
        userDefineName = UDN_WATER_CLARITIES;
    }
    
    if (isSetting) {
        CMAUserDefinesViewController *destination = segue.destinationViewController;
        
        if ([destination isKindOfClass:[UINavigationController class]])
            destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];

        destination.userDefine = [[self journal] userDefineNamed:userDefineName];
        destination.previousViewID = CMAViewControllerIDAddEntry;
        
        if ([destination.userDefine.name isEqualToString:UDN_FISHING_METHODS]) {
            NSMutableArray *stringArray = [NSMutableArray array];
            
            NSMutableSet *methods = [self parseMethodsDetailText];
            for (id m in methods)
                [stringArray addObject:[m name]];
            
            destination.selectedCellsArray = [stringArray mutableCopy];
        }
        
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow]; // so it knows which cell to edit after the unwind
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromEditSettings"]) {
        CMAUserDefinesViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        
        if ([source.selectedCellLabelText isEqualToString:@""])
            [[cellToEdit detailTextLabel] setText:kNotSelectedString];
        else
            [[cellToEdit detailTextLabel] setText:source.selectedCellLabelText];
        
        source.selectedCellLabelText = nil;
        source.previousViewID = CMAViewControllerIDNil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        
        [[cellToEdit detailTextLabel] setText:source.selectedCellLabelText];
        
        source.location = nil;
        source.selectedCellLabelText = nil;
        source.previousViewID = CMAViewControllerIDNil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromViewBaits"]) {
        CMAViewBaitsViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        [[cellToEdit detailTextLabel] setText:source.baitForAddEntry.name];
        
        source.baitForAddEntry = nil;
    }
}

#pragma mark - Entry Creation

// Returns true if all the user input is valid. Sets anEntry's properties after validation.
- (BOOL)checkUserInputAndSetEntry:(CMAEntry *)anEntry {
    // date
    [anEntry setDate:[self.datePicker date]];
    
    // photos
    // delete current images from core data as they'll be restored later
    if (self.entry) {
        for (int i = 0; i < [self.entry.images count]; i++)
            if ([self.entryImages objectAtIndex:i])
                [[CMAStorageManager sharedManager] deleteManagedObject:[self.entryImages objectAtIndex:i]];
        
        self.entry.images = [NSMutableOrderedSet orderedSet];
    }
    
    if ([self.imageCollection numberOfItemsInSection:0] > 0) {
        for (int i = 0; i < [self.imageCollection numberOfItemsInSection:0]; i++) {
            UICollectionViewCell *cell = [self.imageCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            UIImage *image = [(UIImageView *)[cell viewWithTag:kImageViewTag] image];
            
            // save photos that were taken with the camera
            if (cell.tag == kSavePhotoTag)
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            
            CMAImage *img = [[CMAStorageManager sharedManager] managedImage];
            img.data = UIImagePNGRepresentation(image);
            img.entry = anEntry;
        }
    } else
        [anEntry setImages:nil];
    
    // species
    if (![[self.speciesDetailLabel text] isEqualToString:kNotSelectedString]) {
        CMASpecies *species = [[[self journal] userDefineNamed:UDN_SPECIES] objectNamed:[self.speciesDetailLabel text]];
        [species addEntry:anEntry];
        [anEntry setFishSpecies:species];
    } else {
        [CMAAlerts errorAlert:@"Please select a species." presentationViewController:self];
        return NO;
    }
    
    // fish quantity
    if (![[self.quantityTextField text] isEqualToString:@""]) {
        NSNumber *quantity = [NSNumber numberWithInteger:[[self.quantityTextField text] integerValue]];
        [anEntry setFishQuantity:quantity];
    } else {
        [anEntry setFishQuantity:[NSNumber numberWithInteger:-1]];
    }
    
    // fish length
    if (![[self.lengthTextField text] isEqualToString:@""]) {
        NSNumber *length = [NSNumber numberWithInteger:[[self.lengthTextField text] integerValue]];
        [anEntry setFishLength:length];
    } else {
        [anEntry setFishLength:[NSNumber numberWithInteger:-1]];
    }
    
    // fish weight
    if ([[self journal] measurementSystem] == CMAMeasuringSystemTypeMetric) {
        if (![[self.metricWeightTextField text] isEqualToString:@""]) {
            NSNumber *weight = [NSNumber numberWithInteger:[[self.metricWeightTextField text] integerValue]];
            [anEntry setFishWeight:weight];
        } else {
            [anEntry setFishWeight:[NSNumber numberWithInteger:-1]];
        }
    } else {
        NSString *poundsStr = [self.poundsTextField text];
        NSString *ouncesStr = [self.ouncesTextField text];
        
        // if the user filled one of them out
        if (!([poundsStr isEqualToString:@""] && [ouncesStr isEqualToString:@""])) {
            if ([poundsStr isEqualToString:@""]) poundsStr = @"0";
            if ([ouncesStr isEqualToString:@""]) ouncesStr = @"0";
            
            if (![[self.poundsTextField text] isEqualToString:@""]) {
                NSNumber *pounds = [NSNumber numberWithInteger:[poundsStr integerValue]];
                NSNumber *ounces = [NSNumber numberWithInteger:[ouncesStr integerValue]];
                [anEntry setFishWeight:pounds];
                [anEntry setFishOunces:ounces];
            } else {
                [anEntry setFishWeight:[NSNumber numberWithInteger:-1]];
                [anEntry setFishOunces:[NSNumber numberWithInteger:-1]];
            }
        }
    }
    
    // location and fishing spot
    if (![[self.locationDetailLabel text] isEqualToString:kNotSelectedString]) {
        NSArray *locationInfo = [self parseLocationDetailText];
        
        [anEntry setLocation:locationInfo[0]];
        [anEntry setFishingSpot:locationInfo[1]];
        
        [anEntry.location addEntry:anEntry];
        [anEntry.fishingSpot addEntry:anEntry];
    } else {
        [anEntry setLocation:nil];
        [anEntry setFishingSpot:nil];
    }
    
    // bait used
    if (![[self.baitUsedDetailLabel text] isEqualToString:kNotSelectedString]) {
        CMABait *bait = [[[self journal] userDefineNamed:UDN_BAITS] objectNamed:[self.baitUsedDetailLabel text]];
        [bait addEntry:anEntry];
        [anEntry setBaitUsed:bait];
    } else {
        [anEntry setBaitUsed:nil];
    }
    
    // fishing methods
    if (![[self.methodsDetailLabel text] isEqualToString:kNotSelectedString]) {
        NSMutableSet *methods = [self parseMethodsDetailText];
        for (CMAFishingMethod *m in methods)
            [m addEntry:anEntry];
        
        [anEntry setFishingMethods:methods];
    } else {
        [anEntry setFishingMethods:nil];
    }
    
    // weather conditions
    if (self.isWeatherInitialized) {
        [anEntry setWeatherData:self.weatherData];
        [anEntry.weatherData setEntry:anEntry];
    } else
        [anEntry setWeatherData:nil];
    
    // water temperature
    if (![[self.waterTemperatureTextField text] isEqualToString:@""]) {
        NSNumber *temp = [NSNumber numberWithInteger:[[self.waterTemperatureTextField text] integerValue]];
        [anEntry setWaterTemperature:temp];
    } else {
        [anEntry setWaterTemperature:[NSNumber numberWithInteger:-1]];
    }
    
    // water clarity
    if (![[self.waterClarityLabel text] isEqualToString:kNotSelectedString]) {
        CMAWaterClarity *waterClarity = [[[self journal] userDefineNamed:UDN_WATER_CLARITIES] objectNamed:[self.waterClarityLabel text]];
        [waterClarity addEntry:anEntry];
        [anEntry setWaterClarity:waterClarity];
    } else {
        [anEntry setWaterClarity:nil];
    }
    
    // water depth
    if (![[self.waterDepthTextField text] isEqualToString:@""]) {
        NSNumber *depth = [NSNumber numberWithInteger:[[self.waterDepthTextField text] integerValue]];
        [anEntry setWaterDepth:depth];
    } else {
        [anEntry setWaterDepth:[NSNumber numberWithInteger:-1]];
    }
    
    // notes
    if (![[self.notesTextView text] isEqualToString:@""]) {
        [anEntry setNotes:[self.notesTextView text]];
    } else {
        [anEntry setNotes:nil];
    }
    
    return YES;
}

// Returns array of length 2 where [0] is a CMALocation and [1] is a CMAFishingSpot.
- (NSArray *)parseLocationDetailText {
    NSArray *stringLocationInfo = [[self.locationDetailLabel text] componentsSeparatedByString:TOKEN_LOCATION];
    
    CMALocation *location = [[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:stringLocationInfo[0]];
    CMAFishingSpot *fishingSpot = [location fishingSpotNamed:stringLocationInfo[1]];

    return [NSArray arrayWithObjects:location, fishingSpot, nil];
}

// Returns an NSSet of fishing methods from [[self journal] userDefines].
- (NSMutableSet *)parseMethodsDetailText {
    NSMutableSet *result = [NSMutableSet set];
    NSArray *fishingMethodStrings = [[self.methodsDetailLabel text] componentsSeparatedByString:TOKEN_FISHING_METHODS];
    
    for (NSString *str in fishingMethodStrings) {
        id obj = [[[self journal] userDefineNamed:UDN_FISHING_METHODS] objectNamed:str];
        
        if (obj)
            [result addObject:obj];
    }
    
    return result;
}

#pragma mark - Image Picker

// Presents an image picker with sourceType.
- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType {
    CMAImagePickerViewController *imagePicker = [CMAImagePickerViewController new];
    
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:sourceType];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self insertImageIntoCollection:chosenImage saveToGallery:(picker.sourceType == UIImagePickerControllerSourceTypeCamera)];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfImages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailImageCell" forIndexPath:indexPath];
    
    if ([self.entryImages count] > 0) {
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
        CMAImage *img = [self.entryImages objectAtIndex:indexPath.item];
        [imageView setImage:[img dataAsUIImage]];
    }
        
    return cell;
}

- (void)insertImageIntoCollection:(UIImage *)anImage saveToGallery:(BOOL)saveToGallery {
    self.numberOfImages++;
    
    // reload table if adding the first image
    if (!self.hasAttachedImages) {
        self.hasAttachedImages = YES;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.imageCollection insertItemsAtIndexPaths:@[indexPath]];
    
    UICollectionViewCell *insertedCell = [self.imageCollection cellForItemAtIndexPath:indexPath];
    
    if (saveToGallery)
        [insertedCell setTag:kSavePhotoTag];
    
    UIImageView *imageView = (UIImageView *)[insertedCell viewWithTag:kImageViewTag];
    [imageView setImage:anImage];
}

- (void)deleteImageFromCollectionAtIndexPath:(NSIndexPath *)anIndexPath {
    self.numberOfImages--;
    
    // delete image from core data if it's a core data obejct
    CMAImage *img = [self.entryImages objectAtIndex:anIndexPath.item];
    if (img) {
        [self.entryImages removeObject:img];
        [[CMAStorageManager sharedManager] deleteManagedObject:img];
    }
    
    [self.imageCollection deleteItemsAtIndexPaths:@[anIndexPath]];
    
    // reload table to hide collection cell if there are no more images
    if (self.numberOfImages == 0) {
        self.hasAttachedImages = NO;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self initWeatherDataWithCoordinate:manager.location.coordinate];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [CMAAlerts errorAlert:[NSString stringWithFormat:@"Failed to get user location. Error: %@", error.localizedDescription] presentationViewController:self];
    [self.weatherIndicator stopAnimating];
    [self.weatherIndicator setHidden:YES];
}

#pragma mark - Weather 

- (void)toggleWeatherDataCell {
    if (self.isWeatherInitialized) {
        [self.toggleWeatherButton setTitle:@"-" forState:UIControlStateNormal];
        [self.weatherIndicator stopAnimating];
        [self.weatherIndicator setHidden:YES];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.weatherDataView setAlpha:1.0f];
        }];
    } else {
        // remove weather data
        [UIView animateWithDuration:0.15 animations:^{
            [self.weatherDataView setAlpha:0.0f];
        }];
        
        [self.toggleWeatherButton setTitle:@"+" forState:UIControlStateNormal];
        
        // remove from core data
        if (self.weatherData) {
            [[CMAStorageManager sharedManager] deleteManagedObject:self.weatherData];
            self.weatherData = nil;
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)toggleWeatherData {
    self.isWeatherInitialized = !self.isWeatherInitialized;
    
    if (self.isWeatherInitialized) {
        [self.weatherIndicator setHidden:NO];
        [self.weatherIndicator startAnimating];
        
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    } else
        [self toggleWeatherDataCell];
}

// Sets self.weatherData from data gathered from the OpenWeatherMapAPI.
- (void)initWeatherDataWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (![CMAUtilities validConnection]) {
        [CMAAlerts errorAlert:@"You do not have a valid network connection. Please connect and try again." presentationViewController:self];
        [self.weatherIndicator setHidden:YES];
        return;
    }
    
    self.weatherData = [[CMAStorageManager sharedManager] managedWeatherData];
    self.weatherData = [self.weatherData initWithCoordinates:coordinate andJournal:[[self journal] measurementSystem]];
    
    [self.weatherData.weatherAPI currentWeatherByCoordinate:self.weatherData.coordinate withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            NSLog(@"Error getting weather data: %@", error.localizedDescription);
            [CMAAlerts errorAlert:@"There was an error getting weather data. Please try again later." presentationViewController:self];
            [self.weatherIndicator setHidden:YES];
            [[CMAStorageManager sharedManager] deleteManagedObject:self.weatherData];
            [self setWeatherData:nil];
            return;
        }
        
        NSArray *weatherArray = result[@"weather"];
        
        if ([weatherArray count] > 0) {
            NSString *imageString = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", result[@"weather"][0][@"icon"]];
            [self.weatherData setWeatherImage:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]]];
            [self.weatherData setSkyConditions:result[@"weather"][0][@"main"]];
        } else {
            [self.weatherData setWeatherImage:UIImagePNGRepresentation([UIImage imageNamed:@"no_image.png"])];
            [self.weatherData setSkyConditions:@"N/A"];
        }
        
        [self.weatherData setTemperature:(NSNumber *)result[@"main"][@"temp"]]; // [3][3]
        [self.weatherData setWindSpeed:[NSString stringWithFormat:@"%@", result[@"wind"][@"speed"]]]; // [1][0]
        
        [self initWeatherDataViewWithData:self.weatherData];
        [self toggleWeatherDataCell];
    }];
}

- (void)initWeatherDataViewWithData:(CMAWeatherData *)someWeatherData {
    [self.weatherDataView.weatherImageView setImage:[UIImage imageWithData:someWeatherData.weatherImage]];
    [self.weatherDataView.temperatureLabel setText:[someWeatherData temperatureAsStringWithUnits:[[self journal] temperatureUnitsAsString:YES]]];
    [self.weatherDataView.windSpeedLabel setText:[someWeatherData windSpeedAsStringWithUnits:[[self journal] speedUnitsAsString:YES]]];
    [self.weatherDataView.skyConditionsLabel setText:[someWeatherData skyConditionsAsString]];
}

@end
