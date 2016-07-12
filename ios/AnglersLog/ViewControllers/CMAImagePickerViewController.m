//
//  CMAImagePickerViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAImagePickerViewController.h"
#import "CMAAlerts.h"

@interface CMAImagePickerViewController ()

@end

@implementation CMAImagePickerViewController

#pragma mark - Initializing

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (BOOL)cameraAvailable:(UIViewController *)displayViewController {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [CMAAlerts errorAlert:@"Device has no camera." presentationViewController:displayViewController];
        return false;
    }
    
    return true;
}

@end
