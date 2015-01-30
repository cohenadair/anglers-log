//
//  CMABait.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMABait.h"
#import "CMAStorageManager.h"

@implementation CMABait

@dynamic entries;
@dynamic userDefine;

@dynamic baitDescription;
@dynamic imageData;
@dynamic fishCaught;
@dynamic size;
@dynamic baitType;

#pragma mark - Initialization

- (CMABait *)initWithName:(NSString *)aName andUserDefine:(CMAUserDefine *)aUserDefine {
    self.name = [aName capitalizedString];
    self.baitDescription = nil;
    self.imageData = nil;
    self.fishCaught = [NSNumber numberWithInteger:0];
    self.baitType = CMABaitTypeArtificial;
    self.entries = [NSMutableSet set];
    self.userDefine = aUserDefine;
    
    return self;
}

// Used to initialize objects created from an archive. For compatibility purposes.
- (void)validateProperties {
    if (!self.name)
        self.name = [NSMutableString string];
    
    if (!self.fishCaught)
        self.fishCaught = [NSNumber numberWithInteger:0];
}

#pragma mark - Archiving
/*
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMABaitName"];
        _baitDescription = [aDecoder decodeObjectForKey:@"CMABaitDescription"];
        _image = [aDecoder decodeObjectForKey:@"CMABaitImage"];
        _size = [aDecoder decodeObjectForKey:@"CMABaitSize"];
        _baitType = [aDecoder decodeObjectForKey:@"CMABaitType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMABaitName"];
    [aCoder encodeObject:self.baitDescription forKey:@"CMABaitDescription"];
    [aCoder encodeObject:self.image forKey:@"CMABaitImage"];
    [aCoder encodeObject:self.size forKey:@"CMABaitSize"];
    [aCoder encodeObject:self.baitType forKey:@"CMABaitType"];
}
*/
#pragma mark - Editing

- (void)setSize:(NSString *)size {
    [self willChangeValueForKey:@"size"];
    [self setPrimitiveValue:[size capitalizedString] forKey:@"size"];
    [self didChangeValueForKey:@"size"];
}

- (void)edit: (CMABait *)aNewBait {
    [self setName:[aNewBait.name capitalizedString]];
    [self setBaitDescription:aNewBait.baitDescription];
    [self setImageData:aNewBait.imageData];
    [self setSize:[aNewBait.size capitalizedString]];
    [self setBaitType:aNewBait.baitType];
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

- (void)addEntry:(CMAEntry *)anEntry {
    [self.entries addObject:anEntry];
}

@end
