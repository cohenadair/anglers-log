//
//  CMALocation.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAUserDefineObject.h"

@interface CMALocation : CMAUserDefineObject <CMAUserDefineProtocol>

@property (strong, nonatomic)NSMutableOrderedSet *fishingSpots;

@end
