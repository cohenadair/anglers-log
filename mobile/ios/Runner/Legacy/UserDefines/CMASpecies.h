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

@end
