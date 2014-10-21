//
//  CMAViewEntriesViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAViewEntriesViewController.h"
#import "CMAAddEntryViewController.h"

@interface CMAViewEntriesViewController ()

@end

@implementation CMAViewEntriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

// Sets the height of each cell.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entriesCell" forIndexPath:indexPath];
    
    cell.textLabel.text = @"Walleye";
    cell.detailTextLabel.text = @"May 5th, 2014 at 6:15am";
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.imageView.image = [UIImage imageNamed:@"example.jpg"];
    
    return cell;
}

- (void) tableView:(UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromViewEntriesToSingleEntry" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromViewEntriesToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_ViewEntries;
    }
}

- (IBAction)unwindToViewEntries:(UIStoryboardSegue *)segue {
    
}

@end
