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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.settingLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.settingLabels objectAtIndex:indexPath.item];
    
    return cell;
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
