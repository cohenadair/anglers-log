//
//  UIColor+CMA.m
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-24.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "UIColor+CMA.h"

@implementation UIColor (CMA)

+ (UIColor *)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:0];
}

+ (UIColor *)anglersLogLight {
    return [UIColor colorWithR:235 g:212 b:147];
}

@end
