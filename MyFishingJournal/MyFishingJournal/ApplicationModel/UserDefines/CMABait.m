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

- (id)init {
    return [self initWithName:@""];
}

- (id)initWithName: (NSString *)aName {
    if (self = [super init]) {
        _name = [aName capitalizedString];
        _baitDescription = nil;
        _image = nil;
        _fishCaught = [NSNumber numberWithInteger:0];
        _baitType = [NSNumber numberWithInteger:CMABaitTypeArtificial];
    }
    
    return self;
}

// Used to initialize objects created from an archive. For compatibility purposes.
- (void)validateProperties {
    if (!self.name)
        self.name = [NSMutableString string];
    
    if (!self.fishCaught)
        self.fishCaught = [NSNumber numberWithInteger:0];
    
    if (!self.baitType)
        self.baitType = [NSNumber numberWithInt:CMABaitTypeArtificial];
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMABaitName"];
        _baitDescription = [aDecoder decodeObjectForKey:@"CMABaitDescription"];
        _image = [aDecoder decodeObjectForKey:@"CMABaitImage"];
        _fishCaught = [aDecoder decodeObjectForKey:@"CMABaitFishCaught"];
        _size = [aDecoder decodeObjectForKey:@"CMABaitSize"];
        _baitType = [aDecoder decodeObjectForKey:@"CMABaitType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMABaitName"];
    [aCoder encodeObject:self.baitDescription forKey:@"CMABaitDescription"];
    [aCoder encodeObject:self.image forKey:@"CMABaitImage"];
    [aCoder encodeObject:self.fishCaught forKey:@"CMABaitFishCaught"];
    [aCoder encodeObject:self.size forKey:@"CMABaitSize"];
    [aCoder encodeObject:self.baitType forKey:@"CMABaitType"];
}

#pragma mark - Editing

- (void)setName:(NSMutableString *)name {
    _name = [[name capitalizedString] mutableCopy];
}

- (void)edit: (CMABait *)aNewBait {
    [self setName:[aNewBait.name capitalizedString]];
    [self setBaitDescription:aNewBait.baitDescription];
    [self setImage:aNewBait.image];
    [self setSize:[aNewBait.size capitalizedString]];
    [self setBaitType:aNewBait.baitType];
}

- (CMABait *)copy {
    CMABait *result = [CMABait new];
    
    [result setName:self.name];
    [result setBaitDescription:self.baitDescription];
    [result setImage:self.image];
    [result setBaitType:self.baitType];
    [result setSize:self.size];
    [result setFishCaught:self.fishCaught];
    
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
