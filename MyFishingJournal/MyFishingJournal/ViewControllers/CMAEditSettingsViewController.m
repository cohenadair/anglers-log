//
//  CMAEditSettingsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEditSettingsViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAddLocationViewController.h"
#import "CMASingleLocationViewController.h"

@interface CMAEditSettingsViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneSelectingButton;

@property (strong, nonatomic)UIAlertView *addItemAlert;

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingMultiple;

@end

@implementation CMAEditSettingsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.userDefine name]; // sets title according to the setting that was clicked in the previous view
    self.navigationController.toolbarHidden = NO;
    
    self.isSelectingForAddEntry = (self.previousViewID == CMAViewControllerID_AddEntry);
    self.isSelectingMultiple = (self.isSelectingForAddEntry && [[self.userDefine name] isEqualToString:SET_FISHING_METHODS]);
    
    // for selecting multiple fishing methods
    if (self.isSelectingMultiple)
        [self configureTableForMutipleSelection];
    
    // initilize addItemAlert
    self.addItemAlert = [UIAlertView new];
    self.addItemAlert = [self.addItemAlert initWithTitle:@"" message:[NSString stringWithFormat:@"Add to %@:", [self.userDefine name]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    self.addItemAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // show the toolbar when navigating back from a push segue
    self.navigationController.toolbarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (void)configureTableForMutipleSelection {
    [self toggleDoneSelectingButton:YES];
    [self.tableView setAllowsMultipleSelection:YES];
    [self setIsSelectingForAddEntry:YES];
}

- (void)configureCellForMultipleSelection: (UITableViewCell *)aCell {
    [aCell setSelectionStyle:UITableViewCellSelectionStyleGray];
}

// Hides/shows a checkmark inside aCell.
- (void)toggleCellAccessoryCheckmarkAtIndexPath: (NSIndexPath *)anIndexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:anIndexPath];

    if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
    else
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

// Returns a string with all selected cell labels separated by a comma.
- (NSString *)stringFromSelectedCells {
    NSArray *selectedPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableString *selectedCellLabels = [NSMutableString string];
    
    for (NSIndexPath *path in selectedPaths) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        [selectedCellLabels appendFormat:@"%@, ", [cell.textLabel text]];
    }
    
    // remove the next comma and space
    if (selectedCellLabels.length > 0) {
        NSRange range;
        range.location = [selectedCellLabels length] - 2;
        range.length = 2;
        [selectedCellLabels replaceCharactersInRange:range withString:@""];
    }
    
    return selectedCellLabels;
}

// Inserts a cell with label aStringForLabel at the end of the table.
- (void)insertCellAtTableEnd: (NSString *)aStringForLabel {
    NSInteger lastSection = [self.tableView numberOfSections] - 1;
    NSInteger lastRow = [self.tableView numberOfRowsInSection:lastSection] - 1;
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:lastRow inSection:lastSection]];
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    UITableViewCell *insertedCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow + 1 inSection:lastSection + 1]];
    [insertedCell.textLabel setText:aStringForLabel];
    
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.userDefine count];
}

// Initialize each cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editSettingsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.userDefine nameAtIndex:indexPath.item];
    
    // enable chevron for non-strings
    if (![self.userDefine isSetOfStrings])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (self.isSelectingMultiple)
        [self configureCellForMultipleSelection:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // if it's a location, show Single Location View
    if ([[self.userDefine name] isEqualToString:SET_LOCATIONS]) {
        self.selectedCellLabelText = [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        [self performSegueWithIdentifier:@"fromEditSettingsToSingleLocation" sender:self];
    } else
    
    // if selecting multiple
    if (self.isSelectingMultiple)
        [self toggleCellAccessoryCheckmarkAtIndexPath:indexPath];
    else
    
    // unwind if we're selecting for Add Entry
    if (self.isSelectingForAddEntry) {
        self.selectedCellLabelText = [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromEditSettings" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // if selecting multiple
    if (self.isSelectingMultiple)
        [self toggleCellAccessoryCheckmarkAtIndexPath:indexPath];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.userDefine removeObjectNamed:cell.textLabel.text];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Toolbar Manipulation

// Shows or hides the "Done Selecting" button in the UIToolBar.
// Method is only used when selecting cells for the Add Entry view.
- (void)toggleDoneSelectingButton: (BOOL)show {
    if (show) {
        [self.doneSelectingButton setTitle:@"Done Selecting"];
        [self.doneSelectingButton setEnabled:YES];
    } else {
        [self.doneSelectingButton setTitle:@""];
        [self.doneSelectingButton setEnabled:NO];
    }
}

#pragma mark - Alert Views

// handles all UIAlertViews results for this screen
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // add the new user define
    if (alertView == self.addItemAlert)
        if (buttonIndex == 1) {
            NSString *enteredText = [[alertView textFieldAtIndex:0] text];
            [[alertView textFieldAtIndex:0] setText:@""];
            
            [self.userDefine addObject:enteredText];
            [self insertCellAtTableEnd:enteredText];
        }
}

#pragma mark - Events

- (IBAction)clickAddButton:(UIBarButtonItem *)sender {
    if ([[self.userDefine name] isEqualToString:SET_LOCATIONS])
        [self performSegueWithIdentifier:@"fromEditSettingsToAddLocation" sender:self];
    else
        [self.addItemAlert show];
}

// Enter editing mode.
- (IBAction)clickDeleteButton:(UIBarButtonItem *)sender {
    [self.tableView setEditing:YES animated:YES];
    [sender setEnabled:NO];
    [self.addButton setEnabled:NO];
    [self.doneSelectingButton setEnabled:NO];
    
    // add a done button that will be used to exit editing mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)clickDoneSelectingButton:(UIBarButtonItem *)sender {
    self.selectedCellLabelText = [self stringFromSelectedCells];
    [self performSegueWithIdentifier:@"unwindToAddEntryFromEditSettings" sender:self];
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self.tableView setEditing:NO animated:YES];
    [self.deleteButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromEditSettingsToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_EditSettings;
    }
    
    if ([segue.identifier isEqualToString:@"fromEditSettingsToSingleLocation"]) {
        CMASingleLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.location = [[[self journal] userDefineNamed:SET_LOCATIONS] locationNamed:self.selectedCellLabelText];
        destination.isSelectingForAddEntry = self.isSelectingForAddEntry;
    }
}

- (IBAction)unwindToEditSettings:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
}

@end
