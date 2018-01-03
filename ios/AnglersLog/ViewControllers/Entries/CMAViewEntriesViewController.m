//
//  CMAViewEntriesViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAAlerts.h"
#import "CMASingleEntryViewController.h"
#import "CMAStorageManager.h"
#import "CMAThumbnailCell.h"
#import "CMATouchSegmentedControl.h"
#import "CMAUtilities.h"
#import "CMAViewEntriesViewController.h"
#import "SWRevealViewController.h"

@interface CMAViewEntriesViewController () <CMATableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (strong, nonatomic)NSMutableOrderedSet<CMAEntry *> *entries;

@end

@implementation CMAViewEntriesViewController

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
    
    self.noXView.imageView.image = [UIImage imageNamed:@"entries_large.png"];
    self.noXView.titleView.text = @"Entries.";
    
    self.quantityTitleText = @"Entries";
    self.searchBarPlaceholder = @"Search entries";
    
    [self setupTableViewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initSideBarMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sortButton.enabled = self.deleteButton.enabled = self.tableViewRowCount > 0;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CMAThumbnailCell.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMAThumbnailCell *cell = [CMAThumbnailCell forTableView:tableView indexPath:indexPath];
    [cell setEntry:self.entries[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromViewEntriesToSingleEntry" sender:self];
}

#pragma mark - Events

- (void)enableToolbarButtons {
    [self.tableView setEditing:NO animated:YES];
    [self.deleteButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    [self.sortButton setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)disableToolbarButtons {
    [self.tableView setEditing:YES animated:YES];
    [self.deleteButton setEnabled:NO];
    [self.addButton setEnabled:NO];
    [self.sortButton setEnabled:NO];
    
    // add a done button that will be used to exit editing mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)clickDeleteButton:(UIBarButtonItem *)sender {
    [self disableToolbarButtons];
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self enableToolbarButtons];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDViewEntries;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewEntriesToSingleEntry"]) {
        CMASingleEntryViewController *destination = segue.destinationViewController;
        CMAEntry *entryToDisplay = [[[self journal] entries] objectAtIndex:[self.tableView indexPathForSelectedRow].item];
        destination.entry = entryToDisplay;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
}

#pragma mark - CMASearchTableViewDelegate

- (void)filterTableViewData:(NSString *)searchText {
    self.entries = [self.journal filterEntries:searchText];
}

- (void)setupTableViewData {
    self.entries = self.journal.entries;
}

- (NSInteger)tableViewRowCount {
    return self.entries.count;
}

- (NSInteger)unfilteredTableViewRowCount {
    return self.journal.entries.count;
}

- (void)onDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.journal removeEntryDated:self.entries[indexPath.row].date];
}

- (void)didDeleteLastItem {
    [self enableToolbarButtons];
    self.deleteButton.enabled = NO;
    self.sortButton.enabled = NO;
}

@end
