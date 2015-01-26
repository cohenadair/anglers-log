//
//  CMAUserDefineObject.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-26.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAUserDefineObject.h"

@implementation CMAUserDefineObject

@dynamic name;

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:[[name capitalizedString] mutableCopy] forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

@end
