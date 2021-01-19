//
//  CMABait.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAUserDefineProtocol.h"
#import "CMAConstants.h"
#import "CMAUserDefineObject.h"

@class CMAImage;

@interface CMABait : CMAUserDefineObject <CMAUserDefineProtocol>

@property (strong, nonatomic)NSString *baitDescription;
@property (strong, nonatomic)CMAImage *imageData;
@property (strong, nonatomic)NSNumber *fishCaught;
@property (strong, nonatomic)NSString *size;
@property (strong, nonatomic)NSString *color;
@property (nonatomic)CMABaitType baitType;

@end
