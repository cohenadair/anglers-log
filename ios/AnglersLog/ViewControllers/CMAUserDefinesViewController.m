//
//  CMAEditSettingsViewController.m
//  AnglersLog
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
#import "UIColor+CMA.h"

@interface CMAUserDefinesViewController () <CMATableViewControllerDelegate>

@property (strong, nonatomic)UIBarButtonItem *doneSelectingButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic)UIAlertController *addItemAlert;
@property (strong, nonatomic)UIAlertController *editItemAlert;

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingMultiple;
@property (nonatomic)BOOL isSelectingForStatistics;

@property (strong, nonatomic) NSOrderedSet<CMAUserDefineObject *> *userDefineObjects;

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

- (void)setupView {
    self.delegate = self;
    
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
    
    self.quantityTitleText = self.userDefine.name;
    self.searchBarPlaceholder = [NSString stringWithFormat:@"Search %@",
            self.userDefine.name.lowercaseString];
    
    [self setupTableViewData];
}

- (void)setupEditButton {
    self.deleteButton.enabled = self.tableViewRowCount > 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    self.isSelectingForAddEntry = (self.previousViewID == CMAViewControllerIDAddEntry);
    self.isSelectingMultiple = (self.isSelectingForAddEntry && [[self.userDefine name] isEqualToString:UDN_FISHING_METHODS]);
    
    self.isSelectingForStatistics = (self.previousViewID == CMAViewControllerIDStatistics);
    
    // for selecting multiple fishing methods
    if (self.isSelectingMultiple)
        [self configureTableForMutipleSelection];
    
    [self initAddItemAlert];
    [self initEditItemAlert];
    
    // enable side bar navigation unless the user is adding an entry
    if (!self.isSelectingForAddEntry && !self.isSelectingForStatistics)
        [self initSideBarMenu];
    else
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupEditButton];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if (self.isSelectingForStatistics)
        self.navigationController.toolbarHidden = YES;
}

#pragma mark - Table View Initializing

- (void)configureTableForMutipleSelection {
    [self toggleDoneSelectingButton:YES];
    [self.tableView setAllowsMultipleSelection:YES];
    [self setIsSelectingForAddEntry:YES];
    
    if (!self.selectedCellsArray)
        [self setSelectedCellsArray:[NSMutableArray array]];
}

- (void)setCell:(UITableViewCell *)cell selected:(BOOL)selected {
    if (selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = UIColor.anglersLogLightTransparent;
        if (![self.selectedCellsArray containsObject:cell.textLabel.text]) {
            [self.selectedCellsArray addObject:cell.textLabel.text];
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = UIColor.clearColor;
        [self.selectedCellsArray removeObject:cell.textLabel.text];
    }
    
    // Override global selection background view settings. This allows multiple selection to work
    // since it's done manually rather than through the built in UITableView selection.
    UIView *view = UIView.new;
    view.backgroundColor = UIColor.clearColor;
    cell.multipleSelectionBackgroundView = view;
}

// Hides/shows a checkmark inside aCell.
- (void)toggleCellAccessoryCheckmarkAtIndexPath: (NSIndexPath *)anIndexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:anIndexPath];
    [self setCell:selectedCell selected:selectedCell.accessoryType == UITableViewCellAccessoryNone];
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

// Initialize each cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:@"defaultCell"];
    cell.textLabel.text = self.userDefineObjects[indexPath.row].name;
    
    // enable chevron for non-strings
    if (![self.userDefine isSetOfStrings] && !self.isSelectingForStatistics) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (self.isSelectingMultiple) {
        [self setCell:cell selected:[self.selectedCellsArray containsObject:cell.textLabel.text]];
    }
    
    return cell;
}

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
    
    // if we just want to edit.
    self.selectedCellLabelText = self.userDefineObjects[indexPath.row].name;
    self.editItemAlert.textFields[0].text = self.selectedCellLabelText;
    [self presentViewController:self.editItemAlert animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // if selecting multiple
    if (self.isSelectingMultiple) {
        [self toggleCellAccessoryCheckmarkAtIndexPath:indexPath];
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
    self.addItemAlert =
        [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Add to %@:", [self.userDefine name]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self.addItemAlert addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *cancel =
        [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *add =
        [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self onClickNewDone]; }];
    
    [self.addItemAlert addAction:cancel];
    [self.addItemAlert addAction:add];
}

- (void)initEditItemAlert {
    self.editItemAlert =
        [UIAlertController alertControllerWithTitle:@"Edit Item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self.editItemAlert addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
            handler:^(UIAlertAction *action) {
                [self onClickEditCancel];
            }];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self onClickEditDone];
            }];
    
    [self.editItemAlert addAction:cancel];
    [self.editItemAlert addAction:done];
}

- (void)onClickNewDone {
    NSString *enteredText = [[[self.addItemAlert textFields] objectAtIndex:0] text];
    
    if ([enteredText isEqualToString:@""])
        return;
    
    [[[self.addItemAlert textFields] objectAtIndex:0] setText:@""];
    
    id objectToAdd = [self.userDefine emptyObjectNamed:enteredText];
    
    if (![[self journal] addUserDefine:self.userDefine.name objectToAdd:objectToAdd notify:YES]) {
        [self showItemExistsAlert];
        [[CMAStorageManager sharedManager] deleteManagedObject:objectToAdd saveContext:YES];
        return;
    }
}

- (void)onClickEditDone {
    NSString *oldName = self.selectedCellLabelText;
    NSString *newName = [[[self.editItemAlert textFields] objectAtIndex:0] text];
    
    // if nothing was entered
    if ([newName isEqualToString:@""])
        return;
    
    // if no changes were made
    if ([oldName isEqualToString:newName])
        return;
    
    // if the new name is a duplicate name
    if ([[[self journal] userDefineNamed:self.userDefine.name] objectNamed:newName]) {
        [self showItemExistsAlert];
        return;
    }
    
    // if the new name is valid
    id newObj = [self.userDefine emptyObjectNamed:newName];
    [[self journal] editUserDefine:self.userDefine.name
                       objectNamed:oldName
                     newProperties:newObj
                            notify:YES];
}

- (void)onClickEditCancel {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)showItemExistsAlert {
    [CMAAlerts errorAlert:@"An item that name already exists. Please select a new item or edit the existing item." presentationViewController:self];
}

#pragma mark - Events

- (void)enterEditMode {
    [self.tableView setEditing:YES animated:YES];
    self.deleteButton.enabled = NO;
    self.addButton.enabled = NO;
    
    // add a done button that will be used to exit editing mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)exitEditMode {
    [self.tableView setEditing:NO animated:YES];
    self.deleteButton.enabled = self.tableViewRowCount > 0;
    self.addButton.enabled = YES;
    
    if (self.isSelectingMultiple)
        [self.doneSelectingButton setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = self.doneSelectingButton;
}

- (void)toggleEditMode:(BOOL)exiting {
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
- (IBAction)clickDeleteButton:(UIBarButtonItem *)sender {
    [self toggleEditMode:NO];
}

- (void)clickDoneSelectingButton {
    self.selectedCellLabelText = [self stringFromSelectedCells];
    [self performSegueWithIdentifier:@"unwindToAddEntryFromEditSettings" sender:self];
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self toggleEditMode:YES];
}

- (void)reloadData {
    [super reloadData];
    [self setupEditButton];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromEditSettingsToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDEditSettings;
    }
    
    if ([segue.identifier isEqualToString:@"fromUserDefinesToSelectFishingSpot"]) {
        CMASelectFishingSpotViewController *destination = segue.destinationViewController;
        CMALocation *loc = [[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
    }
    
    if ([segue.identifier isEqualToString:@"fromUserDefinesToSingleLocation"]) {
        CMASingleLocationViewController *destination = segue.destinationViewController;
        CMALocation *loc = [[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.selectedCellLabelText];
        destination.location = loc;
        destination.previousViewID = CMAViewControllerIDEditSettings;
    }
}

- (IBAction)unwindToEditSettings:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - CMASearchTableViewDelegate

- (void)filterTableViewData:(NSString *)searchText {
    self.userDefineObjects = [self.userDefine search:searchText];
}

- (void)setupTableViewData {
    self.userDefineObjects = self.userDefine.activeSet;
}

- (NSInteger)tableViewRowCount {
    return self.userDefineObjects.count;
}

- (void)onDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.journal removeUserDefine:self.userDefine.name
                       objectNamed:self.userDefineObjects[indexPath.row].name];
}

- (void)didDeleteLastItem {
    [self toggleEditMode:YES];
}

@end
