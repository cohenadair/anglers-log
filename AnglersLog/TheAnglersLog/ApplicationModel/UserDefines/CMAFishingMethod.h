//
//  CMAFishingMethod.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@class CMAEntry;

@interface CMAFishingMethod : CMAUserDefineObject <CMAUserDefineProtocol>

// initialization
- (CMAFishingMethod *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine;

// editing
- (void)edit:(CMAFishingMethod *)aNewFishingMethod;

@end
