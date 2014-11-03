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
#import "CMAAppDelegate.h"

@interface CMAViewEntriesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic)NSArray *entriesArray;
@property (strong, nonatomic)NSDateFormatter *dateFormatter;

@end

@implementation CMAViewEntriesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    [self setEntriesArray:[[self journal].entries allObjects]];
    if ([self.entriesArray count] <= 0)
        [self.deleteButton setEnabled:NO];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = NO;
    
    [self setEntriesArray:[[self journal].entries allObjects]];
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
    // Return the number of rows in the section.
    return [[self journal] entryCount];
}

// Sets the height of each cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entriesCell" forIndexPath:indexPath];
    
    CMAEntry *entry = [self.entriesArray objectAtIndex:indexPath.item];
    
    cell.textLabel.text = [entry.fishSpecies name];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:entry.date];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    if ([entry.images count] > 0)
        cell.imageView.image = [entry.images anyObject];
    else
        cell.imageView.image = [UIImage imageNamed:@"no-image.png"];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[self journal] removeEntryDated:[self.dateFormatter dateFromString:cell.detailTextLabel.text]];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([tableView numberOfRowsInSection:0] == 0) {
            [self toggleEditButtons:YES];
            [self.deleteButton setEnabled:NO];
        }
    }
}

#pragma mark - Events

- (void)toggleEditButtons: (BOOL)enable {
    if (enable) {
        [self.tableView setEditing:NO animated:YES];
        [self.deleteButton setEnabled:YES];
        [self.addButton setEnabled:YES];
        
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self.tableView setEditing:YES animated:YES];
        [self.deleteButton setEnabled:NO];
        [self.addButton setEnabled:NO];
        
        // add a done button that will be used to exit editing mode
        UIBarButtonItem *doneButton = [UIBarButtonItem new];
        doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (IBAction)clickDeleteButton:(UIBarButtonItem *)sender {
    [self toggleEditButtons:NO];
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self toggleEditButtons:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_ViewEntries;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewEntriesToSingleEntry"]) {
        CMASingleEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMAEntry *entryToDisplay = [self.entriesArray objectAtIndex:[self.tableView indexPathForSelectedRow].item];
        destination.entry = entryToDisplay;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
}

@end
