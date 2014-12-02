//
//  CMANoXView.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/23/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMANoXView.h"

@implementation CMANoXView

- (void)centerInParent:(UIView *)aParentView navigationController:(UINavigationController *)aNavigationController {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    CGRect newFrame;
    newFrame.origin.x = aParentView.frame.origin.x;
    newFrame.origin.y = -aNavigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    newFrame.size.width = aParentView.frame.size.width;
    newFrame.size.height = screenFrame.size.height;
    [self setFrame:newFrame];
}

@end
