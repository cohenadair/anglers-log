//
//  CMAWaterClarity.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2014-12-27.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAWaterClarity.h"

@implementation CMAWaterClarity

@dynamic name;

#pragma mark - Initialization

- (CMAWaterClarity *)initWithName: (NSString *)aName {
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
        _name = [aDecoder decodeObjectForKey:@"CMAWaterClarityName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAWaterClarityName"];
}
*/
#pragma mark - Editing

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:[[name capitalizedString] mutableCopy] forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

- (void)edit:(CMAWaterClarity *)aNewWaterClarity {
    [self setName:[aNewWaterClarity.name capitalizedString]];
}

@end
