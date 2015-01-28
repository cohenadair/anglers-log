//
//  CMAImage.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAImage.h"
#import "CMABait.h"
#import "CMAEntry.h"

@implementation CMAImage

@dynamic data;
@dynamic entry;
@dynamic bait;

- (UIImage *)dataAsUIImage {
    return [UIImage imageWithData:self.data];
}

- (void)setDataFromUIImage:(UIImage *)anImage {
    self.data = UIImagePNGRepresentation(anImage);
}

@end
