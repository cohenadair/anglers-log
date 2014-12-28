//
//  CMASideMenuViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/12/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASideMenuViewController.h"
#import "CMAUserDefinesViewController.h"
#import "CMAAppDelegate.h"
#import "SWRevealViewController.h"

@interface CMASideMenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleView;

@end

@implementation CMASideMenuViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self initTitleView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTitleView {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.frame.size.height - 1, self.titleView.frame.size.width, 0.5)];
    [line setBackgroundColor:[UIColor blackColor]];
    [self.titleView addSubview:line];
}

#pragma mark - Table View Initializing

- (CMAUserDefine *)userDefineFromSelectedCell {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    return [[self journal] userDefineNamed:[(UILabel *)[selectedCell viewWithTag:100] text]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSideMenuSpeciesToEditSettings"] ||
        [segue.identifier isEqualToString:@"fromSideMenuLocationsToEditSettings"] ||
        [segue.identifier isEqualToString:@"fromSideMenuFishingMethodsToEditSettings"] ||
        [segue.identifier isEqualToString:@"fromSideMenuWaterClaritiesToEditSettings"])
    {
        CMAUserDefinesViewController *destination = segue.destinationViewController;
        destination.userDefine = [self userDefineFromSelectedCell];
    }
    
    // Manage the view transition and tell SWRevealViewController the new front view controller for display. We reuse the navigation controller and replace the view controller with destination view controller.
    if ([segue isKindOfClass: [SWRevealViewControllerSegue class]]) {
        [self.revealViewController toggleOverlay];
        
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*)segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController *dvc) {
            UINavigationController *navController = (UINavigationController *)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}

@end
