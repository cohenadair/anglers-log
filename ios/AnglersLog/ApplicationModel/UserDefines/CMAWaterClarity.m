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

#pragma mark - Initialization

- (CMAWaterClarity *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine; {
    self.name = aName;
    self.entries = [NSMutableSet set];
    self.userDefine = aUserDefine;
    
    return self;
}

#pragma mark - Editing

- (void)edit:(CMAWaterClarity *)aNewWaterClarity {
    [self setName:[aNewWaterClarity.name capitalizedString]];
}

- (void)addEntry:(CMAEntry *)anEntry {
    [self.entries addObject:anEntry];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitWaterClarity:self];
}

@end
