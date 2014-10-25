//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"
#import "CMAConstants.h"

@interface CMASingleLocationViewController ()

@end

NSInteger const FISHING_SPOT_SECTION = 2;

@implementation CMASingleLocationViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLE_SECTION_SPACING;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < 2)
        return 1;
    
    if (section == FISHING_SPOT_SECTION)
        return [self.location fishingSpotCount];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // location name
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationNameCell" forIndexPath:indexPath];
        
        [cell.textLabel setText:[self.location name]];
        return cell;
    }
    
    // map
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell" forIndexPath:indexPath];
        return cell;
    }
    
    // fishing spots
    if (indexPath.section == FISHING_SPOT_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fishingSpotCell" forIndexPath:indexPath];
        
        CMAFishingSpot *fishingSpot = [self.location fishingSpotAtIndex:indexPath.item];
        [cell.textLabel setText:fishingSpot.name];
        
        NSString *coordinateText = [NSString stringWithFormat:@"Latitude: %f, Longitude: %f", fishingSpot.location.coordinate.latitude, fishingSpot.location.coordinate.longitude];
        [cell.detailTextLabel setText:coordinateText];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unwind to Add Entry view after selecting a fishing spot
    if (indexPath.section == FISHING_SPOT_SECTION && self.isSelectingForAddEntry) {
        self.addEntryLabelText = [NSString stringWithFormat:@"%@%@%@", [self.location name], TOKEN_LOCATION, [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [self performSegueWithIdentifier:@"unwindToAddEntryFromSingleLocation" sender:self];
    }
}

- (void) tableView:(UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped accessory button.");
}


@end
