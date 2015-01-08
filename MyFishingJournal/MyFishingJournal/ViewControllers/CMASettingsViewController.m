//
//  CMASettingsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASettingsViewController.h"
#import "CMAAppDelegate.h"
#import "SWRevealViewController.h"
#import "CMAAlerts.h"

@interface CMASettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *cloudSwitch;

@end

@implementation CMASettingsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
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
    [self.cloudSwitch setOn:[self journal].cloudBackupEnabled];
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
    return kTableSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Events

- (IBAction)clickUnitsSegmentedControl:(UISegmentedControl *)sender {
    [[self journal] setMeasurementSystem:(CMAMeasuringSystemType)[sender selectedSegmentIndex]];
    [[self journal] archive];
}

- (IBAction)toggleCloudSwitch:(UISwitch *)sender {
    CMAAppDelegate *delegate = ((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]);
    
    if (sender.on) {
        if (![[NSFileManager defaultManager] ubiquityIdentityToken]) {
            [CMAAlerts errorAlert:@"No iCloud account enabled. Please enable iCloud in your devices settings and try again." presentationViewController:self];
            sender.on = NO;
        } else {
            [delegate iCloudUbiquityTokenHandler];
            [delegate iCloudRequestHandlerOverrideFirstLaunch:YES withCallback:^(void) {
                [sender setOn:[self journal].cloudBackupEnabled animated:YES];
            }];
        }
    } else {
        [delegate iCloudDisableHandler];
        [CMAAlerts alertAlert:@"Your journal entries will no longer be backed up by iCloud." presentationViewController:self];
    }
}

@end
