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
#import "CMAUtilities.h"
#import "CMAAdBanner.h"

@interface CMAViewEntriesViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (strong, nonatomic)NSDateFormatter *dateFormatter;
@property (strong, nonatomic)CMANoXView *noEntriesView;
@property (strong, nonatomic)UISearchBar *searchBar;
@property (strong, nonatomic)UIView *searchResultView;

@property (strong, nonatomic)CMAAdBanner *adBanner;

@property (strong, nonatomic)NSMutableOrderedSet *entries;
@property (nonatomic)BOOL isSearchBarInView;
@property (nonatomic)CGFloat currentOffsetY;

@end

#define kSearchBarHeight 44

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
    
    [self.noEntriesView centerInParent:self.view];
    [self.noEntriesView setAlpha:0.0f];
    [self.view addSubview:self.noEntriesView];
}

- (void)handleNoEntriesView {
    if (!self.noEntriesView)
        [self initNoEntriesView];
    
    if ([self.entries count] <= 0)
        [UIView animateWithDuration:0.5 animations:^{
            [self.noEntriesView setAlpha:1.0f];
        }];
    else
        [self.noEntriesView setAlpha:0.0f];
}

- (void)setupView {
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
    if ([self.entries count] > 0) {
        self.deleteButton.enabled = YES;
        self.sortButton.enabled = YES;
        [self initSearchBar];
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Entries (%ld)", (long)[[self journal] entryCount]];
    
    [self handleNoEntriesView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Entries" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy 'at' h:mm a"];
    
    self.entries = [[self journal] entries];
    self.isSearchBarInView = NO;
    self.currentOffsetY = 0.0f;
    
    if ([self.entries count] <= 0) {
        [self.deleteButton setEnabled:NO];
        [self.sortButton setEnabled:NO];
    }
    
    [self initAdBanner];
    [self initSideBarMenu];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
    
    [self.tableView setContentOffset:CGPointMake(0, self.currentOffsetY)];
    
    if (self.searchBar && !self.isSearchBarInView) {
        if (self.currentOffsetY > 0)
            [self.tableView setContentOffset:CGPointMake(0, self.currentOffsetY)];
        else
            [self.tableView setContentOffset:CGPointMake(0, kSearchBarHeight)];
        
        [self setIsSearchBarInView:NO];
    } else
        [self.tableView setContentOffset:CGPointMake(0, self.currentOffsetY)];
    
    self.entries = [[self journal] entries]; // need to reset in case an entry was edited and the order changed
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.searchBar && !self.isSearchBarInView)
        [self.tableView setContentOffset:CGPointMake(0, kSearchBarHeight)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Ad Banner Initializing

- (void)initAdBanner {
    self.adBanner = [CMAAdBanner withFrame:CGRectMake(0, -50, self.view.frame.size.width, 50) delegate:self superView:self.view];
    self.adBanner.constraint = self.tableViewTop;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self.adBanner showWithCompletion:nil];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self.adBanner hideWithCompletion:nil];
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries count];
}

// Sets the height of each cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_THUMB_SIZE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMAEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entriesCell" forIndexPath:indexPath];
    
    CMAEntry *entry = [self.entries objectAtIndex:indexPath.item];
    
    cell.speciesLabel.text = [entry.fishSpecies name];
    cell.dateLabel.text = [self.dateFormatter stringFromDate:entry.date];
    
    if (entry.location)
        cell.locationLabel.text = [entry locationAsString];
    else
        cell.locationLabel.text = @"No Location";
    
    if ([entry imageCount] > 0) {
        CMAImage *img = [entry.images objectAtIndex:0];
        cell.thumbImage.image = img.tableCellImage;
    } else
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
            [self deleteSearchBar];
        }
    }
}

#pragma mark - Search Bar Initializing

- (void)initSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kSearchBarHeight)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    [self initSearchResultView];
}

- (void)initSearchResultView {
    self.searchResultView = [[UIView alloc] initWithFrame:CGRectMake(0, kSearchBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 50)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"No results found."];
    
    [self.searchResultView addSubview:label];
    
    [self.view addSubview:self.searchResultView];
    [self.searchResultView setHidden:YES];
}

- (void)deleteSearchBar {
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
    self.tableView.tableHeaderView = nil;
    [self.tableView setContentOffset:CGPointMake(0, 0)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSMutableOrderedSet *searchResults = [[self journal] filterEntries:searchBar.text];
    
    if ([searchResults count] <= 0)
        self.searchResultView.hidden = NO;
    else
        self.searchResultView.hidden = YES;
    
    self.entries = searchResults;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        NSLog(@"Search was cleared, resetting table...");
        self.entries = [[self journal] entries];
        [self.tableView reloadData];
        [self.searchResultView setHidden:YES];
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
        
        self.isSearchBarInView = (self.tableView.contentOffset.y == 0.0f);
        self.currentOffsetY = self.tableView.contentOffset.y;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    // reload data to show the newly sorted array
    self.entries = [[self journal] entries];
    
    if ([self.entries count] <= 0) {
        [self deleteSearchBar];
    }
}

@end
