//
//  CMAFishingMethod.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAFishingMethod.h"

@implementation CMAFishingMethod

@dynamic name;

#pragma mark - Initialization

- (CMAFishingMethod *)initWithName: (NSString *)aName {
    self.name = aName;
    
    return self;
}

// Used to initialize objects created from an archive. For compatibility purposes.
- (void)validateProperties {
    if (!self.name)
        self.name = [NSMutableString string];
}

#pragma mark - Archiving
/*
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMAFishingMethodName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAFishingMethodName"];
}
*/
#pragma mark - Editing

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:[[name capitalizedString] mutableCopy] forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (void)edit:(CMAFishingMethod *)aNewFishingMethod {
    [self setName:[aNewFishingMethod.name capitalizedString]];
}

@end
