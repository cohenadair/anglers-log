//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/20/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleLocationViewController.h"

@interface CMASingleLocationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@end

@implementation CMASingleLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationNameLabel.text = self.locationName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
