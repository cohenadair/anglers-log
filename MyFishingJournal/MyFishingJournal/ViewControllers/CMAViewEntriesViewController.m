//
//  CMAViewEntriesViewController.m
//  MyFishingJournal
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
#import "SWRevealViewController.h"

@interface CMAViewEntriesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet CMATouchSegmentedControl *organizeControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)UIActionSheet *sortActionSheet;

@end

@implementation CMAViewEntriesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;

    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    if ([[self journal] entryCount] <= 0)
        [self.deleteButton setEnabled:NO];
    
    [self initSortActionSheet];
    [self initSideBarMenu];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
    [self resetOrganizeControl];
    
    if ([[self journal] entryCount] > 0)
        self.deleteButton.enabled = YES;
    
    [self.tableView reloadData];
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
    cell.locationLabel.text = [NSString stringWithFormat:@"%@: %@", entry.location.name, entry.fishingSpot.name];
    
    if ([entry.images count] > 0)
        cell.thumbImage.image = [entry.images anyObject];
    else
        cell.thumbImage.image = [UIImage imageNamed:@"no-image.png"];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        CMAEntryTableViewCell *cell = (CMAEntryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [[self journal] removeEntryDated:[self.dateFormatter dateFromString:cell.dateLabel.text]];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([tableView numberOfRowsInSection:0] == 0) {
            [self enableToolbarButtons];
            [self.deleteButton setEnabled:NO];
            [self resetOrganizeControl];
        }
    }
}

#pragma mark - Action Sheet Delegate

- (void)initSortActionSheet {
    self.sortActionSheet = [UIActionSheet new];
    self.sortActionSheet = [self.sortActionSheet initWithTitle:@"Sort By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date", @"Species", @"Location", @"Length", @"Weight", @"Bait Used", nil];
}

- (void)sortActionSheetButtonClick: (NSInteger)buttonIndex {
    NSString *sortTitle = [self.organizeControl titleForSegmentAtIndex:0];
    
    switch (buttonIndex) {
        case 0:
            // date
            NSLog(@"Clicked date.");
            sortTitle = @"Sort By: Date";
            break;
            
        case 1:
            // species
            NSLog(@"Clicked species.");
            sortTitle = @"Sort By: Species";
            break;
            
        case 2:
            // location
            NSLog(@"Clicked location.");
            sortTitle = @"Sort By: Location";
            break;
            
        case 3:
            // length
            NSLog(@"Clicked length.");
            sortTitle = @"Sort By: Length";
            break;
            
        case 4:
            // weight
            NSLog(@"Clicked weight.");
            sortTitle = @"Sort By: Weight";
            break;
            
        case 5:
            // bait used
            NSLog(@"Clicked bait used.");
            sortTitle = @"Sort By: Bait Used";
            break;
            
        default:
            NSLog(@"Invalid action sheet button index.");
            break;
    }
    
    [self.organizeControl setTitle:sortTitle forSegmentAtIndex:0];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.sortActionSheet)
        [self sortActionSheetButtonClick:buttonIndex];
}

#pragma mark - Events

- (void)enableToolbarButtons {
    [self.tableView setEditing:NO animated:YES];
    [self.deleteButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    [self.organizeControl setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)disableToolbarButtons {
    [self.tableView setEditing:YES animated:YES];
    [self.deleteButton setEnabled:NO];
    [self.addButton setEnabled:NO];
    [self.organizeControl setEnabled:NO];
    
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

- (IBAction)selectedOrganizeControl:(CMATouchSegmentedControl *)sender {
    if ([sender selectedSegmentIndex] == 0)
        [self.sortActionSheet showInView:self.view];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_ViewEntries;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewEntriesToSingleEntry"]) {
        CMASingleEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMAEntry *entryToDisplay = [[[self journal] entries] objectAtIndex:[self.tableView indexPathForSelectedRow].item];
        destination.entry = entryToDisplay;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Organize Segmented Control

- (void)resetOrganizeControl {
    [self.organizeControl setEnabled:[[self journal] entryCount] > 0];
    [self.organizeControl setSelectedSegmentIndex:-1];
    [self.organizeControl setTitle:@"Sort" forSegmentAtIndex:0];
}

@end
