//
//  CMABait.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/27/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMABait.h"
#import "CMAStorageManager.h"
#import "CMAJSONWriter.h"

@implementation CMABait

@dynamic baitDescription;
@dynamic imageData;
@dynamic fishCaught;
@dynamic size;
@dynamic color;
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

- (void)handleModelUpdate {
    if (self.imageData)
        [self.imageData handleModelUpdate];
}

#pragma mark - Editing

- (void)setSize:(NSString *)size {
    [self willChangeValueForKey:@"size"];
    [self setPrimitiveValue:[size capitalizedString] forKey:@"size"];
    [self didChangeValueForKey:@"size"];
}

- (void)setColor:(NSString *)color {
    [self willChangeValueForKey:@"color"];
    [self setPrimitiveValue:[color capitalizedString] forKey:@"color"];
    [self didChangeValueForKey:@"color"];
}

- (void)edit:(CMABait *)aNewBait {
    [self setName:[aNewBait.name capitalizedString]];
    [self setBaitDescription:aNewBait.baitDescription];
    [self setImageData:aNewBait.imageData];
    [self setSize:[aNewBait.size capitalizedString]];
    [self setColor:[aNewBait.color capitalizedString]];
    [self setBaitType:aNewBait.baitType];
}

- (void)incFishCaught:(NSInteger)incBy {
    NSInteger count = [self.fishCaught integerValue];
    count += incBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

- (void)decFishCaught:(NSInteger)decBy {
    NSInteger count = [self.fishCaught integerValue];
    count -= decBy;
    
    [self setFishCaught:[NSNumber numberWithInteger:count]];
}

#pragma mark - Accessing

- (NSString *)typeAsString {
    if (self.baitType == CMABaitTypeArtificial)
        return @"Artificial";
    else if (self.baitType == CMABaitTypeLive)
        return @"Live";
    else if (self.baitType == CMABaitTypeReal)
        return @"Real";
    else
        NSLog(@"Invalid baitType in [CMABaitInstance typeAsString]");
    
    return @"";
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitBait:self];
}

@end
