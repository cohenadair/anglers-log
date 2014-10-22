//
//  CMAHomeViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAHomeViewController.h"
#import "CMAAddEntryViewController.h"
#import "CMAConstants.h"

@interface CMAHomeViewController ()

@end

@implementation CMAHomeViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // sets the back button text to "Home" when unwinding from a push segue
    self.navigationItem.backBarButtonItem = [UIBarButtonItem new];
    self.navigationItem.backBarButtonItem = [self.navigationItem.backBarButtonItem initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromHomeToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_Home;
    } else
        self.navigationController.navigationBarHidden = NO;
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    
}

@end

