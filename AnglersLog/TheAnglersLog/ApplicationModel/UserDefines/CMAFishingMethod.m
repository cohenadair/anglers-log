//
//  CMAFishingMethod.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAFishingMethod.h"

@implementation CMAFishingMethod

#pragma mark - Initialization

- (CMAFishingMethod *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine {
    self.name = aName;
    self.userDefine = aUserDefine;
    
    return self;
}

#pragma mark - Editing

- (void)edit:(CMAFishingMethod *)aNewFishingMethod {
    [self setName:[aNewFishingMethod.name capitalizedString]];
}

@end
