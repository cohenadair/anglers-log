//
//  CMAViewBaitsViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAppDelegate.h"
#import "CMAAddBaitViewController.h"
#import "CMANoXView.h"
#import "CMASingleBaitViewController.h"
#import "CMAStorageManager.h"
#import "CMAThumbnailCell.h"
#import "CMAViewBaitsViewController.h"
#import "SWRevealViewController.h"

@interface CMAViewBaitsViewController ()

@property (weak, nonatomic)IBOutlet NSLayoutConstraint *tableViewTop;
@property (weak, nonatomic)IBOutlet UITableView *tableView;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic)CMAUserDefine *userDefineBaits;
@property (strong, nonatomic)CMANoXView *noBaitsView;

@property (nonatomic)CGFloat currentOffsetY;

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
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil];
    if (nib.count <= 0)
        return;
    
    self.noBaitsView = (CMANoXView *)[nib objectAtIndex:0];
    
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
    [self.tableView setContentOffset:CGPointMake(0, self.currentOffsetY)];
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
    [CMAThumbnailCell registerWithTableView:self.tableView];
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
    return CMAThumbnailCell.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self journal] userDefineNamed:UDN_BAITS] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMAThumbnailCell *cell = [CMAThumbnailCell forTableView:tableView indexPath:indexPath];
    CMABait *bait = (CMABait *) [self.userDefineBaits objectAtIndex:indexPath.row];
    BOOL hideAccessory = self.isSelectingForAddEntry || self.isSelectingForStatistics;
    [cell setBait:bait hideAccessory:hideAccessory];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // delete from data source
    CMABait *bait = (CMABait *) [self.userDefineBaits objectAtIndex:indexPath.row];
    [self.journal removeUserDefine:UDN_BAITS objectNamed:bait.name];
    
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
        CMASingleBaitViewController *destination = segue.destinationViewController;
        CMABait *baitToDisplay = [self.userDefineBaits objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        destination.bait = baitToDisplay;
    }
    
    self.currentOffsetY = self.tableView.contentOffset.y;
}

- (IBAction)unwindToViewBaits:(UIStoryboardSegue *)segue {
    [self setUserDefineBaits:[[self journal] userDefineNamed:UDN_BAITS]];
    [self.tableView reloadData];
}

@end
