//
//  CMASpecies.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASpecies.h"
#import "CMAConstants.h"

@implementation CMASpecies

@dynamic entries;
@dynamic userDefine;
@dynamic numberCaught;
@dynamic weightCaught;
@dynamic ouncesCaught;

#pragma mark - Initialization

- (CMASpecies *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine {
    self.name = aName;
    self.numberCaught = [NSNumber numberWithInteger:0];
    self.weightCaught = [NSNumber numberWithInteger:0];
    self.ouncesCaught = [NSNumber numberWithInteger:0];
    self.entries = [NSMutableSet set];
    self.userDefine = aUserDefine;
    
    return self;
}

#pragma mark - Editing

- (void)edit:(CMASpecies *)aNewSpecies {
    [self setName:[aNewSpecies.name capitalizedString]];
}

- (void)incNumberCaught:(NSInteger)incBy {
    NSInteger count = [self.numberCaught integerValue];
    count += incBy;
    
    [self setNumberCaught:[NSNumber numberWithInteger:count]];
}

- (void)decNumberCaught:(NSInteger)decBy {
    NSInteger count = [self.numberCaught integerValue];
    count -= decBy;
    
    [self setNumberCaught:[NSNumber numberWithInteger:count]];
}

- (void)incWeightCaught:(NSInteger)incBy {
    NSInteger count = [self.weightCaught integerValue];
    count += incBy;
    
    [self setWeightCaught:[NSNumber numberWithInteger:count]];
}

- (void)decWeightCaught:(NSInteger)decBy {
    NSInteger count = [self.weightCaught integerValue];
    count -= decBy;
    
    [self setWeightCaught:[NSNumber numberWithInteger:count]];
}

- (void)incOuncesCaught:(NSInteger)incBy {
    NSInteger count = [self.ouncesCaught integerValue];
    count += incBy;
    
    [self setOuncesCaught:[NSNumber numberWithInteger:count]];
}

- (void)decOuncesCaught:(NSInteger)decBy {
    NSInteger count = [self.ouncesCaught integerValue];
    count -= decBy;
    
    [self setOuncesCaught:[NSNumber numberWithInteger:count]];
}

@end
