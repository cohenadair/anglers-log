//
//  CMAViewEntriesViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAViewEntriesViewController.h"
#import "CMAAddEntryViewController.h"
#import "CMAAppDelegate.h"

@interface CMAViewEntriesViewController ()

@end

@implementation CMAViewEntriesViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
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
    
    CMAEntry *entry = [[self journal] entryAtIndex:indexPath.item];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    cell.textLabel.text = entry.fishSpecies;
    cell.detailTextLabel.text = [dateFormatter stringFromDate:entry.date];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    if ([entry.images count] > 0)
        cell.imageView.image = [entry.images anyObject];
    else
        cell.imageView.image = [UIImage imageNamed:@"no-image.png"];
    
    return cell;
}

- (void) tableView:(UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromViewEntriesToSingleEntry" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_ViewEntries;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    
}

@end
