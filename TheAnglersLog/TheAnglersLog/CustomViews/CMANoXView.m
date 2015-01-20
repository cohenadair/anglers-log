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
    CGFloat navHeight = aNavigationController.navigationBar.frame.size.height;
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    NSInteger yOffset = 0;

    // if the parent's height includes the navigation bar
    if (aParentView.frame.size.height == (screenFrame.size.height - navHeight - statusHeight))
        yOffset = -(navHeight / 2) - statusHeight;
    else
        yOffset = -navHeight - statusHeight;
    
    CGRect newFrame;
    newFrame.origin.x = aParentView.frame.origin.x;
    newFrame.origin.y = yOffset;
    newFrame.size.width = aParentView.frame.size.width;
    newFrame.size.height = screenFrame.size.height;

    [self setFrame:newFrame];
}

@end
