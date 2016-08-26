//
//  CMANoXView.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/23/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMANoXView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleView;
@property (weak, nonatomic) IBOutlet UIView *subView;

- (void)centerInParent:(UIView *)aParentView;

@end
