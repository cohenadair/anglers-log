//
//  CMATableViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-27.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "CMATableViewController.h"
#import "CMAThumbnailCell.h"
#import "CMAUtilities.h"
#import "UIView+CMAConstraints.h"

@interface CMATableViewController () <UITableViewDelegate, UITableViewDataSource,
        UISearchBarDelegate, CMAJournalChangeListener>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UILabel *noResultsLabel;

@property (nonatomic) CGFloat trackedScrollPosition;
@property (nonatomic) NSString *currentSearchText;

@end

@implementation CMATableViewController

#pragma mark - Accessing Helpers

- (CMAJournal *)journal {
    return CMAStorageManager.sharedManager.sharedJournal;
}

#pragma mark - View Management

- (void)dealloc {
    [self.journal removeChangeListener:self];
}

- (void)setupSearchBar {
    self.searchBar = [UISearchBar new];
    [self.view addSubview:self.searchBar];
    
    [self.searchBar constrain:^(UIView *view) {
        [view leadingToSuperview];
        [view trailingToSuperview];
        [view topToSuperview];
        [view heightToConstant:SEARCH_BAR_HEIGHT];
    }];
    
    self.searchBar.delegate = self;
}

- (void)setupTableView {
    self.tableView = [UITableView new];
    [self.view addSubview:self.tableView];
    
    [self.tableView constrain:^(UIView *view) {
        [view leadingToSuperview];
        [view trailingToSuperview];
        [view bottomToSuperview];
        [view topToAnchor:self.searchBar.bottomAnchor];
    }];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.separatorColor = UIColor.clearColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [CMAThumbnailCell registerWithTableView:self.tableView];
}

- (void)setupEmptyTableView {
    self.noXView = [NSBundle.mainBundle loadNibNamed:@"CMANoXView" owner:self options:nil][0];
    [self.view addSubview:self.noXView];
    
    [self.noXView constrain:^(UIView *view) {
        [view fillSuperview];
    }];
    
    self.noXView.alpha = 0;
    self.noXView.hidden = YES;
}

- (void)setupNoResultsLabel {
    self.noResultsLabel = [UILabel new];
    [self.view addSubview:self.noResultsLabel];
    
    [self.noResultsLabel constrain:^(UIView *view) {
        [view leadingToSuperview];
        [view trailingToSuperview];
        [view topToAnchor:self.searchBar.bottomAnchor offset:SPACING_NORMAL];
    }];
    
    self.noResultsLabel.text = @"Search returned 0 results";
    self.noResultsLabel.textColor = UIColor.lightGrayColor;
    self.noResultsLabel.hidden = YES;
    self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSearchBar];
    [self setupTableView];
    [self setupEmptyTableView];
    [self setupNoResultsLabel];
    
    [self.journal addChangeListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.contentOffset = CGPointMake(0, self.trackedScrollPosition);
    
    [self updateTitle];
    [self updateNoXViewVisibilityAnimated:NO];
    
    // If there is an active search query when returning to the table view, be sure to update
    // the table. This is necessary to for modifications to the underlying data model to be shown
    // in the filtered table view without searching again.
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.trackedScrollPosition = self.tableView.contentOffset.y;
}

- (void)setSearchBarPlaceholder:(NSString *)searchBarPlaceholder {
    _searchBarPlaceholder = searchBarPlaceholder;
    self.searchBar.placeholder = searchBarPlaceholder;
}

- (void)reloadData {
    if (self.isSearching) {
        [self filterTableView:self.searchBar.text];
    } else {
        [self.delegate setupTableViewData];
    }
    
    [self.tableView reloadData];
    [self updateNoXViewVisibilityAnimated:YES];
    [self updateTitle];
}

- (void)updateTitle {
    if (self.isSearching) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%ld/%ld)",
                self.quantityTitleText, (long)self.delegate.tableViewRowCount,
                (long)self.delegate.unfilteredTableViewRowCount];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%ld)", self.quantityTitleText,
                (long)self.delegate.tableViewRowCount];
    }
}

- (void)updateNoXViewVisibilityAnimated:(BOOL)animated {
    BOOL visible = self.delegate.tableViewRowCount <= 0 && !self.isSearching;
    self.noXView.alpha = visible;
    self.noXView.hidden = !visible;
}

- (void)filterTableView:(NSString *)searchText {
    if ([CMAUtilities isEmpty:searchText]) {
        // Be sure to show all items if the search text was cleared.
        [self.delegate setupTableViewData];
    } else {
        [self.delegate filterTableViewData:searchText];
    }
    
    // Hide/show no results label and table view based on the current table view row count.
    self.noResultsLabel.hidden = self.delegate.tableViewRowCount > 0;
    self.tableView.hidden = !self.noResultsLabel.hidden;
    
    [self.tableView reloadData];
}

- (BOOL)isSearching {
    return ![CMAUtilities isEmpty:self.currentSearchText];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.delegate.tableViewRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Should be overridden by subclass.
    return nil;
}

 - (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate respondsToSelector:@selector(onDeleteRowAtIndexPath:)]) {
            [self.delegate onDeleteRowAtIndexPath:indexPath];
        }
        
        if (self.delegate.tableViewRowCount <= 0) {
            if ([self.delegate respondsToSelector:@selector(didDeleteLastItem)]) {
                [self.delegate didDeleteLastItem];
            }
            
            // The Apple documentation states that setEditing: should not be called from within
            // the data sources tableView:commitEditingStyle:forRowAtIndexPath method, but to do
            // at after a delay if necessary.
            //
            // This is called here to ensure that editing mode is disabled when all items have
            // been deleted from the table view.
            [self performSelector:@selector(endEditing) withObject:self afterDelay:0.25];
        }
    }
}

- (void)endEditing {
    self.tableView.editing = NO;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.currentSearchText = searchText;
    [self filterTableView:self.currentSearchText];
    [self updateTitle];
}

#pragma mark - CMAJournalChangeListener

- (void)entriesDidChange {
    [self reloadData];
}

- (void)baitsDidChange {
    [self reloadData];
}

- (void)locationsDidChange {
    [self reloadData];
}

- (void)fishingMethodsDidChange {
    [self reloadData];
}

- (void)speciesDidChange {
    [self reloadData];
}

- (void)waterClaritiesDidChange {
    [self reloadData];
}

@end
