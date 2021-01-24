//
//  CMAFishingMethod.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingMethod.h"
#import "CMAJSONWriter.h"

@implementation CMAFishingMethod

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitFishingMethod:self];
}

@end
