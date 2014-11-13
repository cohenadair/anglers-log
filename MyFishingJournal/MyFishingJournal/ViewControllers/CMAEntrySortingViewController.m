//
//  CMAEntrySortingViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/13/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEntrySortingViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAlerts.h"

@interface CMAEntrySortingViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortOrderControl;

@property (nonatomic)CMAEntrySortMethod sortMethod;
@property (nonatomic)CMASortOrder sortOrder;

@end

@implementation CMAEntrySortingViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSortMethod:[[self journal] entrySortMethod]];
    [self setSortOrder:[[self journal] entrySortOrder]];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self selectSortMethodCell];
    [self.sortOrderControl setSelectedSegmentIndex:self.sortOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (void)selectSortMethodCell {
    // select current sort method
    NSIndexPath *sortMethodIndexPath = [NSIndexPath indexPathForItem:self.sortMethod inSection:0];
    UITableViewCell *sortMethodCell = [self.tableView cellForRowAtIndexPath:sortMethodIndexPath];
    [self.tableView selectRowAtIndexPath:sortMethodIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    sortMethodCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Events

- (IBAction)clickedCancalButton:(UIBarButtonItem *)sender {
    self.sortMethod = CMAEntrySortMethod_Nil;
    [self performUnwindToViewEntriesSegue];
}

- (IBAction)clickedDoneButton:(UIBarButtonItem *)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath == nil) {
        [CMAAlerts errorAlert:@"Please select a sort method."];
        return;
    }
    
    [self setSortMethod:selectedIndexPath.item];
    [self setSortOrder:(CMASortOrder)[self.sortOrderControl selectedSegmentIndex]];
    [[self journal] sortEntriesBy:self.sortMethod order:self.sortOrder];
    
    [self performUnwindToViewEntriesSegue];
}

#pragma mark - Navigation

- (void)performUnwindToViewEntriesSegue {
    [self performSegueWithIdentifier:@"unwindToViewEntriesFromEntrySorting" sender:self];
}

@end
