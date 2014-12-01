//
//  CMANoXView.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/23/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMANoXView.h"

@implementation CMANoXView

- (void)centerInParent:(UIView *)aParentView {
    [self setFrame:CGRectMake(0, 0, aParentView.frame.size.width, aParentView.frame.size.height)];
}

@end
