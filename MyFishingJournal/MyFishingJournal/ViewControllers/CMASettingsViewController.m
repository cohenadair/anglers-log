//
//  CMASettingsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASettingsViewController.h"
#import "CMAEditSettingsViewController.h"
#import "CMAAppDelegate.h"
#import "CMASegmentedControlTableViewCell.h"

@interface CMASettingsViewController ()

@property (strong, nonatomic)NSArray *settingLabels;

@end

@implementation CMASettingsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // sets the back button to get back to this view (this button is visible on any view shown by a "show" segue)
    self.navigationItem.backBarButtonItem = [UIBarButtonItem new];
    self.navigationItem.backBarButtonItem = [self.navigationItem.backBarButtonItem initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.settingLabels = [NSArray arrayWithArray:[[[self journal] userDefines] allKeys]];
    
    [self.tableView setRowHeight:44.0];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_SECTION_SPACING;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == ([self numberOfSectionsInTableView:tableView] - 1))
        return TABLE_SECTION_SPACING;
    
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

// Returns the number of rows in section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.settingLabels count];
            
        case 1:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // user defines
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsDisclosureCell" forIndexPath:indexPath];
        cell.textLabel.text = [self.settingLabels objectAtIndex:indexPath.item];
        return cell;
    }
    
    // other settings
    if (indexPath.section == 1) {
        CMASegmentedControlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"segmentedControlCell" forIndexPath:indexPath];
        
        [cell.label setText:@"Measurement System"];
        [cell.segmentedControl setTitle:@"Imperial" forSegmentAtIndex:0];
        [cell.segmentedControl setTitle:@"Metric" forSegmentAtIndex:1];
        [cell.segmentedControl setSelectedSegmentIndex:[[self journal] measurementSystem]];
        [cell.segmentedControl addTarget:self action:@selector(clickMeasurementSystemControl:) forControlEvents:UIControlEventAllEvents];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Events

- (void)clickMeasurementSystemControl:(UISegmentedControl *)sender {
    [[self journal] setMeasurementSystem:(CMAMeasuringSystemType)[sender selectedSegmentIndex]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSettingsToEditSettings"]) {
        CMAEditSettingsViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        
        // sets the proper title for the "Edit Settings" screen
        destination.settingName = [self.settingLabels objectAtIndex:[[self.tableView indexPathForCell:sender] item]];
    }
}

@end
