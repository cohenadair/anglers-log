//
//  CMAAddEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAAddLocationViewController.h"

@interface CMAAddEntryViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (strong, nonatomic)NSDictionary *tableLabels;
@property (strong, nonatomic)NSDictionary *tableCellTypes;

@end

// Constants represent the different cell identifiers.
NSString *const CELL_DATE_DISPLAY = @"dateDisplayCell";
NSString *const CELL_DATE_PICKER = @"datePickerCell";
NSString *const CELL_USER_DEFINE = @"userDefineCell";
NSString *const CELL_USER_INPUT = @"userInputCell";
NSString *const CELL_PICTURES = @"picturesCell";
NSString *const CELL_NOTES = @"notesCell";

@implementation CMAAddEntryViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
    
    self.tableLabels =
        @{@"0" : @[@"Notes"],
          @"1" : @[@"Methods", @"Length", @"Weight", @"Quantity", @"Bait"],
          @"2" : @[@"Pictures"],
          @"3" : @[@"Date & Time", @"Date Picker", @"Species", @"Location"]};
    
    self.tableCellTypes =
        @{@"Date & Time" : CELL_DATE_DISPLAY,
          @"Date Picker" : CELL_DATE_PICKER,
          @"Species"     : CELL_USER_DEFINE,
          @"Location"    : CELL_USER_DEFINE,
          @"Pictures"    : CELL_PICTURES,
          @"Methods"     : CELL_USER_DEFINE,
          @"Length"      : CELL_USER_INPUT,
          @"Weight"      : CELL_USER_INPUT,
          @"Quantity"    : CELL_USER_INPUT,
          @"Bait"        : CELL_USER_DEFINE,
          @"Notes"       : CELL_NOTES};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

// Returns the key of self.tableLabels at anIndex.
- (NSString *)sectionNameAtIndex: (NSUInteger)anIndex {
    return [[self.tableLabels allKeys] objectAtIndex:anIndex];
}

// Returns the object of self.tableLabels at anIndex.
- (NSArray *)sectionLabelsAtIndex: (NSUInteger)anIndex {
    return [self.tableLabels objectForKey:[self sectionNameAtIndex:anIndex]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CELL_HEADER_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == ([self numberOfSectionsInTableView:tableView] - 1))
        return CELL_HEADER_HEIGHT;

    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.tableLabels allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self sectionLabelsAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = [[self sectionLabelsAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellType = [self.tableCellTypes objectForKey:cellName];

    if ([cellType isEqualToString:CELL_USER_DEFINE]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        cell.detailTextLabel.text = @"None";
        return cell;
    }
    
    if ([cellType isEqualToString:CELL_USER_INPUT]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        return cell;
    }
    
    if ([cellType isEqualToString:CELL_PICTURES]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        return cell;
    }
    
    if ([cellType isEqualToString:CELL_DATE_DISPLAY]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        return cell;
    }
    
    if ([cellType isEqualToString:CELL_DATE_PICKER]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        return cell;
    }
    
    if ([cellType isEqualToString:CELL_NOTES]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
        cell.textLabel.text = cellName;
        return cell;
    }
    
    return nil;
}

#pragma mark - Events

- (IBAction)clickedDone:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(UIBarButtonItem *)sender {
    [self performSegueToPreviousView];
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_Home:
            [self performSegueWithIdentifier:@"unwindToHome" sender:self];
            break;
            
        case CMAViewControllerID_ViewEntries:
            [self performSegueWithIdentifier:@"unwindToViewEntries" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromAddEntryToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_AddEntry;
    }
}

- (IBAction)unwindToAddEntry:(UIStoryboardSegue *)segue {
    
}

@end
