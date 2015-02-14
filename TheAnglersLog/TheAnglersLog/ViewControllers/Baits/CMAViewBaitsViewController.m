//
//  CMAViewBaitsViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAViewBaitsViewController.h"
#import "CMAAddBaitViewController.h"
#import "CMASingleBaitViewController.h"
#import "CMABaitTableViewCell.h"
#import "SWRevealViewController.h"
#import "CMAAppDelegate.h"
#import "CMANoXView.h"
#import "CMAStorageManager.h"

@interface CMAViewBaitsViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic)CMAUserDefine *userDefineBaits;
@property (strong, nonatomic)CMANoXView *noBaitsView;

@end

@implementation CMAViewBaitsViewController

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

- (void)initNoBaitView {
    self.noBaitsView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noBaitsView.imageView.image = [UIImage imageNamed:@"baits_large.png"];
    self.noBaitsView.titleView.text = @"Baits.";
    
    [self.noBaitsView centerInParent:self.view];
    [self.noBaitsView setAlpha:0.0f];
    [self.view addSubview:self.noBaitsView];
}

- (void)handleNoBaitView {
    if (!self.noBaitsView)
        [self initNoBaitView];
    
    if ([self.userDefineBaits count] <= 0)
        [UIView animateWithDuration:0.5 animations:^{
            [self.noBaitsView setAlpha:1.0f];
        }];
    else
        [self.noBaitsView setAlpha:0.0f];
}

- (void)setupView {
    [self setUserDefineBaits:[[self journal] userDefineNamed:UDN_BAITS]];
    [self handleNoBaitView];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isSelectingForAddEntry && !self.isSelectingForStatistics)
        [self initSideBarMenu];
    else
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupView];
    
    [self.deleteButton setEnabled:([self.userDefineBaits count] > 0)];
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setUserInteractionEnabled:YES];
    
    if (self.isSelectingForStatistics)
        self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self journal] userDefineNamed:UDN_BAITS] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMABaitTableViewCell *cell = (CMABaitTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"baitCell" forIndexPath:indexPath];
    
    CMABait *bait = [self.userDefineBaits objectAtIndex:indexPath.row];
    
    if (bait.imageData)
        [cell.thumbImage setImage:[bait.imageData dataAsUIImage]];
    else
        [cell.thumbImage setImage:[UIImage imageNamed:@"no_image.png"]];
    
    [cell.nameLabel setText:bait.name];
    
    if (bait.fishCaught)
        [cell.fishCaughtLabel setText:[NSString stringWithFormat:@"%@ Fish Caught", [bait.fishCaught stringValue]]];
    else
        [cell.fishCaughtLabel setText:@"0 Fish Caught"];
    
    if (self.isSelectingForAddEntry || self.isSelectingForStatistics)
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.item % 2 == 0)
        [cell setBackgroundColor:CELL_COLOR_DARK];
    else
        [cell setBackgroundColor:CELL_COLOR_LIGHT];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelectingForAddEntry) {
        self.baitForAddEntry = [self.userDefineBaits objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromViewBaits" sender:self];
        return;
    }
    
    if (self.isSelectingForStatistics) {
        self.baitNameForStatistics = [[self.userDefineBaits objectAtIndex:indexPath.row] name];
        [self performSegueWithIdentifier:@"unwindToStatisticsFromViewBaits" sender:self];
        return;
    }
    
    [self performSegueWithIdentifier:@"fromViewBaitsToSingleBait" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromViewBaitsToSingleBait" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // delete from data source
    CMABaitTableViewCell *cell = (CMABaitTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[self journal] removeUserDefine:UDN_BAITS objectNamed:cell.nameLabel.text];
    
    // delete from table
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // if there are no more items in the table
    if ([tableView numberOfRowsInSection:0] == 0) {
        [self exitEditMode];
        [self.deleteButton setEnabled:NO];
        [[self journal] archive];
        [self handleNoBaitView];
        [self.tableView reloadData];
    }
}

#pragma mark - Events

- (void)exitEditMode {
    [self.tableView setEditing:NO animated:YES];
    [self.deleteButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    
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
    [[self journal] archive];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewBaitsToAddBait"]) {
        CMAAddBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDViewBaits;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewBaitsToSingleBait"]) {
        CMASingleBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMABait *baitToDisplay = [self.userDefineBaits objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        destination.bait = baitToDisplay;
    }
}

- (IBAction)unwindToViewBaits:(UIStoryboardSegue *)segue {
    [self setUserDefineBaits:[[self journal] userDefineNamed:UDN_BAITS]];
    [self.tableView reloadData];
}

@end
