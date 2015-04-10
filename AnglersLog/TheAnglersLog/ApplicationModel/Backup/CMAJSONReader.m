//
//  CMAJSONReader.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-04-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAJSONReader.h"
#import "CMAStorageManager.h"

@implementation CMAJSONReader

+ (BOOL)JSONToJournal:(CMAJournal *)aJournal jsonFilePath:(NSString *)aFilePath error:(NSString **)errorMsg {
    NSData *jsonData = [NSData dataWithContentsOfFile:aFilePath];
    
    NSError *e;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&e];
    if (e) {
        *errorMsg = ERROR_JSON_READ;
        NSLog(@"Failed to parse JSON: %@", e.localizedDescription);
        return NO;
    }
    
    CMAJSONReader *reader = [[CMAJSONReader alloc] initWithJournal:aJournal];
    [reader jsonToJournal:[json objectForKey:@"journal"]];
    
    return YES;
}

- (CMAJSONReader *)initWithJournal:(CMAJournal *)aJournal {
    if (self = [super init]) {
        _journal = aJournal;
    }
    
    return self;
}

#pragma mark - Parsing Methods

- (BOOL)jsonToJournal:(id)json {
    self.journal.name = [json valueForKey:@"name"];
    
    // user defines need to be done first so the objects are accessible for entries
    [self doArrayFromJSON:json key:@"userDefines" func:^(id obj){ [self addUserDefine:obj]; }];
    [self doArrayFromJSON:json key:@"entries" func:^(id obj){ [self addEntry:obj]; }];
    
    self.journal.measurementSystem = [[json valueForKey:@"measurementSystem"] integerValue];
    self.journal.entrySortMethod = [[json valueForKey:@"entrySortMethod"] integerValue];
    self.journal.entrySortOrder = [[json valueForKey:@"entrySortOrder"] integerValue];
    
    return YES;
}

- (void)addEntry:(id)anEntry {

}

- (CMAImage *)imageFromJSON:(id)anImage {
    if ([anImage count] > 0) {
        CMAImage *img = [[CMAStorageManager sharedManager] managedImage];
        img.imagePath = [anImage valueForKey:@"imagePath"];
        [img initProperties]; // to generate thumbnails
        return img;
    }
    
    return nil;
}

- (void)addUserDefine:(id)aUserDefine {
    CMAUserDefine *ud = [self.journal userDefineNamed:[aUserDefine valueForKey:@"name"]];
        
    if ([ud isSetOfBaits])           [self doArrayFromJSON:aUserDefine key:@"baits" func:^(id obj) { [self addBait:obj]; }];
    if ([ud isSetOfLocations])       [self doArrayFromJSON:aUserDefine key:@"locations" func:^(id obj) { [self addLocation:obj]; }];
    if ([ud isSetOfSpecies])         [self doArrayFromJSON:aUserDefine key:@"species" func:^(id obj) { [self addSpecies:obj]; }];
    if ([ud isSetOfFishingMethods])  [self doArrayFromJSON:aUserDefine key:@"fishingMethods" func:^(id obj) { [self addFishingMethod:obj]; }];
    if ([ud isSetOfWaterClarities])  [self doArrayFromJSON:aUserDefine key:@"waterClarities" func:^(id obj) { [self addWaterClarity:obj]; }];
}

- (void)addBait:(id)aBait {
    CMAUserDefine *ud = [self.journal userDefineNamed:UDN_BAITS];
    
    // create a new clarity if it doesn't already exist
    NSString *name = [aBait valueForKey:@"name"];
    CMABait *b = (CMABait *)[ud objectNamed:name];
    if (b == nil) {
        b = [[CMAStorageManager sharedManager] managedBait];
        [ud addObject:b];
    }
    
    b.name = name;
    b.baitDescription = [aBait valueForKey:@"baitDescription"];
    if ([b.baitDescription isEqualToString:@""])
        b.baitDescription = nil;
    
    b.imageData = [self imageFromJSON:[aBait objectForKey:@"image"]];
    
    b.size = [aBait valueForKey:@"size"];
    if ([b.size isEqualToString:@""])
        b.size = nil;
    
    b.color = [aBait valueForKey:@"color"];
    if ([b.color isEqualToString:@""])
        b.color = nil;
    
    b.baitType = [[aBait valueForKey:@"baitType"] integerValue];
    [b incFishCaught:[[aBait valueForKey:@"fishCaught"] integerValue]];
}

- (void)addLocation:(id)aLocation {
    CMAUserDefine *ud = [self.journal userDefineNamed:UDN_LOCATIONS];
    
    // create new if it doesn't already exist
    NSString *name = [aLocation valueForKey:@"name"];
    CMALocation *l = (CMALocation *)[ud objectNamed:name];
    if (l == nil) {
        l = [[CMAStorageManager sharedManager] managedLocation];
        [ud addObject:l];
    }
    
    l.name = name;
    
    NSArray *fishingSpots = [aLocation objectForKey:@"fishingSpots"];
    for (id obj in fishingSpots)
        [self addFishingSpot:obj toLocation:l];
}

- (void)addFishingSpot:(id)aFishingSpot toLocation:(CMALocation *)aLocation {
    NSString *name = [aFishingSpot valueForKey:@"name"];
    CMAFishingSpot *f = [aLocation fishingSpotNamed:name];
    if (f == nil) {
        f = [[CMAStorageManager sharedManager] managedFishingSpot];
        [aLocation addFishingSpot:f];
    }
    
    f.name = name;
    [f incFishCaught:[[aFishingSpot valueForKey:@"fishCaught"] integerValue]];
    [self addCoordinates:[aFishingSpot objectForKey:@"coordinates"] toFishingSpot:f];
}

- (void)addCoordinates:(id)someCoordinates toFishingSpot:(CMAFishingSpot *)aFishingSpot {
    [aFishingSpot setCoordinates:CLLocationCoordinate2DMake([[someCoordinates valueForKey:@"latitude"] floatValue], [[someCoordinates valueForKey:@"longitude"] floatValue])];
}

- (void)addFishingMethod:(id)aFishingMethod {
    CMAUserDefine *ud = [self.journal userDefineNamed:UDN_FISHING_METHODS];
    
    // create new if it doesn't already exist
    NSString *name = [aFishingMethod valueForKey:@"name"];
    CMAFishingMethod *m = (CMAFishingMethod *)[ud objectNamed:name];
    if (m == nil) {
        m = [[CMAStorageManager sharedManager] managedFishingMethod];
        [ud addObject:m];
    }
    
    m.name = name;
}

- (void)addWaterClarity:(id)aWaterClarity {
    CMAUserDefine *ud = [self.journal userDefineNamed:UDN_WATER_CLARITIES];
    
    // create new if it doesn't already exist
    NSString *name = [aWaterClarity valueForKey:@"name"];
    CMAWaterClarity *c = (CMAWaterClarity *)[ud objectNamed:name];
    if (c == nil) {
        c = [[CMAStorageManager sharedManager] managedWaterClarity];
        [ud addObject:c];
    }
    
    c.name = name;
}

- (void)addSpecies:(id)aSpecies {
    CMAUserDefine *ud = [self.journal userDefineNamed:UDN_SPECIES];
    
    // create new if it doesn't already exist
    NSString *name = [aSpecies valueForKey:@"name"];
    CMASpecies *s = (CMASpecies *)[ud objectNamed:name];
    if (s == nil) {
        s = [[CMAStorageManager sharedManager] managedSpecies];
        [ud addObject:s];
    }
    
    s.name = name;
    [s incNumberCaught:[[aSpecies valueForKey:@"numberCaught"] integerValue]];
    [s incWeightCaught:[[aSpecies valueForKey:@"weightCaught"] integerValue]];
    [s incOuncesCaught:[[aSpecies valueForKey:@"ouncesCaught"] integerValue]];
}

#pragma mark - Helper Methods

- (void)doArrayFromJSON:(id)json key:(NSString *)aKey func:(void (^)(id))aFunc {
    NSArray *arr = [json objectForKey:aKey];
    for (id obj in arr)
        aFunc(obj);
}

- (NSNumber *)addNumber:(id)a to:(id)b {
    return [NSNumber numberWithInteger:[a integerValue] + [b integerValue]];
}

@end
