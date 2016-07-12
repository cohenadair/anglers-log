//
//  CMADataExport.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-08.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"

@interface CMADataExporter : NSObject

+ (NSURL *)exportJournal:(CMAJournal *)aJournal;

@end
