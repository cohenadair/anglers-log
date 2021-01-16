//
//  CMAUserDefineObject.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-26.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAUserDefineObject.h"
#import "CMAUtilities.h"
#import "NSString+CMA.h"

@implementation CMAUserDefineObject

@dynamic name;
@dynamic entries;
@dynamic userDefine;

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:[[CMAUtilities capitalizedString:name] mutableCopy] forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (void)addEntry:(CMAEntry *)anEntry {
    [self.entries addObject:anEntry];
}

- (BOOL)containsSearchText:(NSString *)searchText {
    return [self.name.stringByRemovingSpaces.lowercaseString
            containsString:searchText.stringByRemovingSpaces.lowercaseString];
}

@end
