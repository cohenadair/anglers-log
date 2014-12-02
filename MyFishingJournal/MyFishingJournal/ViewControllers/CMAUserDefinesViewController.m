//
//  CMAEditSettingsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefinesViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAddLocationViewController.h"
#import "CMASingleLocationViewController.h"
#import "CMASelectFishingSpotViewController.h"
#import "CMANoXView.h"
#import "SWRevealViewController.h"

@interface CMAUserDefinesViewController ()

@property (strong, nonatomic)UIBarButtonItem *editButton;
@property (strong, nonatomic)UIBarButtonItem *doneSelectingButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic)UIAlertView *addItemAlert;
@property (strong, nonatomic)UIAlertView *editItemAlert;
@property (strong, nonatomic)CMANoXView *noXView;

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingMultiple;
@property (nonatomic)BOOL isSelectingForStatistics;

@end

@implementation CMAUserDefinesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoXView {
    self.noXView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    NSString *imageName = @"";
    
    if ([self.userDefine.name isEqualToString:SET_LOCATIONS])
        imageName = @"locations_large.png";
    else if ([self.userDefine.name isEqualToString:SET_FISHING_METHODS])
        imageName = @"fishing_methods_large.png";
    else if ([self.userDefine.name isEqualToString:SET_SPECIES])
        imageName = @"species_large.png";
    
    self.noXView.imageView.image = [UIImage imageNamed:imageName];
    self.noXView.titleView.text = [NSString stringWithFormat:@"%@.", self.userDefine.name];
    
    [self.noXView centerInParent:self.view navigationController:self.navigationController];
    [self.view addSubview:self.noXView];
}

- (void)handleNoXView {
    if ([self.userDefine count] <= 0)
        [self initNoXView];
    else {
        [self.noXView removeFromSuperview];
        self.noXView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.userDefine name]; // sets title according to the setting that was clicked in the previous view
    self.navigationController.toolbarHidden = NO;
    
    // used to populate cells
    if ([self.userDefine.objects count] <= 0)
        [self.editButton setEnabled:NO];
    
    self.isSelectingForAddEntry = (self.previousViewID == CMAViewControllerIDAddEntry);
    self.isSelectingMultiple = (self.isSelectingForAddEntry && [[self.userDefine name] isEqualToString:SET_FISHING_METHODS]);
    
    self.isSelectingForStatistics = (self.previousViewID == CMAViewControllerIDStatistics);
    
    // for selecting multiple fishing methods
    if (self.isSelectingMultiple)
        [self configureTableForMutipleSelection];
    
    [self initAddItemAlert];
    [self initEditItemAlert];
    [self initializeToolbar];
    
    // enable side bar navigation unless the user is adding an entry
    if (!self.isSelectingForAddEntry && !self.isSelectingForStatistics)
        [self initSideBarMenu];
    else
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self handleNoXView];
    [self.editButton setEnabled:[self.userDefine count] > 0];
    
    // show the toolbar when navigating back from a push segue
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if (self.isSelectingForStatistics)
        self.navigationController.toolbarHidden = YES;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Toolbar Initializing

- (void)initializeToolbar {
    // remove editing button for non-string defines
    if (![self.userDefine isSetOfStrings])
        self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clickEditButton:)];
    else
        self.editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(clickEditButton:)];
    
    NSMutableArray *barItems = [self.toolbarItems mutableCopy];
    [barItems insertObject:self.editButton atIndex:0];
    
    [self setToolbarItems:barItems];
}

#pragma mark - Table View Initializing

- (void)configureTableForMutipleSelection {
    [self toggleDoneSelectingButton:YES];
    [self.tableView setAllowsMultipleSelection:YES];
    [self setIsSelectingForAddEntry:YES];
}

// Hides/shows a checkmark inside aCell.
- (void)toggleCellAccessoryCheckmarkAtIndexPath: (NSIndexPath *)anIndexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:anIndexPath];

    if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
    else
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

// Sets each cell's selection style to selectionStyle.
- (void)toggleCellSelectionStyles: (UITableViewCellSelectionStyle)selectionStyle {
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell setSelectionStyle:selectionStyle];
    }
}

// Returns a string with all selected cell labels separated by a comma.
- (NSString *)stringFromSelectedCells {
    NSMutableString *result = [NSMutableString string];
    
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            [result appendFormat:@"%@%@", [cell.textLabel text], TOKEN_FISHING_METHODS];
    }
    
    // remove the last comma and space
    if (result.length > 0) {
        NSRange range;
        range.location = [result length] - 2;
        range.length = 2;
        [result replaceCharactersInRange:range withString:@""];
    }
    
    return result;
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
    cell.textLabel.text = [[self.userDefine.objects objectAtIndex:indexPath.item] name];
    
    // enable chevron for non-strings
    if (![self.userDefine isSetOfStrings] && !self.isSelectingForStatistics)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        if ((!self.isSelectingForAddEntry || self.isSelectingMultiple) && !self.tableView.editing)
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.item % 2 == 0)
        [cell setBackgroundColor:CELL_COLOR_DARK];
    else
        [cell setBackgroundColor:CELL_COLOR_LIGHT];
    
    return cell;
}

// NO NOT CHANGE ORDER OF IF STATEMENTS!
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelectingForStatistics) {
        self.selectedCellLabelText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        [self performSegueWithIdentifier:@"unwindToStatisticsFromUserDefines" sender:self];
        return;
    }
    
    // if it's a location
    if ([[self.userDefine name] isEqualToString:SET_LOCATIONS]) {
        self.selectedCellLabelText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];

        if (self.isSelectingForAddEntry)
            [self performSegueWithIdentifier:@"fromUserDefinesToSelectFishingSpot" sender:self];
        else
            [self performSegueWithIdentifier:@"fromUserDefinesToSingleLocation" sender:self];
    
        return;
    }
    
    // if in editing mode
    if (tableView.editing) {
        self.selectedCellLabelText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        [[self.editItemAlert textFieldAtIndex:0] setText:self.selectedCellLabelText];
        [self.editItemAlert show];
        return;
    }
    
    // if selecting multiple
    if (self.isSelectingMultiple) {
        [self toggleCellAccessoryCheckmarkAtIndexPath:indexPath];
        return;
    }
    
    // unwind if we're selecting for Add Entry
    if (self.isSelectingForAddEntry) {
        self.selectedCellLabelText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromEditSettings" sender:self];
        return;
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
        [[self journal] removeUserDefine:self.userDefine.name objectNamed:cell.textLabel.text];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([tableView numberOfRowsInSection:0] == 0) {
            [self toggleEditMode:YES];
            [self.editButton setEnabled:NO];
            [self initNoXView];
            [[self journal] archive];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Navigation Bar Manipulation

// Shows or hides the "Done Selecting" button in the UINavigationBar.
// Method is only used when selecting cells for the Add Entry view.
- (void)toggleDoneSelectingButton: (BOOL)show {
    // initialize button if it hasn't been already
    if (!self.doneSelectingButton)
        self.doneSelectingButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneSelectingButton)];
    
    if (show) {
        [self.navigationItem setRightBarButtonItem:self.doneSelectingButton];
        [self.doneSelectingButton setEnabled:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
        [self.doneSelectingButton setEnabled:NO];
    }
}

#pragma mark - Alert Views

- (void)initAddItemAlert {
    self.addItemAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add to %@:", [self.userDefine name]] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    self.addItemAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
}

- (void)initEditItemAlert {
    self.editItemAlert = [[UIAlertView alloc] initWithTitle:@"Edit Item" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    self.editItemAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
}

// handles all UIAlertViews results for this screen
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.addItemAlert)
        if (buttonIndex == 1) { // add button
            NSString *enteredText = [[alertView textFieldAtIndex:0] text];
            
            if ([enteredText isEqualToString:@""])
                return
                
            [[alertView textFieldAtIndex:0] setText:@""];
            
            [self.userDefine addObject:[self.userDefine emptyObjectNamed:enteredText]];
            [self handleNoXView];
            [[self journal] archive];
        }
    
    if (alertView == self.editItemAlert)
        if (buttonIndex == 1) { // ok button
            NSString *enteredText = [[alertView textFieldAtIndex:0] text];
            
            if ([enteredText isEqualToString:@""])
                return;
            
            id newProperties = [self.userDefine emptyObjectNamed:[[alertView textFieldAtIndex:0] text]];
            [[self journal] editUserDefine:[self.userDefine name] objectNamed:self.selectedCellLabelText newProperties:newProperties];
            [[self journal] archive];
        }
    
    [self.tableView reloadData];
}

#pragma mark - Events

- (void)enterEditMode {
    [self.tableView setEditing:YES animated:YES];
    [self.editButton setEnabled:NO];
    [self.addButton setEnabled:NO];
    
    // add a done button that will be used to exit editing mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if ([self.userDefine isSetOfStrings])
        [self toggleCellSelectionStyles:UITableViewCellSelectionStyleDefault];
    else
        [self.tableView setAllowsSelectionDuringEditing:NO];
}

- (void)exitEditMode {
    [self.tableView setEditing:NO animated:YES];
    [self.editButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    
    if (self.isSelectingMultiple)
        [self.doneSelectingButton setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = self.doneSelectingButton;
    
    [self toggleCellSelectionStyles:UITableViewCellSelectionStyleNone];
}

- (void)toggleEditMode: (BOOL)exiting {
    if (exiting)
        [self exitEditMode];
    else
        [self enterEditMode];
}

- (IBAction)clickAddButton:(UIBarButtonItem *)sender {
    if ([[self.userDefine name] isEqualToString:SET_LOCATIONS])
        [self performSegueWithIdentifier:@"fromEditSettingsToAddLocation" sender:self];
    else {
        [[self.addItemAlert textFieldAtIndex:0] setText:@""];
        [self.addItemAlert show];
    }
}

// Enter editing mode.
- (IBAction)clickEditButton:(UIBarButtonItem *)sender {
    [self toggleEditMode:NO];
}

- (void)clickDoneSelectingButton {
    self.selectedCellLabelText = [self stringFromSelectedCells];
    [self performSegueWithIdentifier:@"unwindToAddEntryFromEditSettings" sender:self];
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self toggleEditMode:YES];
    [[self journal] archive];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromEditSettingsToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDEditSettings;
    }
    
    if ([segue.identifier isEqualToString:@"fromUserDefinesToSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMALocation *loc = [[[self journal] userDefineNamed:SET_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
        destination.navigationItem.title = loc.name;
    }
    
    if ([segue.identifier isEqualToString:@"fromUserDefinesToSingleLocation"]) {
        CMASingleLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMALocation *loc = [[[self journal] userDefineNamed:SET_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
        destination.navigationItem.title = loc.name;
    }
}

- (IBAction)unwindToEditSettings:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
}

@end
