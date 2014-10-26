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

@interface CMAAddEntryViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic)IBOutlet UILabel *dateTimeDetailLabel;
@property (weak, nonatomic)IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic)IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic)IBOutlet UITextField *lengthTextField;
@property (weak, nonatomic)IBOutlet UITextField *weightTextField;
@property (weak, nonatomic)IBOutlet UITextView *notesTextView;

@property (weak, nonatomic)IBOutlet UIButton *cameraButton;
@property (weak, nonatomic)IBOutlet UIButton *attachButton;
@property (weak, nonatomic)IBOutlet UICollectionView *imageCollection;

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)NSIndexPath *indexPathForOptionsCell; // used after an unwind from selecting options
@property (nonatomic)BOOL isEditingDateTime;
@property (nonatomic)BOOL hasEditedNotesTextView;

@property (nonatomic)BOOL hasAttachedImages;
@property (nonatomic)NSInteger numberOfImages;
@property (strong, nonatomic)NSIndexPath *deleteImageIndexPath;

@end

NSInteger const DATE_PICKER_HEIGHT = 225;
NSInteger const DATE_PICKER_SECTION = 0;
NSInteger const DATE_PICKER_ROW = 1;
NSInteger const DATE_DISPLAY_SECTION = 0;
NSInteger const DATE_DISPLAY_ROW = 0;

NSInteger const IMAGES_HEIGHT = 121;
NSInteger const IMAGES_SECTION = 2;
NSInteger const IMAGES_ROW = 1;

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
    
    [self.imageCollection setAllowsSelection:NO];
    [self.imageCollection setAllowsMultipleSelection:NO];
    
    self.isEditingDateTime = NO;
    self.hasEditedNotesTextView = NO;
    
    self.hasAttachedImages = NO;
    self.numberOfImages = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

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
    if (indexPath.section == IMAGES_SECTION && indexPath.row == IMAGES_ROW) {
        if (self.hasAttachedImages)
            return IMAGES_HEIGHT;
        else
            return 0;
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
    
    
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

- (IBAction)changedDatePicker:(UIDatePicker *)sender {
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:sender.date]];
}

- (IBAction)clickedCamera:(UIButton *)sender {
    if ([self cameraAvailable])
        [self presentImagePicker:YES];
}

- (IBAction)clickedAttach:(UIButton *)sender {
    [self presentImagePicker:NO];
}

- (IBAction)longPressedImageInCollection:(UILongPressGestureRecognizer *)sender {
    // only show at the beginning of the gesture
    if (sender.state == UIGestureRecognizerStateBegan) {
        // referenced in the UIAlertView delegate protocol
        self.deleteImageIndexPath = [self.imageCollection indexPathForItemAtPoint:[sender locationInView:self.imageCollection]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Picture" message:@"Do you want to remove this picture?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alertView show];
    }
}

#pragma mark - Alert View

// handles all UIAlertViews results for this screen
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // delete button
    if (buttonIndex == 1)
        if (self.deleteImageIndexPath != nil) {
            [self deleteImageFromCollectionAtIndexPath:self.deleteImageIndexPath];
            self.deleteImageIndexPath = nil;
        }
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_Home:
            [self performSegueWithIdentifier:@"unwindToHome" sender:self];
            break;
            
        case CMAViewControllerID_ViewEntries:
            [self performSegueWithIdentifier:@"unwindToViewEntries" sender:self];
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
    }
}

#pragma mark - Entry Creation

// Returns true if all the user input is valid. Sets anEntry's properties after validation.
// Used as a loop condition to validate user input.
- (BOOL)checkUserInputAndSetEntry: (CMAEntry *)anEntry {
    return YES;
}

// Returns array of length 2 where [0] is a CMALocation and [1] is a CMAFishingSpot.
- (NSArray *)parseLocationDetailText {
    NSArray *result = [NSArray array];
    
    return result;
}

// Returns an NSSet of fishing methods from [[self journal] userDefines].
- (NSSet *)parseMethodsDetailText {
    NSSet *result = [NSSet set];
    
    return result;
}

#pragma mark - Image Picker

// Presents either the devices camera or photo library depening on the camera BOOL.
- (void)presentImagePicker:(BOOL)camera {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:YES];
    
    if (camera)
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    else
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

// Returns whether or not the device has a camera.
// If not, displays an alert to the user.
- (BOOL)cameraAvailable {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
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
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailImageCell" forIndexPath:indexPath];
    
    [[cell.contentView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[cell.contentView layer] setBorderWidth:1.0f];
    
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
    
    UIImageView *imageView = (UIImageView *)[insertedCell viewWithTag:100];
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
