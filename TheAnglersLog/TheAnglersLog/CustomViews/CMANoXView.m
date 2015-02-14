//
//  CMANoXView.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/23/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMANoXView.h"

@implementation CMANoXView

- (void)centerInParent:(UIView *)aParentView {
    CGRect newFrame = aParentView.frame;
    newFrame.origin.y = 0;
    
    [self setFrame:newFrame];
}

@end
