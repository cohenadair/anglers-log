//
//  CMASettingsViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASettingsViewController.h"
#import "CMAAppDelegate.h"
#import "SWRevealViewController.h"
#import "CMAAlerts.h"
#import "CMAStorageManager.h"

@interface CMASettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;

@end

#define kSectionFeedback 1
#define kRowRate 0

@implementation CMASettingsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideBarMenu];
    [self.unitsSegmentedControl setSelectedSegmentIndex:[self journal].measurementSystem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_HEIGHT_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionFeedback && indexPath.row == kRowRate)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_LINK]];
}

#pragma mark - Events

- (IBAction)clickUnitsSegmentedControl:(UISegmentedControl *)sender {
    [[self journal] setMeasurementSystem:(CMAMeasuringSystemType)[sender selectedSegmentIndex]];
    [[self journal] archive];
}

@end
