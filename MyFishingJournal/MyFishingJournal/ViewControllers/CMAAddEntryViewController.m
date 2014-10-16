//
//  CMAAddEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"

@interface CMAAddEntryViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation CMAAddEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_Home:
            [self performSegueWithIdentifier:@"unwindToHome" sender:self];
            break;
        
        case CMAViewControllerID_ViewEntries:
            [self performSegueWithIdentifier:@"unwindToViewEntries" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (IBAction)clickedDone:(id)sender {
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(id)sender {
    [self performSegueToPreviousView];
}

@end
