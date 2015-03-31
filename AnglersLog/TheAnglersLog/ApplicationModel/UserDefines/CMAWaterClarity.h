//
//  CMAWaterClarity.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMAWaterClarity : CMAUserDefineObject <CMAUserDefineProtocol>

// initialization
- (CMAWaterClarity *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;

// editing
- (void)edit:(CMAWaterClarity *)aNewWaterClarity;

@end
