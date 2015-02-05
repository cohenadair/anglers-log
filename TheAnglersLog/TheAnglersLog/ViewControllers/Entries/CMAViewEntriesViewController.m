//
//  CMAViewEntriesViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAViewEntriesViewController.h"
#import "CMAAddEntryViewController.h"
#import "CMASingleEntryViewController.h"
#import "CMATouchSegmentedControl.h"
#import "CMAEntryTableViewCell.h"
#import "CMAAppDelegate.h"
#import "CMANoXView.h"
#import "SWRevealViewController.h"
#import "CMAStorageManager.h"
#import "CMAAlerts.h"

@interface CMAViewEntriesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)CMANoXView *noEntriesView;

@end

@implementation CMAViewEntriesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

- (CMAAppDelegate *)appDelegate {
    return (CMAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoEntriesView {
    self.noEntriesView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noEntriesView.imageView.image = [UIImage imageNamed:@"entries_large.png"];
    self.noEntriesView.titleView.text = @"Entries.";
    
    [self.noEntriesView centerInParent:self.view navigationController:self.navigationController];
    [self.noEntriesView setAlpha:0.0f];
    [self.view addSubview:self.noEntriesView];
}

- (void)handleNoEntriesView {
    if (!self.noEntriesView)
        [self initNoEntriesView];
    
    if ([[self journal] entryCount] <= 0)
        [UIView animateWithDuration:0.5 animations:^{
            [self.noEntriesView setAlpha:1.0f];
        }];
    else
        [UIView animateWithDuration:0.5 animations:^{
            [self.noEntriesView setAlpha:0.0f];
        }];
}

- (void)setupView {
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if ([[self journal] entryCount] > 0) {
        self.deleteButton.enabled = YES;
        self.sortButton.enabled = YES;
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Entries (%ld)", (long)[[self journal] entryCount]];
    
    [self handleNoEntriesView];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Entries" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    if ([[self journal] entryCount] <= 0) {
        [self.deleteButton setEnabled:NO];
        [self.sortButton setEnabled:NO];
    }
    
    [self initSideBarMenu];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self journal] entryCount];
}

// Sets the height of each cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMAEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entriesCell" forIndexPath:indexPath];
    
    CMAEntry *entry = [[[self journal] entries] objectAtIndex:indexPath.item];
    
    cell.speciesLabel.text = [entry.fishSpecies name];
    cell.dateLabel.text = [self.dateFormatter stringFromDate:entry.date];
    
    if (entry.location)
        cell.locationLabel.text = [entry locationAsString];
    else
        cell.locationLabel.text = @"No Location";
    
    if ([entry.images count] > 0)
        cell.thumbImage.image = [[entry.images objectAtIndex:0] dataAsUIImage];
    else
        cell.thumbImage.image = [UIImage imageNamed:@"no_image.png"];
    
    if (indexPath.item % 2 == 0)
        [cell setBackgroundColor:CELL_COLOR_DARK];
    else
        [cell setBackgroundColor:CELL_COLOR_LIGHT];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"fromViewEntriesToSingleEntry" sender:self];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        CMAEntryTableViewCell *cell = (CMAEntryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [[self journal] removeEntryDated:[self.dateFormatter dateFromString:cell.dateLabel.text]];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.navigationItem.title = [NSString stringWithFormat:@"Entries (%ld)", (long)[[self journal] entryCount]];
        
        if ([tableView numberOfRowsInSection:0] == 0) {
            [self enableToolbarButtons];
            [self handleNoEntriesView];
            [self.deleteButton setEnabled:NO];
            [self.sortButton setEnabled:NO];
        }
    }
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
    [[self journal] archive];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDViewEntries;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewEntriesToSingleEntry"]) {
        CMASingleEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMAEntry *entryToDisplay = [[[self journal] entries] objectAtIndex:[self.tableView indexPathForSelectedRow].item];
        destination.entry = entryToDisplay;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToViewEntriesFromEntrySorting"]) {
        // reload data to show the newly sorted array
        [self.tableView reloadData];
    }
}

@end
