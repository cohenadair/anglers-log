//
//  CMAAboutViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 2018-01-06.
//  Copyright © 2018 Cohen Adair. All rights reserved.
//

#import "CMAAboutViewController.h"

#define kPolicySectionIndex 1
#define kPrivacyPolicyIndex 0
#define kIcons8PolicyIndex 1

@interface CMAAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation CMAAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@",
            [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPolicySectionIndex) {
        if (indexPath.row == kPrivacyPolicyIndex) {
            [self openPrivacyPolicy];
        }
        
        if (indexPath.row == kIcons8PolicyIndex) {
            [self showIcons8Alert];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)openPrivacyPolicy {
    [UIApplication.sharedApplication openURL:
            [NSURL URLWithString:@"https://anglerslog.ca/privacy/privacy-policy.html"]];
}

- (void)showIcons8Alert {
    NSString *icons8Url = @"https://icons8.com/";
    NSString *title = @"Icons8 Terms & Privacy";
    NSString *msg = @"\nSome icons used in Anglers' Log were developed by Icons8.\n\nIcons8 "
            "provides thousands of free icons for both personal and commercial use.";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
            message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Visit Icons8"
                                              style:UIAlertActionStyleDefault
                                            handler:
            ^(UIAlertAction * _Nonnull action) {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:icons8Url]];
            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
