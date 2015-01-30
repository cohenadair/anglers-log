//
//  CMASelectFishingSpotViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASelectFishingSpotViewController.h"
#import "CMAAddLocationViewController.h"

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSelectFishingSpotToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.location = self.location;
        destination.previousViewID = CMAViewControllerIDSelectFishingSpot;
    }
}

- (IBAction)unwindToSelectFishingSpot:(UIStoryboardSegue *)segue {
    CMAAddLocationViewController *source = segue.sourceViewController;
    
    self.location = source.location;
    source.location = nil;
    source.previousViewID = CMAViewControllerIDNil;
    
    [self.tableView reloadData];
}

@end
