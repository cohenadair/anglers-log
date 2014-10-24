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

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)NSIndexPath *indexPathForOptionsCell; // used after an unwind from selecting options
@property (nonatomic)BOOL isEditingDateTime;
@property (nonatomic)BOOL hasEditedNotesTextView;

@end

NSInteger const DATE_PICKER_HEIGHT = 225;
NSInteger const DATE_PICKER_SECTION = 0;
NSInteger const DATE_PICKER_ROW = 1;
NSInteger const DATE_DISPLAY_SECTION = 0;
NSInteger const DATE_DISPLAY_ROW = 0;

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
    
    self.isEditingDateTime = NO;
    self.hasEditedNotesTextView = NO;
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
        [UIView animateWithDuration:0.5 animations:^(void) {
            [self.datePicker setAlpha:1.0f];
        }];
    else
        [UIView animateWithDuration:0.15 animations:^ (void) {
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

#pragma mark - Text View Initialization

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
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

- (IBAction)changedDatePicker:(UIDatePicker *)sender {
    [self.dateTimeDetailLabel setText:[self.dateFormatter stringFromDate:sender.date]];
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
        
        self.indexPathForOptionsCell = [self.tableView indexPathForSelectedRow];
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToAddEntryFromEditSettings"]) {
        CMAEditSettingsViewController *source = [segue sourceViewController];
        UITableViewCell *cellToEdit = [self.tableView cellForRowAtIndexPath:self.indexPathForOptionsCell];
        
        if ([source.selectedCellLabelText isEqualToString:@""])
            [[cellToEdit detailTextLabel] setText:@"Not Selected"];
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

@end
