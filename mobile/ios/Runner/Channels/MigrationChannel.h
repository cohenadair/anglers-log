//
//  MigrationChannel.h
//  Runner
//
//  Created by Cohen Adair on 2021-01-11.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@interface MigrationChannel : NSObject

+ (void)create:(NSObject<FlutterBinaryMessenger> *)messenger;

@end
