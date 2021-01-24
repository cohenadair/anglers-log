//
//  CMASpecies.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASpecies.h"
#import "CMAJSONWriter.h"

@implementation CMASpecies

@dynamic entries;
@dynamic userDefine;
@dynamic numberCaught;
@dynamic weightCaught;
@dynamic ouncesCaught;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitSpecies:self];
}

@end
