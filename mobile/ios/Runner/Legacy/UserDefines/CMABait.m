//
//  CMABait.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMABait.h"
#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"

@implementation CMABait

@dynamic baitDescription;
@dynamic imageData;
@dynamic fishCaught;
@dynamic size;
@dynamic color;
@dynamic baitType;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitBait:self];
}

@end
