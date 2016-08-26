//
//  CMASpecies.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMASpecies : CMAUserDefineObject <CMAUserDefineProtocol>

@property (strong, nonatomic)NSNumber *numberCaught;
@property (strong, nonatomic)NSNumber *weightCaught;
@property (strong, nonatomic)NSNumber *ouncesCaught;

// initialization
- (CMASpecies *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;

// editing
- (void)edit:(CMASpecies *)aNewSpecies;
- (void)incNumberCaught:(NSInteger)incBy;
- (void)decNumberCaught:(NSInteger)decBy;
- (void)incWeightCaught:(NSInteger)incBy;
- (void)decWeightCaught:(NSInteger)decBy;
- (void)incOuncesCaught:(NSInteger)incBy;
- (void)decOuncesCaught:(NSInteger)decBy;

@end
