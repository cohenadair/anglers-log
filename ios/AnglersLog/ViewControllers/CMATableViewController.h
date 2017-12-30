//
//  CMATableViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-27.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "CMANoXView.h"

@protocol CMATableViewControllerDelegate

@required

/**
 * Called when the search text in the search bar changes to a non-empty value, and should
 * initialize, setup, or reset the table view's data structure, filtering based on searchText. This
 * method will automatically reload the table view's data by calling [UITableView reloadData];
 */
- (void)filterTableViewData:(NSString *)searchText;

/**
 * Called when the search text in the search bar changes to the empty string, and should
 * initialize, setup, or reset the table view's data structure, such as an NSArray. This method will
 * automatically reload the table view's data by calling [UITableView reloadData];
 */
- (void)setupTableViewData;

/**
 * @return The row count of the current table view state, filtered or otherwise. The value returned
 *         from this method should be cumulative of all sections in the table view.
 */
- (NSInteger)tableViewRowCount;

@optional

/**
 * Called in tableView:commitEditingStyle:forRowAtIndexPath when editingStyle ==
 * UITableViewCellEditingStyleDelete. This method should delete the object from the underlying data
 * model.
 */
- (void)onDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Called in tableView:commitEditingStyle:forRowAtIndexPath when editingStyle ==
 * UITableViewCellEditingStyleDelete, immediately after calling onDeleteRowAtIndexPath:, and if
 * the new table view row count is 0.
 */
- (void)didDeleteLastItem;

@end

/**
 * A UIViewController subclass that implements reusable features used throughout Anglers' Log. By
 * default, this class includes a UITableView (and associated UISearchBar) with a single section
 * and row count equal to the value returned by the tableViewRowCount delegate method.
 */
@interface CMATableViewController : UIViewController

@property (weak, nonatomic) NSObject<CMATableViewControllerDelegate> *delegate;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CMANoXView *noXView;

@property (strong, nonatomic) NSString *quantityTitleText;
@property (strong, nonatomic) NSString *searchBarPlaceholder;

- (void)reloadData;

/**
 * Updates the view controller's title. By default, the controller's title includes the quantity
 * of items shown in the table. This method should be called to reset the title after the table's
 * view count changes.
 */
- (void)updateTitle;

/**
 * Hides or shows the noXView's visibility the delegate method, tableViewRowCount.
 * @param animated YES to animate the hide/show transition; NO otherwise.
 */
- (void)updateNoXViewVisibilityAnimated:(BOOL)animated;

@end
