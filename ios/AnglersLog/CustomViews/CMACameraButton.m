//
//  CMACameraButton.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMACameraButton.h"

@implementation CMACameraButton

- (void)myInit:(id)aTarget action:(SEL)anAction {
    if (anAction != NULL)
        [self addTapGesture:aTarget action:anAction];
    
    [self addTint];
}

- (void)addTapGesture:(id)aTarget action:(SEL)anAction {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:aTarget action:anAction];
    singleTap.numberOfTapsRequired = 1;
    
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:singleTap];
}

- (void)addTint {
    UIImage *image = [[UIImage imageNamed:@"camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:image];
    [self setTintColor:[[[[UIApplication sharedApplication] delegate] window] tintColor]];
}

@end
