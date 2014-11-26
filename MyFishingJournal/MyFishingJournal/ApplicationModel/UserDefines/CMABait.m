//
//  CMABait.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMABait.h"
#import "CMAConstants.h"

@implementation CMABait

#pragma mark - Instance Creation

+ (CMABait *)withName: (NSString *)aName {
    return [[self alloc] initWithName:[aName capitalizedString]];
}

#pragma mark - Initialization

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = aName;
        _baitDescription = nil;
        _image = nil;
    }
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMABaitName"];
        _baitDescription = [aDecoder decodeObjectForKey:@"CMABaitDescription"];
        _image = [aDecoder decodeObjectForKey:@"CMABaitImage"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMABaitName"];
    [aCoder encodeObject:self.baitDescription forKey:@"CMABaitDescription"];
    [aCoder encodeObject:self.image forKey:@"CMABaitImage"];
}

#pragma mark - Editing

- (void)edit: (CMABait *)aNewBait {
    [self setName:[aNewBait.name capitalizedString]];
    [self setBaitDescription:aNewBait.baitDescription];
    [self setImage:aNewBait.image];
}

- (CMABait *)copy {
    CMABait *result = [CMABait new];
    
    [result setName:self.name];
    [result setBaitDescription:self.baitDescription];
    [result setImage:self.image];
    
    return result;
}

#pragma mark - Other

// other
- (BOOL)removedFromUserDefines {
    return [self.name isEqualToString:REMOVED_TEXT];
}

@end
