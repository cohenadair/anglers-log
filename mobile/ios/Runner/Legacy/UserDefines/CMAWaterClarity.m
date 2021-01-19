//
//  CMAWaterClarity.m
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAWaterClarity.h"
#import "CMAJSONWriter.h"

@implementation CMAWaterClarity

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitWaterClarity:self];
}

@end
