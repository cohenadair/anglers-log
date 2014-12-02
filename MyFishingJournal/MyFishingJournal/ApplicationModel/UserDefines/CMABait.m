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
        _name = [aName capitalizedString];
        _baitDescription = nil;
        _image = nil;
        _fishCaught = [NSNumber numberWithInteger:0];
    }
    
    return self;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMABaitName"];
        _baitDescription = [aDecoder decodeObjectForKey:@"CMABaitDescription"];
        _image = [aDecoder decodeObjectForKey:@"CMABaitImage"];
        _fishCaught = [aDecoder decodeObjectForKey:@"CMABaitFishCaught"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMABaitName"];
    [aCoder encodeObject:self.baitDescription forKey:@"CMABaitDescription"];
    [aCoder encodeObject:self.image forKey:@"CMABaitImage"];
    [aCoder encodeObject:self.fishCaught forKey:@"CMABaitFishCaught"];
}

#pragma mark - Editing

- (void)setName:(NSMutableString *)name {
    _name = [[name capitalizedString] mutableCopy];
}

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

- (void)incFishCaught: (NSInteger)incBy {
    NSInteger count = [self.fishCaught integerValue];
    count += incBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

- (void)decFishCaught: (NSInteger)decBy {
    NSInteger count = [self.fishCaught integerValue];
    count -= decBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

#pragma mark - Other

// other
- (BOOL)removedFromUserDefines {
    return [self.name isEqualToString:REMOVED_TEXT];
}

@end
