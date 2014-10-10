//
//  CMAUserDefine.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMALocation.h"

@implementation CMAUserDefine

// instance creation
+ (CMAUserDefine *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

// initializing
- (CMAUserDefine *)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
        _objects = [NSMutableSet set];
    }
    
    return self;
}

- (void)addObject: (id)anObject {
    [self.objects addObject:anObject];
}

- (void)removeObject: (id)anObject {
    [self.objects removeObject:anObject];
}

- (NSInteger)count {
    return [self.objects count];
}

@end
