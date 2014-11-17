//
//  CMAAddEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAEditSettingsViewController.h"
#import "CMASingleLocationViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAlerts.h"

@interface CMAAddEntryViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic)IBOutlet UILabel *dateTimeDetailLabel;
@property (weak, nonatomic)IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic)IBOutlet UILabel *speciesDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *baitUsedDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *methodsDetailLabel;
@property (weak, nonatomic)IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic)IBOutlet UITextField *lengthTextField;
@property (weak, nonatomic)IBOutlet UITextField *weightTextField;
@property (weak, nonatomic)IBOutlet UICollectionView *imageCollection;
@property (weak, nonatomic)IBOutlet UITextView *notesTextView;

@property (weak, nonatomic)IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic)IBOutlet UILabel *weightLabel;

@property (weak, nonatomic)IBOutlet UIImageView *cameraImage;

@property (strong, nonatomic)UIActionSheet *cameraActionSheet;
@property (strong, nonatomic)UIActionSheet *deleteImageActionSheet;

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)NSIndexPath *indexPathForOptionsCell; // used after an unwind from selecting options
@property (nonatomic)BOOL isEditingDateTime;
@property (nonatomic)BOOL isEditingEntry;
@property (nonatomic)BOOL hasEditedNotesTextView;

@property (nonatomic)BOOL hasAttachedImages;
@property (nonatomic)NSInteger numberOfImages;
@property (strong, nonatomic)NSIndexPath *deleteImageIndexPath;
@property (strong, nonatomic)NSArray *entryImages;

@end

NSInteger const DATE_PICKER_HEIGHT = 225;
NSInteger const DATE_PICKER_SECTION = 0;
NSInteger const DATE_PICKER_ROW = 1;
NSInteger const DATE_DISPLAY_SECTION = 0;
NSInteger const DATE_DISPLAY_ROW = 0;

NSInteger const IMAGES_HEIGHT = 150;
NSInteger const IMAGES_SECTION = 2;

NSInteger const IMAGE_VIEW_TAG = 100;

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
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    // set date detail label to the current date and time
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:[NSDate new]]];
    
    // set proper units for length and weight labels
    [self.lengthLabel setText:[NSString stringWithFormat:@"Length (%@)", [[self journal] lengthUnitsAsString:NO]]];
    [self.weightLabel setText:[NSString stringWithFormat:@"Weight (%@)", [[self journal] weightUnitsAsString:NO]]];
    
    [self.imageCollection setAllowsSelection:NO];
    [self.imageCollection setAllowsMultipleSelection:NO];
    
    self.isEditingEntry = self.previousViewID == CMAViewControllerID_SingleEntry;
    self.isEditingDateTime = NO;
    self.hasEditedNotesTextView = NO;
    self.hasAttachedImages = NO;
    self.numberOfImages = 0;
    
    // if we're editing rather than adding an entry
    if (self.isEditingEntry)
        [self initializeTableForEditing];
    
    [self initCameraImage];
    [self initCameraActionSheet];
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
    [self.speciesDetailLabel setText:self.entry.fishSpecies.name];
    
    // location and fishing spot
    [self.locationDetailLabel setText:[NSString stringWithFormat:@"%@: %@", self.entry.location.name, self.entry.fishingSpot.name]];
    
    // bait used
    if (self.entry.baitUsed)
        [self.baitUsedDetailLabel setText:self.entry.baitUsed.name];
    
    // fishing methods
    if (self.entry.fishingMethods)
        [self.methodsDetailLabel setText:[self.entry concatinateFishingMethods]];
    
    // fish quantity
    if (self.entry.fishQuantity)
        [self.quantityTextField setText:self.entry.fishQuantity.stringValue];
    
    // fish length
    if ([self.entry.fishLength integerValue] != -1)
        [self.lengthTextField setText:self.entry.fishLength.stringValue];
    else
        [self.lengthTextField setText:@"0"];
    
    // fish weight
    if ([self.entry.fishWeight integerValue] != -1)
        [self.weightTextField setText:self.entry.fishWeight.stringValue];
    else
        [self.weightTextField setText:@"0"];
    
    // pictures
    [self.imageCollection reloadData];
    
    // notes
    if (self.entry.notes)
        [self.notesTextView setText:self.entry.notes];
}

- (void)toggleDatePickerCellHidden:(UITableView *)aTableView {
    self.isEditingDateTime = !self.isEditingDateTime;
    
    // use begin/endUpdates to animate changes
    [aTableView beginUpdates];
    
    if (self.isEditingDateTime)
        [UIView animateWithDuration:0.5 animations:^{
            [self.datePicker setAlpha:1.0f];
        }];
    else
        [UIView animateWithDuration:0.15 animations:^{
            [self.datePicker setAlpha:0.0f];
        }];
    
    [aTableView reloadData];
    
    [aTableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_SECTION_SPACING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // only set a footer for the last cell in the table
    if (section == ([self numberOfSectionsInTableView:tableView] - 1))
        return TABLE_SECTION_SPACING;

    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // set height of the date picker cell
    if (indexPath.section == DATE_PICKER_SECTION && indexPath.row == DATE_PICKER_ROW) {
        if (self.isEditingDateTime)
            return DATE_PICKER_HEIGHT;
        else
            return 0;
    }
    
    // for the images collection cell
    if (indexPath.section == IMAGES_SECTION) {
        if (self.hasAttachedImages)
            return IMAGES_HEIGHT;
        else
            return 44;
    }
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // show the date picker cell when the date display cell is selected
    if (indexPath.section == DATE_DISPLAY_SECTION && indexPath.row == DATE_DISPLAY_ROW)
        [self toggleDatePickerCellHidden:tableView];
    else
        // hide the date picker cell when any other cell is selected
        if (self.isEditingDateTime)
            [self toggleDatePickerCellHidden:tableView];
}

#pragma mark - Text View Initializing

- (void)initCameraImage {
    // add tap gesture recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedCameraImage)];
    singleTap.numberOfTapsRequired = 1;
    [self.cameraImage setUserInteractionEnabled:YES];
    [self.cameraImage addGestureRecognizer:singleTap];
    
    // add current tint
    UIImage *image = [[UIImage imageNamed:@"camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cameraImage setImage:image];
    [self.cameraImage setTintColor:[[[[UIApplication sharedApplication] delegate] window] tintColor]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // clear the default "Notes" text
    if (!self.hasEditedNotesTextView) {
        [textView setText:@""];
        self.hasEditedNotesTextView = YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // if nothing was added while editing, reset the text to "Notes"
    if ([textView.text isEqualToString:@""]) {
        [textView setText:@"Notes"];
        self.hasEditedNotesTextView = NO;
    }
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
        
        [[self journal] sortEntriesBy:[self journal].entrySortMethod order:[self journal].entrySortOrder];
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

- (void)clickedCameraImage {
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

- (void)initCameraActionSheet {
    self.cameraActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Attach Photo", nil];
}

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
        case CMAViewControllerID_ViewEntries:
            [self performSegueWithIdentifier:@"unwindToViewEntriesFromAddEntry" sender:self];
            break;
            
        case CMAViewControllerID_SingleEntry:
            [self performSegueWithIdentifier:@"unwindToSingleEntryFromAddEntry" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
    
    // bait used
    if ([segue.identifier isEqualToString:@"fromAddEntryBaitToEditSettings"]) {
        isSetting = YES;
        userDefineName = SET_BAITS;
    }
    
    // methods
    if ([segue.identifier isEqualToString:@"fromAddEntryMethodsToEditSettings"]) {
        isSetting = YES;
        userDefineName = SET_FISHING_METHODS;
    }
    
    if (isSetting) {
        CMAEditSettingsViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.userDefine = [[self journal] userDefineNamed:userDefineName];
        destination.previousViewID = CMAViewControllerID_AddEntry;
        
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow]; // so it knows which cell to edit after the unwind
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromEditSettings"]) {
        CMAEditSettingsViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        
        if ([source.selectedCellLabelText isEqualToString:@""])
            [[cellToEdit detailTextLabel] setText:NO_SELECT];
        else
            [[cellToEdit detailTextLabel] setText:source.selectedCellLabelText];
        
        source.previousViewID = CMAViewControllerID_Nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromSingleLocation"]) {
        CMASingleLocationViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        [[cellToEdit detailTextLabel] setText:source.addEntryLabelText];
        
        source.previousViewID = CMAViewControllerID_Nil;
    }
}

#pragma mark - Entry Creation

// Returns true if all the user input is valid. Sets anEntry's properties after validation.
// Used as a loop condition to validate user input.
- (BOOL)checkUserInputAndSetEntry: (CMAEntry *)anEntry {
    // date
    [anEntry setDate:[self.datePicker date]];
    
    // species
    if (![[self.speciesDetailLabel text] isEqualToString:NO_SELECT]) {
        CMASpecies *species = [[[self journal] userDefineNamed:SET_SPECIES] objectNamed:[self.speciesDetailLabel text]];
        [anEntry setFishSpecies:species];
    } else {
        [CMAAlerts errorAlert:@"Please select a species."];
        return NO;
    }
    
    // location and fishing spot
    if (![[self.locationDetailLabel text] isEqualToString:NO_SELECT]) {
        NSArray *locationInfo = [self parseLocationDetailText];
        
        [anEntry setLocation:locationInfo[0]];
        [anEntry setFishingSpot:locationInfo[1]];
    } else {
        [CMAAlerts errorAlert:@"Please select a location."];
        return NO;
    }
    
    // bait used
    if (![[self.baitUsedDetailLabel text] isEqualToString:NO_SELECT]) {
        CMABait *bait = [[[self journal] userDefineNamed:SET_BAITS] objectNamed:[self.baitUsedDetailLabel text]];
        [anEntry setBaitUsed:bait];
    } else {
        [anEntry setBaitUsed:[CMABait withName:@""]];
    }
    
    // fishing methods
    if (![[self.methodsDetailLabel text] isEqualToString:NO_SELECT]) {
        [anEntry setFishingMethods:[self parseMethodsDetailText]];
    } else {
        [anEntry setFishingMethods:nil];
    }
    
    // fish quantity
    if (![[self.quantityTextField text] isEqualToString:@"0"]) {
        NSNumber *quantity = [NSNumber numberWithInteger:[[self.quantityTextField text] integerValue]];
        [anEntry setFishQuantity:quantity];
    } else {
        [anEntry setFishQuantity:[NSNumber numberWithInteger:-1]];
    }
    
    // fish length
    if (![[self.lengthTextField text] isEqualToString:@"0"]) {
        NSNumber *length = [NSNumber numberWithInteger:[[self.lengthTextField text] integerValue]];
        [anEntry setFishLength:length];
    } else {
        [anEntry setFishLength:[NSNumber numberWithInteger:-1]];
    }
    
    // fish weight
    if (![[self.weightTextField text] isEqualToString:@"0"]) {
        NSNumber *weight = [NSNumber numberWithInteger:[[self.weightTextField text] integerValue]];
        [anEntry setFishWeight:weight];
    } else {
        [anEntry setFishWeight:[NSNumber numberWithInteger:-1]];
    }
    
    // pictures
    if ([self.imageCollection numberOfItemsInSection:0] > 0) {
        for (int i = 0; i < [self.imageCollection numberOfItemsInSection:0]; i++) {
            UICollectionViewCell *cell = [self.imageCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            UIImage *image = [(UIImageView *)[cell viewWithTag:IMAGE_VIEW_TAG] image];
            
            [anEntry addImage:image];
        }
    } else
        [anEntry setImages:nil];
    
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
- (NSSet *)parseMethodsDetailText {
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
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
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
    
    UIImageView *imageView = (UIImageView *)[insertedCell viewWithTag:IMAGE_VIEW_TAG];
    [imageView setImage:anImage];
}

- (void)deleteImageFromCollectionAtIndexPath:(NSIndexPath *)anIndexPath {
    self.numberOfImages--;
    
    [self.imageCollection deleteItemsAtIndexPaths:@[anIndexPath]];
    
    // reload table to hide collection cell if there are no more images
    if (self.numberOfImages == 0) {
        self.hasAttachedImages = NO;
        
        [self.tableView beginUpdates];
        [self.tableView reloadData];
        [self.tableView endUpdates];
    }
}

@end
