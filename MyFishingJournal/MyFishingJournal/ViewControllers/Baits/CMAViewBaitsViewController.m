//
//  CMAViewBaitsViewController.m
//  MyFishingJournal
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
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoBaitView {
    self.noBaitsView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noBaitsView.imageView.image = [UIImage imageNamed:@"baits_large.png"];
    self.noBaitsView.titleView.text = @"Baits.";
    
    [self.noBaitsView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.noBaitsView];
}

- (void)handleNoBaitView {
    if ([self.userDefineBaits count] <= 0)
        [self initNoBaitView];
    else {
        [self.noBaitsView removeFromSuperview];
        self.noBaitsView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isSelectingForAddEntry)
        [self initSideBarMenu];
    else
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    
    [self setUserDefineBaits:[[self journal] userDefineNamed:SET_BAITS]];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self handleNoBaitView];
    
    [self.deleteButton setEnabled:([self.userDefineBaits count] > 0)];
    [self.navigationController setToolbarHidden:NO];
    
    [self.tableView reloadData];
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
    return [[[self journal] userDefineNamed:SET_BAITS] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMABaitTableViewCell *cell = (CMABaitTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"baitCell" forIndexPath:indexPath];
    
    CMABait *bait = [[self.userDefineBaits objects] objectAtIndex:indexPath.row];
    
    if (bait.image)
        [cell.thumbImage setImage:bait.image];
    else
        [cell.thumbImage setImage:[UIImage imageNamed:@"no-image.png"]];
    
    [cell.nameLabel setText:bait.name];
    
    if (self.isSelectingForAddEntry)
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelectingForAddEntry) {
        self.baitForAddEntry = [[self.userDefineBaits objects] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromViewBaits" sender:self];
    } else
        [self performSegueWithIdentifier:@"fromViewBaitsToSingleBait" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromViewBaitsToSingleBait" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // delete from data source
    CMABaitTableViewCell *cell = (CMABaitTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [[[self journal] userDefineNamed:SET_BAITS] removeObjectNamed:cell.nameLabel.text];
    
    // delete from table
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // if there are no more items in the table
    if ([tableView numberOfRowsInSection:0] == 0) {
        [self exitEditMode];
        [self.deleteButton setEnabled:NO];
        [[self journal] archive];
        [self initNoBaitView];
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
        destination.previousViewID = CMAViewControllerID_ViewBaits;
    }
    
    if ([segue.identifier isEqualToString:@"fromViewBaitsToSingleBait"]) {
        CMASingleBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        CMABait *baitToDisplay = [[self.userDefineBaits objects] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        destination.bait = baitToDisplay;
    }
}

- (IBAction)unwindToViewBaits:(UIStoryboardSegue *)segue {
    [self setUserDefineBaits:[[self journal] userDefineNamed:SET_BAITS]];
    [self.tableView reloadData];
}

@end
