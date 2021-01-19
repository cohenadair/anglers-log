//
//  CMAImage.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAImage.h"
#import "CMAJSONWriter.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"

@implementation CMAImage

@dynamic imagePath;
@dynamic entry;
@dynamic bait;

#pragma mark - Getters

- (NSString *)imagePath {
    return [[[CMAStorageManager sharedManager] documentsDirectory].path stringByAppendingPathComponent:[self primitiveValueForKey:@"imagePath"]];
}

// Path relative to /Documents/
- (NSString *)localImagePath {
    return [self primitiveValueForKey:@"imagePath"];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitImage:self];
}

@end
