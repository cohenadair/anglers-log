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

@dynamic entry;
@dynamic baitDescription;
@dynamic image;
@dynamic fishCaught;
@dynamic size;
@dynamic baitType;

#pragma mark - Initialization

- (CMABait *)initWithName:(NSString *)aName {
    self.name = [aName capitalizedString];
    self.baitDescription = nil;
    self.image = nil;
    self.fishCaught = [NSNumber numberWithInteger:0];
    self.baitType = CMABaitTypeArtificial;
    
    return self;
}

// Used to initialize objects created from an archive. For compatibility purposes.
- (void)validateProperties {
    if (!self.name)
        self.name = [NSMutableString string];
    
    if (!self.fishCaught)
        self.fishCaught = [NSNumber numberWithInteger:0];
    
    if (!self.baitType)
        self.baitType = CMABaitTypeArtificial;
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
    [self setImage:aNewBait.image];
    [self setSize:[aNewBait.size capitalizedString]];
    [self setBaitType:aNewBait.baitType];
}

- (CMABait *)copy {
    CMABait *result = [[CMAStorageManager sharedManager] managedBait];
    
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
