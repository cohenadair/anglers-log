//
//  CMAEditSettingsViewController.m
//  TheAnglersLog
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
#import "CMAStorageManager.h"
#import "CMAAlerts.h"

@interface CMAUserDefinesViewController ()

@property (strong, nonatomic)UIBarButtonItem *editButton;
@property (strong, nonatomic)UIBarButtonItem *doneSelectingButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic)UIAlertController *addItemAlert;
@property (strong, nonatomic)UIAlertController *editItemAlert;
@property (strong, nonatomic)CMANoXView *noXView;

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingMultiple;
@property (nonatomic)BOOL isSelectingForStatistics;

@end

@implementation CMAUserDefinesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
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
    
    if ([self.userDefine.name isEqualToString:UDN_LOCATIONS])
        imageName = @"locations_large.png";
    else if ([self.userDefine.name isEqualToString:UDN_FISHING_METHODS])
        imageName = @"fishing_methods_large.png";
    else if ([self.userDefine.name isEqualToString:UDN_SPECIES])
        imageName = @"species_large.png";
    else if ([self.userDefine.name isEqualToString:UDN_WATER_CLARITIES])
        imageName = @"water_clarities_large.png";
    
    self.noXView.imageView.image = [UIImage imageNamed:imageName];
    self.noXView.titleView.text = [NSString stringWithFormat:@"%@.", self.userDefine.name];
    
    [self.noXView centerInParent:self.view];
    [self.noXView setAlpha:0.0f];
    [self.view addSubview:self.noXView];
}

- (void)handleNoXView {
    if (!self.noXView)
        [self initNoXView];
    
    if ([self.userDefine count] <= 0) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.noXView setAlpha:1.0f];
        }];
        
        [self.editButton setEnabled:NO];
    } else {
        [self.editButton setEnabled:YES];
        [self.noXView setAlpha:0.0f];
    }
}

- (void)setupView {
    [self handleNoXView];
    [self.editButton setEnabled:[self.userDefine count] > 0];
    
    // show the toolbar when navigating back from a push segue
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if (self.isSelectingForStatistics)
        self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.userDefine name]; // sets title according to the setting that was clicked in the previous view
    self.navigationController.toolbarHidden = NO;
    
    // used to populate cells
    if ([self.userDefine count] <= 0)
        [self.editButton setEnabled:NO];
    
    self.isSelectingForAddEntry = (self.previousViewID == CMAViewControllerIDAddEntry);
    self.isSelectingMultiple = (self.isSelectingForAddEntry && [[self.userDefine name] isEqualToString:UDN_FISHING_METHODS]);
    
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
    [self setupView];
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
    
    if (!self.selectedCellsArray)
        [self setSelectedCellsArray:[NSMutableArray array]];
}

// Hides/shows a checkmark inside aCell.
- (void)toggleCellAccessoryCheckmarkAtIndexPath: (NSIndexPath *)anIndexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:anIndexPath];

    if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
        [self.selectedCellsArray removeObject:selectedCell.textLabel.text];
    } else {
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.selectedCellsArray addObject:selectedCell.textLabel.text];
    }
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
    
    for (int i = 0; i < [self.selectedCellsArray count]; i++) {
        [result appendFormat:@"%@%@", [self.selectedCellsArray objectAtIndex:i], TOKEN_FISHING_METHODS];
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
    cell.textLabel.text = [[self.userDefine objectAtIndex:indexPath.row] name];
    
    // enable chevron for non-strings
    if (![self.userDefine isSetOfStrings] && !self.isSelectingForStatistics)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        if ((!self.isSelectingForAddEntry || self.isSelectingMultiple) && !self.tableView.editing)
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.isSelectingMultiple) {
        if ([self.selectedCellsArray containsObject:cell.textLabel.text])
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
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
    if ([[self.userDefine name] isEqualToString:UDN_LOCATIONS]) {
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
        [[[self.editItemAlert textFields] objectAtIndex:0] setText:self.selectedCellLabelText];
        [self presentViewController:self.editItemAlert animated:YES completion:nil];
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
    if (self.isSelectingMultiple) {
        [self toggleCellAccessoryCheckmarkAtIndexPath:indexPath];
    }
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
            [self handleNoXView];
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
    self.addItemAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Add to %@:", [self.userDefine name]]
                                                            message:nil
                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [self.addItemAlert addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *cancel =
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *add =
        [UIAlertAction actionWithTitle:@"Add"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                        NSString *enteredText = [[[self.addItemAlert textFields] objectAtIndex:0] text];
                                                    
                                        if ([enteredText isEqualToString:@""])
                                            return;
                                        
                                        [[[self.addItemAlert textFields] objectAtIndex:0] setText:@""];
                                   
                                        id objectToAdd = [self.userDefine emptyObjectNamed:enteredText];
                                   
                                        if (![[self journal] addUserDefine:self.userDefine.name objectToAdd:objectToAdd]) {
                                            [CMAAlerts errorAlert:@"An item that name already exists. Please select a new item or edit the existing item." presentationViewController:self];
                                            [[CMAStorageManager sharedManager] deleteManagedObject:objectToAdd];
                                            return;
                                        }
                                   
                                        [[self journal] archive];
                                        [self.tableView reloadData];
                                        
                                        [self handleNoXView];
                               }];
    
    [self.addItemAlert addAction:cancel];
    [self.addItemAlert addAction:add];
}

- (void)initEditItemAlert {
    self.editItemAlert = [UIAlertController alertControllerWithTitle:@"Edit Item"
                                                             message:nil
                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [self.editItemAlert addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *cancel =
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *done =
        [UIAlertAction actionWithTitle:@"Done"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                        NSString *enteredText = [[[self.editItemAlert textFields] objectAtIndex:0] text];
                                   
                                        if ([enteredText isEqualToString:@""])
                                            return;
                                         
                                        id newProperties = [self.userDefine emptyObjectNamed:[[[self.editItemAlert textFields] objectAtIndex:0] text]];
                                        [[self journal] editUserDefine:[self.userDefine name] objectNamed:self.selectedCellLabelText newProperties:newProperties];
                                        [[CMAStorageManager sharedManager] deleteManagedObject:newProperties];
                                         
                                        [self.tableView reloadData];
                               }];
    
    [self.editItemAlert addAction:cancel];
    [self.editItemAlert addAction:done];
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
    if ([[self.userDefine name] isEqualToString:UDN_LOCATIONS])
        [self performSegueWithIdentifier:@"fromEditSettingsToAddLocation" sender:self];
    else {
        [[[self.addItemAlert textFields] objectAtIndex:0] setText:@""];
        [self presentViewController:self.addItemAlert animated:YES completion:nil];
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
        CMALocation *loc = [[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
        destination.navigationItem.title = loc.name;
    }
    
    if ([segue.identifier isEqualToString:@"fromUserDefinesToSingleLocation"]) {
        CMASingleLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMALocation *loc = [[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
        destination.navigationItem.title = loc.name;
    }
}

- (IBAction)unwindToEditSettings:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
    [self.tableView reloadData];
}

@end
