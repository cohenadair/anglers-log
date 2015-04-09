//
//  CMADataImporter.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"

@interface CMADataImporter : NSObject

+ (void)importToJournal:(CMAJournal *)aJournal fromFilePath:(NSString *)aPath;

@end
