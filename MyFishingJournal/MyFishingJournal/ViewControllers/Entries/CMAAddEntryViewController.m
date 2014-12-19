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
#import "CMASelectionTableViewController.h"
#import "CMAViewBaitsViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAlerts.h"
#import "CMACameraButton.h"
#import "CMACameraActionSheet.h"

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
@property (weak, nonatomic)IBOutlet UITextField *weightTextField;
@property (weak, nonatomic)IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic)IBOutlet UILabel *weightLabel;

#pragma mark - Catch Details
@property (weak, nonatomic)IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *baitUsedDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *methodsDetailLabel;

#pragma mark - Weather Conditions

#pragma mark - Water Conditions
@property (weak, nonatomic) IBOutlet UILabel *waterClarityLabel;
@property (weak, nonatomic) IBOutlet UITextField *waterDepthTextField;
@property (weak, nonatomic) IBOutlet UITextField *waterTemperatureTextField;
@property (weak, nonatomic) IBOutlet UILabel *waterDepthLabel;
@property (weak, nonatomic) IBOutlet UILabel *waterTemperatureLabel;

#pragma mark - Notes
@property (weak, nonatomic)IBOutlet UITextView *notesTextView;

#pragma mark - Camera
@property (weak, nonatomic)IBOutlet CMACameraButton *cameraImage;
@property (strong, nonatomic)CMACameraActionSheet *cameraActionSheet;
@property (strong, nonatomic)UIActionSheet *deleteImageActionSheet;

#pragma mark - Miscellaneous

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)NSIndexPath *indexPathForOptionsCell; // used after an unwind from selecting options
@property (nonatomic)BOOL isEditingDateTime;
@property (nonatomic)BOOL isEditingEntry;

@property (nonatomic)BOOL hasAttachedImages;
@property (nonatomic)NSInteger numberOfImages;
@property (strong, nonatomic)NSIndexPath *deleteImageIndexPath;
@property (strong, nonatomic)NSArray *entryImages;

@end

#define kDateCellSection 0
#define kDateCellRow 0

#define kDatePickerHeight 225
#define kDatePickerCellSection 0
#define kDatePickerCellRow 1

#define kImagesCellHeightExpanded 150
#define kImagesCellSection 1

#define kImageViewTag 100

NSString *const NO_SELECT = @"Not Selected";

@implementation CMAAddEntryViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMMM dd, yyyy 'at' h:mm a"];
    
    // set date detail label to the current date and time
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:[NSDate new]]];
    
    // set proper units for length and weight labels
    [self.lengthLabel setText:[NSString stringWithFormat:@"Length (%@)", [[self journal] lengthUnitsAsString:NO]]];
    [self.weightLabel setText:[NSString stringWithFormat:@"Weight (%@)", [[self journal] weightUnitsAsString:NO]]];
    
    [self.imageCollection setAllowsSelection:NO];
    [self.imageCollection setAllowsMultipleSelection:NO];
    
    self.isEditingEntry = self.previousViewID == CMAViewControllerIDSingleEntry;
    self.isEditingDateTime = NO;
    self.hasAttachedImages = NO;
    self.numberOfImages = 0;
    
    // if we're editing rather than adding an entry
    if (self.isEditingEntry)
        [self initializeTableForEditing];
    
    self.cameraActionSheet = [CMACameraActionSheet withDelegate:self];
    [self.cameraImage myInit:self action:@selector(tapCameraImage)];
    
    [self initDeleteImageActionSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (void)initializeTableForEditing {
    self.navigationItem.title = @"Edit Entry";
    [self initializeCellsForEditing];
    self.entryImages = [self.entry.images allObjects];
    self.numberOfImages = [self.entryImages count];
    self.hasAttachedImages = (self.numberOfImages > 0);
}

- (void)initializeCellsForEditing {
    // date
    [self.datePicker setDate:[self.entry date]];
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:[self.entry date]]];
    
    // species
    if (![self.entry.fishSpecies removedFromUserDefines])
        [self.speciesDetailLabel setText:self.entry.fishSpecies.name];
    else
        [self.speciesDetailLabel setText:@"Not Selected"];
    
    // location and fishing spot
    if (self.entry.location) {
        if (![self.entry.location removedFromUserDefines])
            [self.locationDetailLabel setText:[self.entry locationAsString]];
        else
            [self.locationDetailLabel setText:@"Not Selected"];
    }
    
    // bait used
    if (self.entry.baitUsed) {
        if (![self.entry.baitUsed removedFromUserDefines])
            [self.baitUsedDetailLabel setText:self.entry.baitUsed.name];
        else
            [self.baitUsedDetailLabel setText:@"Not Selected"];
    }
    
    // fishing methods
    if (self.entry.fishingMethods)
        [self.methodsDetailLabel setText:[self.entry fishingMethodsAsString]];
    
    // fish quantity
    if ([self.entry.fishQuantity integerValue] != -1)
        [self.quantityTextField setText:self.entry.fishQuantity.stringValue];
    
    // fish length
    if ([self.entry.fishLength integerValue] != -1)
        [self.lengthTextField setText:self.entry.fishLength.stringValue];
    
    // fish weight
    if ([self.entry.fishWeight integerValue] != -1)
        [self.weightTextField setText:self.entry.fishWeight.stringValue];
    
    // pictures
    [self.imageCollection reloadData];
    
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
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
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
    CMAEntry *entryToAdd = [CMAEntry new];
    
    if ([self checkUserInputAndSetEntry:entryToAdd]) {
        if (self.isEditingEntry) {
            [[self journal] editEntryDated:[self.entry date] newProperties:entryToAdd];
            [self setEntry:entryToAdd];
        } else
            if (![[self journal] addEntry:entryToAdd]) {
                [CMAAlerts errorAlert:@"An entry with that date and time already exists. Please select a new date or edit the existing entry."];
                return;
            }
        
        if (!self.isEditingEntry)
            [self setEntry:nil];
        
        [[self journal] archive];
        [self performSegueToPreviousView];
    }
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    if (!self.isEditingEntry)
        [self setEntry:nil];
    
    [self performSegueToPreviousView];
}

- (IBAction)changedDatePicker:(UIDatePicker *)sender {
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:sender.date]];
}

- (void)tapCameraImage {
    [self.cameraActionSheet showInView:self.view];
}

- (IBAction)longPressedImageInCollection:(UILongPressGestureRecognizer *)sender {
    // only show at the beginning of the gesture
    if (sender.state == UIGestureRecognizerStateBegan) {
        // referenced in the UIAlertView delegate protocol
        self.deleteImageIndexPath = [self.imageCollection indexPathForItemAtPoint:[sender locationInView:self.imageCollection]];
        [self.deleteImageActionSheet showInView:self.view];
    }
}

#pragma mark - Action Sheets

- (void)initDeleteImageActionSheet {
    self.deleteImageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to remove this photo (it will not be removed from your device)?" delegate:self cancelButtonTitle:@"No, keep it." destructiveButtonTitle:@"Yes, delete it." otherButtonTitles:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.cameraActionSheet) {
        // take photo
        if (buttonIndex == 0)
            if ([self cameraAvailable])
                [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
        
        // attach photo
        if (buttonIndex == 1)
            [self presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (actionSheet == self.deleteImageActionSheet) {
        // delete button
        if (buttonIndex == 0)
            if (self.deleteImageIndexPath != nil) {
                [self deleteImageFromCollectionAtIndexPath:self.deleteImageIndexPath];
                self.deleteImageIndexPath = nil;
            }
    }
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
    
    // water  clarity
    if ([segue.identifier isEqualToString:@"fromAddEntryWaterClarityToSelectionTable"]) {
        CMASelectionTableViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        
        destination.navigationItem.title = @"Water Clarities";
        destination.previousViewID = CMAViewControllerIDAddEntry;
        destination.tableDataArray = @[@"Clear", @"Stained", @"Dark"];
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow];
        
        return;
    }
    
    BOOL isSetting = NO;
    NSString *userDefineName;
    
    // species
    if ([segue.identifier isEqualToString:@"fromAddEntrySpeciesToEditSettings"]) {
        isSetting = YES;
        userDefineName = SET_SPECIES;
    }
    
    // location
    if ([segue.identifier isEqualToString:@"fromAddEntryLocationToEditSettings"]) {
        isSetting = YES;
        userDefineName = SET_LOCATIONS;
    }
    
    // methods
    if ([segue.identifier isEqualToString:@"fromAddEntryMethodsToEditSettings"]) {
        isSetting = YES;
        userDefineName = SET_FISHING_METHODS;
    }
    
    if (isSetting) {
        CMAUserDefinesViewController *destination = segue.destinationViewController;
        
        if ([destination isKindOfClass:[UINavigationController class]])
            destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];

        destination.userDefine = [[self journal] userDefineNamed:userDefineName];
        destination.previousViewID = CMAViewControllerIDAddEntry;
        
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow]; // so it knows which cell to edit after the unwind
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromEditSettings"]) {
        CMAUserDefinesViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        
        if ([source.selectedCellLabelText isEqualToString:@""])
            [[cellToEdit detailTextLabel] setText:NO_SELECT];
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
    
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromSelectionTable"]) {
        CMASelectionTableViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        [[cellToEdit detailTextLabel] setText:source.selectedCellLabelText];
        
        source.previousViewID = CMAViewControllerIDNil;
        source.selectedCellLabelText = nil;
        source.tableDataArray = nil;
    }
}

#pragma mark - Entry Creation

// Returns true if all the user input is valid. Sets anEntry's properties after validation.
- (BOOL)checkUserInputAndSetEntry:(CMAEntry *)anEntry {
    // date
    [anEntry setDate:[self.datePicker date]];
    
    // photos
    if ([self.imageCollection numberOfItemsInSection:0] > 0) {
        for (int i = 0; i < [self.imageCollection numberOfItemsInSection:0]; i++) {
            UICollectionViewCell *cell = [self.imageCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            UIImage *image = [(UIImageView *)[cell viewWithTag:kImageViewTag] image];
            
            [anEntry addImage:image];
        }
    } else
        [anEntry setImages:nil];
    
    // species
    if (![[self.speciesDetailLabel text] isEqualToString:NO_SELECT]) {
        CMASpecies *species = [[[self journal] userDefineNamed:SET_SPECIES] objectNamed:[self.speciesDetailLabel text]];
        [anEntry setFishSpecies:species];
    } else {
        [CMAAlerts errorAlert:@"Please select a species."];
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
    if (![[self.weightTextField text] isEqualToString:@""]) {
        NSNumber *weight = [NSNumber numberWithInteger:[[self.weightTextField text] integerValue]];
        [anEntry setFishWeight:weight];
    } else {
        [anEntry setFishWeight:[NSNumber numberWithInteger:-1]];
    }
    
    // location and fishing spot
    if (![[self.locationDetailLabel text] isEqualToString:NO_SELECT]) {
        NSArray *locationInfo = [self parseLocationDetailText];
        
        [anEntry setLocation:locationInfo[0]];
        [anEntry setFishingSpot:locationInfo[1]];
    } else {
        [anEntry setLocation:nil];
        [anEntry setFishingSpot:nil];
    }
    
    // bait used
    if (![[self.baitUsedDetailLabel text] isEqualToString:NO_SELECT]) {
        CMABait *bait = [[[self journal] userDefineNamed:SET_BAITS] objectNamed:[self.baitUsedDetailLabel text]];
        [anEntry setBaitUsed:bait];
    } else {
        [anEntry setBaitUsed:nil];
    }
    
    // fishing methods
    if (![[self.methodsDetailLabel text] isEqualToString:NO_SELECT]) {
        [anEntry setFishingMethods:[self parseMethodsDetailText]];
    } else {
        [anEntry setFishingMethods:nil];
    }
    
    // weather conditions
    
    // water conditions
    
    // notes
    if (![[self.notesTextView text] isEqualToString:@"Notes"]) {
        [anEntry setNotes:[self.notesTextView text]];
    } else {
        [anEntry setNotes:nil];
    }
    
    return YES;
}

// Returns array of length 2 where [0] is a CMALocation and [1] is a CMAFishingSpot.
- (NSArray *)parseLocationDetailText {
    NSArray *stringLocationInfo = [[self.locationDetailLabel text] componentsSeparatedByString:TOKEN_LOCATION];
    
    CMALocation *location = [[[self journal] userDefineNamed:SET_LOCATIONS] objectNamed:stringLocationInfo[0]];
    CMAFishingSpot *fishingSpot = [location fishingSpotNamed:stringLocationInfo[1]];

    return [NSArray arrayWithObjects:location, fishingSpot, nil];
}

// Returns an NSSet of fishing methods from [[self journal] userDefines].
- (NSMutableSet *)parseMethodsDetailText {
    NSMutableSet *result = [NSMutableSet set];
    NSArray *fishingMethodStrings = [[self.methodsDetailLabel text] componentsSeparatedByString:TOKEN_FISHING_METHODS];
    
    for (NSString *str in fishingMethodStrings)
        [result addObject:[[[self journal] userDefineNamed:SET_FISHING_METHODS] objectNamed:str]];
    
    return result;
}

#pragma mark - Image Picker

// Presents an image picker with sourceType.
- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setSourceType:sourceType];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

// Returns whether or not the device has a camera.
// If not, displays an alert to the user.
- (BOOL)cameraAvailable {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [CMAAlerts errorAlert:@"Device has no camera."];
        return false;
    }
    
    return true;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self insertImageIntoCollection:chosenImage];
    
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
        [imageView setImage:[self.entryImages objectAtIndex:indexPath.item]];
    }
        
    return cell;
}

- (void)insertImageIntoCollection: (UIImage *)anImage {
    self.numberOfImages++;
    
    // reload table if adding the first image
    if (!self.hasAttachedImages) {
        self.hasAttachedImages = YES;
        [self.tableView beginUpdates];
        [self.tableView reloadData];
        [self.tableView endUpdates];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.imageCollection insertItemsAtIndexPaths:@[indexPath]];
    
    UICollectionViewCell *insertedCell = [self.imageCollection cellForItemAtIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[insertedCell viewWithTag:kImageViewTag];
    [imageView setImage:anImage];
}

- (void)deleteImageFromCollectionAtIndexPath:(NSIndexPath *)anIndexPath {
    self.numberOfImages--;
    
    [self.imageCollection deleteItemsAtIndexPaths:@[anIndexPath]];
    
    // reload table to hide collection cell if there are no more images
    if (self.numberOfImages == 0) {
        self.hasAttachedImages = NO;
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

@end
