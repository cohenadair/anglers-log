//
//  CMAJournal.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAJournal.h"
#import "CMAJSONWriter.h"

@implementation CMAJournal

@dynamic name;
@dynamic entries;
@dynamic userDefines;
@dynamic measurementSystem;
@dynamic entrySortMethod;
@dynamic entrySortOrder;

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitJournal:self];
}

@end
