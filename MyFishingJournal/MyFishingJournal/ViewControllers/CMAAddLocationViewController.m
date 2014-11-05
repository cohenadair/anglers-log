//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddLocationViewController.h"
#import "CMAAppDelegate.h"

@interface CMAAddLocationViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation CMAAddLocationViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_SECTION_SPACING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

// Initialize each cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationNameCell" forIndexPath:indexPath];
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addFishingSpotCell" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

#pragma mark - Location Creation

- (BOOL)checkUserInputAndSetLocation: (CMALocation *)aLocation {
    return NO;
}

#pragma mark - Events

- (IBAction)clickedDone:(id)sender {
    // add new event to journal
    CMALocation *locationToAdd = [CMALocation new];
    
    if ([self checkUserInputAndSetLocation:locationToAdd]) {
        if (self.previousViewID == CMAViewControllerID_SingleLocation) {
            [[self journal] editUserDefine:SET_LOCATIONS objectNamed:self.location.name newProperties:locationToAdd];
            [self setLocation:locationToAdd];
        } else
            [[self journal] addUserDefine:SET_LOCATIONS objectToAdd:locationToAdd];
        
        [self performSegueToPreviousView];
    }
}

- (IBAction)clickedCancel:(id)sender {
    [self performSegueToPreviousView];
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_EditSettings:
            [self performSegueWithIdentifier:@"unwindToEditSettings" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

@end
