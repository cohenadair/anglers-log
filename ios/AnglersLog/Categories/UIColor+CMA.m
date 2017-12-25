//
//  UIColor+CMA.m
//  AnglersLog
//
//  Created by Cohen Adair on 2017-12-24.
//  Copyright © 2017 Cohen Adair. All rights reserved.
//

#import "UIColor+CMA.h"

@implementation UIColor (CMA)

+ (UIColor *)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+ (UIColor *)anglersLogLight {
    return [UIColor colorWithR:235.0f g:212.0f b:147.0f a:1.0f];
}

+ (UIColor *)anglersLogLightTransparent {
    return [UIColor colorWithR:235.0f g:212.0f b:147.0f a:0.25f];
}

+ (UIColor *)anglersLogAccent {
    return [UIColor colorWithR:212.0f g:191.0f b:132.0f a:1.0f];
}

@end
