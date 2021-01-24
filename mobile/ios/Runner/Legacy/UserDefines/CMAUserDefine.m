//
//  CMAUserDefine.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMAJSONWriter.h"

@implementation CMAUserDefine

@dynamic journal;
@dynamic name;
@dynamic baits;
@dynamic locations;
@dynamic fishingMethods;
@dynamic species;
@dynamic waterClarities;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitUserDefne:self];
}

@end
