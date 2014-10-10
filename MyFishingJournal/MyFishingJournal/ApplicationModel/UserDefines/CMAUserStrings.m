//
//  CMAUserStrings.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserStrings.h"

@implementation CMAUserStrings

// instance creation
+ (CMAUserStrings *)withName: (NSString *)aName {
    return [[self alloc] initWithName:aName];
}

// initializing
- (CMAUserStrings *)initWithName: (NSString *)aName {
    self = [super initWithName:aName];
    return self;
}

// updates self's string with aNewString's string
- (void)editString: (NSMutableString *)aString newString: (NSString *)aNewString {
    [aString setString:aNewString];
}

// returns nil if a string with aName doesn't exist
- (NSMutableString *)stringNamed: (NSString *)aName {
    for (NSMutableString *str in self.objects)
        if ([str caseInsensitiveCompare:aName] == NSOrderedSame)
            return str;
    
    return nil;
}

@end
