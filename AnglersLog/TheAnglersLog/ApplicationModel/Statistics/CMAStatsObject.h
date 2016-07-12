//
//  CMABaitStatsObject.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/25/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>

@interface CMAStatsObject : NSObject

@property (strong, nonatomic)NSString *name;
@property (nonatomic)NSInteger value;
@property (nonatomic)NSInteger detailValue; // used for ounces, for example

@end
