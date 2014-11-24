//
//  CMAStatisticsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAStatisticsViewController.h"
#import "CMANoXView.h"
#import "CMAAppDelegate.h"
#import "SWRevealViewController.h"

@interface CMAStatisticsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) CMANoXView *noStatsView;

@end

@implementation CMAStatisticsViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoStatsView {
    self.noStatsView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noStatsView.imageView.image = [UIImage imageNamed:@"stats_large.png"];
    self.noStatsView.titleView.text = @"Entries.";
    self.noStatsView.subtitleView.text = @"Visit the \"All Entries\" page to begin.";
    
    [self.noStatsView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.noStatsView];
}

- (void)handleNoStatsView {
    if ([[self journal] entryCount] <= 0)
        [self initNoStatsView];
    else {
        [self.noStatsView removeFromSuperview];
        self.noStatsView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideBarMenu];
    [self handleNoStatsView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
