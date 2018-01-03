//
//  CMAViewBaitsViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAppDelegate.h"
#import "CMAAddBaitViewController.h"
#import "CMASingleBaitViewController.h"
#import "CMAStorageManager.h"
#import "CMAThumbnailCell.h"
#import "CMAUtilities.h"
#import "CMAViewBaitsViewController.h"
#import "SWRevealViewController.h"
#import "UIView+CMAConstraints.h"

@interface CMAViewBaitsViewController () <CMATableViewControllerDelegate>

@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic)NSOrderedSet<CMABait *> *baits;

@end

@implementation CMAViewBaitsViewController

#pragma mark - Accessing Helpers

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
    
    self.noXView.imageView.image = [UIImage imageNamed:@"baits_large.png"];
    self.noXView.titleView.text = @"Baits.";
    
    self.quantityTitleText = @"Baits";
    self.searchBarPlaceholder = @"Search baits";
    
    [self setupTableViewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    if (!self.isSelectingForAddEntry && !self.isSelectingForStatistics)
        [self initSideBarMenu];
    else
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.deleteButton.enabled = self.tableViewRowCount > 0;
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if (self.isSelectingForStatistics)
        self.navigationController.toolbarHidden = YES;
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CMAThumbnailCell.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMAThumbnailCell *cell = [CMAThumbnailCell forTableView:tableView indexPath:indexPath];
    BOOL hideAccessory = self.isSelectingForAddEntry || self.isSelectingForStatistics;
    [cell setBait:self.baits[indexPath.row] hideAccessory:hideAccessory];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelectingForAddEntry) {
        self.baitForAddEntry = self.baits[indexPath.row];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromViewBaits" sender:self];
        return;
    }
    
    if (self.isSelectingForStatistics) {
        self.baitNameForStatistics = self.baits[indexPath.row].name;
        [self performSegueWithIdentifier:@"unwindToStatisticsFromViewBaits" sender:self];
        return;
    }
    
    [self performSegueWithIdentifier:@"fromViewBaitsToSingleBait" sender:self];
}

#pragma mark - Events

- (void)exitEditMode {
    [self.tableView setEditing:NO animated:YES];
    self.deleteButton.enabled = self.tableViewRowCount > 0;
    self.addButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)enterEditMode {
    [self.tableView setEditing:YES animated:YES];
    [self.deleteButton setEnabled:NO];
    [self.addButton setEnabled:NO];
    
    // reveal a done button for exiting edit mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(tapDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)tapDeleteButton:(UIBarButtonItem *)sender {
    [self enterEditMode];
}

- (void)tapDoneButton {
    [self exitEditMode];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewBaitsToAddBait"]) {
        CMAAddBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDViewBaits;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewBaitsToSingleBait"]) {
        CMASingleBaitViewController *destination = segue.destinationViewController;
        destination.bait = self.baits[self.tableView.indexPathForSelectedRow.row];
    }
}

- (IBAction)unwindToViewBaits:(UIStoryboardSegue *)segue {
}

#pragma mark - CMASearchTableViewDelegate

- (void)filterTableViewData:(NSString *)searchText {
    self.baits = [self.journal filterBaits:searchText];
}

- (void)setupTableViewData {
    self.baits = [self.journal userDefineNamed:UDN_BAITS].baits;
}

- (NSInteger)tableViewRowCount {
    return self.baits.count;
}

- (NSInteger)unfilteredTableViewRowCount {
    return self.journal.baits.count;
}

- (void)onDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.journal removeUserDefine:UDN_BAITS objectNamed:self.baits[indexPath.row].name];
}

- (void)didDeleteLastItem {
    [self exitEditMode];
}

@end
