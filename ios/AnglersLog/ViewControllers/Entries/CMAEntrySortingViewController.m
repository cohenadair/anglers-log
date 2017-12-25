//
//  CMAEntrySortingViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/13/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAlerts.h"
#import "CMAAppDelegate.h"
#import "CMAEntrySortingViewController.h"
#import "CMAStorageManager.h"
#import "UIColor+CMA.h"

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
    return [[CMAStorageManager sharedManager] sharedJournal];
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
    [self.sortOrderControl setSelectedSegmentIndex:self.sortOrder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView selectRowAtIndexPath:self.sortMethodIndexPath
                                animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // Clear the "hacked" solution to show the current selection right away.
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.sortMethodIndexPath];
    cell.backgroundColor = UIColor.clearColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (NSIndexPath *)sortMethodIndexPath {
    return [NSIndexPath indexPathForItem:self.sortMethod inSection:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.backgroundColor = UIColor.clearColor;

    // A hack to show the selection right away.
    if (indexPath.row == self.sortMethod) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = UIColor.anglersLogLightTransparent;
    }
    
    return cell;
}

#pragma mark - Events

- (IBAction)clickedCancalButton:(UIBarButtonItem *)sender {
    self.sortMethod = CMAEntrySortMethodNil;
    [self performUnwindToViewEntriesSegue];
}

- (IBAction)clickedDoneButton:(UIBarButtonItem *)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath == nil) {
        [CMAAlerts errorAlert:@"Please select a sort method." presentationViewController:self];
        return;
    }
    
    // sort the journal's entries
    [self setSortMethod:selectedIndexPath.item];
    [self setSortOrder:(CMASortOrder)[self.sortOrderControl selectedSegmentIndex]];
    [[self journal] sortEntriesBy:self.sortMethod order:self.sortOrder];
    [[self journal] archive];
    
    [self performUnwindToViewEntriesSegue];
}

#pragma mark - Navigation

- (void)performUnwindToViewEntriesSegue {
    [self performSegueWithIdentifier:@"unwindToViewEntriesFromEntrySorting" sender:self];
}

@end
