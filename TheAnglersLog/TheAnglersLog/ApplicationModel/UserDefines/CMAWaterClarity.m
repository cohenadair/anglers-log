//
//  CMAWaterClarity.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAWaterClarity.h"

@implementation CMAWaterClarity

@dynamic entries;
@dynamic userDefine;

#pragma mark - Initialization

- (CMAWaterClarity *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine; {
    self.name = aName;
    self.entries = [NSMutableSet set];
    self.userDefine = aUserDefine;
    
    return self;
}

// Used to initialize objects created from an archive. For compatibility purposes.
- (void)validateProperties {
    if (!self.name)
        self.name = [NSMutableString string];
}

#pragma mark - Editing

- (void)edit:(CMAWaterClarity *)aNewWaterClarity {
    [self setName:[aNewWaterClarity.name capitalizedString]];
}

- (void)addEntry:(CMAEntry *)anEntry {
    [self.entries addObject:anEntry];
}

@end
