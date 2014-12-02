//
//  CMASelectFishingSpotViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASelectFishingSpotViewController.h"

@interface CMASelectFishingSpotViewController ()

@end

@implementation CMASelectFishingSpotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.location.fishingSpots count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fishingSpotCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.location.fishingSpots objectAtIndex:indexPath.row] name];
    
    if (indexPath.item % 2 == 0)
        [cell setBackgroundColor:CELL_COLOR_DARK];
    else
        [cell setBackgroundColor:CELL_COLOR_LIGHT];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.previousViewID == CMAViewControllerIDEditSettings) {
        self.selectedCellLabelText = [NSString stringWithFormat:@"%@%@%@", self.location.name, TOKEN_LOCATION, cell.textLabel.text];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromSelectFishingSpot" sender:self];
    }
    
    if (self.previousViewID == CMAViewControllerIDSingleLocation) {
        self.selectedCellLabelText = cell.textLabel.text;
        [self performSegueWithIdentifier:@"unwindToSingleLocationFromSelectFishingSpot" sender:self];
    }
}

@end
