//
//  CMAAddEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAAddLocationViewController.h"

@interface CMAAddEntryViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic)IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic)IBOutlet UIDatePicker *datePicker;

@property (nonatomic)BOOL isEditingDateTime;

@end

NSInteger const DATE_PICKER_HEIGHT = 225;
NSInteger const DATE_PICKER_SECTION = 0;
NSInteger const DATE_PICKER_ROW = 1;
NSInteger const DATE_DISPLAY_SECTION = 0;
NSInteger const DATE_DISPLAY_ROW = 0;

@implementation CMAAddEntryViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEditingDateTime = NO;
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

#pragma mark - Events

- (IBAction)clickedDone:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

- (IBAction)changedDatePicker:(UIDatePicker *)sender {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    [self.dateTimeLabel setText:[dateFormatter stringFromDate:sender.date]];
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
    if ([segue.identifier isEqualToString:@"fromAddEntryToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_AddEntry;
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    
}

@end
