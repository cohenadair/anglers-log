//
//  CMAStorageManager.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAStorageManager.h"
#import "CMAUtilities.h"

@implementation CMAStorageManager

#pragma mark - Initializing

- (void)setSharedJournal:(CMAJournal *)sharedJournal {
    _sharedJournal = sharedJournal;
    [_sharedJournal handleModelUpdate];
    [_sharedJournal initProperties];
}

#pragma mark - Singleton Methods

+ (CMAStorageManager *)sharedManager {
    static CMAStorageManager *sharedStorageManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedStorageManager = [self new];
    });
    
    return sharedStorageManager;
}

#pragma mark - Directories

// Returns the storage directory of aString where aString is a subdirectory in the application's Documents directory.
// If the directory doesn't exist, one is created.
- (NSURL *)documentsSubDirectory:(NSString *)aString {
    NSURL *result = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    result = [result URLByAppendingPathComponent:aString];
    
    NSError *e;
    if (![[NSFileManager defaultManager] fileExistsAtPath:result.path])
        [[NSFileManager defaultManager] createDirectoryAtPath:result.path withIntermediateDirectories:NO attributes:nil error:&e];
    
    return result;
}

- (NSURL *)documentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)coreDataLocalURL {
    // The directory the application uses to store the Core Data store file.
    NSURL *result = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    result = [result URLByAppendingPathComponent:@"TheAnglersLog"];
    
    NSError *e;
    if (![[NSFileManager defaultManager] fileExistsAtPath:result.path])
        // create TheAnglersLog directory if it doesn't exist
        [[NSFileManager defaultManager] createDirectoryAtPath:result.path
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&e];
    
    return result;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TheAnglersLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self coreDataLocalURL] URLByAppendingPathComponent:@"TheAnglersLog.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options = @{NSSQLitePragmasOption: @{@"journal_mode" : @"DELETE"},
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    
    NSPersistentStore *store;
    
    if (!(store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])) {
        // Report any errors we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        NSLog(@"Error in persistentStoreCoordinator: %@, %@", error, [error userInfo]);
    }
    
    NSLog(@"%@", [store URL]);
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext =
            [NSManagedObjectContext.alloc initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Management

/**
 * Returns the path to Anglers' Log's images directory.
 */
- (NSString *)imagesDirectoryPath {
    return [self documentsSubDirectory:@"Images"].path;
}

/**
 * Returns an array of paths to all the user's photos.
 */
- (NSArray<NSString *> *)imageFilePaths {
    return [[NSFileManager defaultManager]
                contentsOfDirectoryAtPath:[self imagesDirectoryPath]
                                    error:nil];
}

/**
 * Iterates through all the users entries and baits, resaving each image as JPG.
 */
- (void)convertAllPngToJpg {
    NSMutableOrderedSet *entries = self.sharedJournal.entries;
    NSMutableOrderedSet *baits = self.sharedJournal.baits;
    
    for (CMAEntry *entry in entries) {
        for (int i = 0; i < entry.imageCount; i++) {
            [entry.images[i] resaveAsJpgWithIndex:i];
        }
    }
    
    for (CMABait *bait in baits) {
        [bait.imageData resaveAsJpgWithIndex:0];
    }
    
    [self.sharedJournal archive];
}

- (void)cleanImages {
    [CMAUtilities runInBackground:^{
        
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        BOOL found;
        int removeCount = 0;
        NSMutableArray *entryPaths = [NSMutableArray array];
        NSArray *imageFiles = [self imageFilePaths];
        
        // get all imagePaths
        for (CMAEntry *e in self.sharedJournal.entries)
            for (CMAImage *img in [e images])
                [entryPaths addObject:img.imagePath];
        
        for (CMABait *b in [[self.sharedJournal userDefineNamed:UDN_BAITS] baits])
            if (b.imageData)
                [entryPaths addObject:b.imageData.imagePath];
        
        if ([entryPaths count] == [imageFiles count]) {
            NSLog(@"No excess images.");
            return;
        }
        
        for (NSString *filePath in imageFiles) {
            found = NO;
            
            for (NSString *imgPath in entryPaths)
                if ([imgPath containsString:filePath]) {
                    found = YES;
                    break;
                }
            
            if (!found) {
                NSError *e;
                if (![[NSFileManager defaultManager] removeItemAtPath:[[self imagesDirectoryPath] stringByAppendingPathComponent:filePath] error:&e])
                    NSLog(@"Failed to delete image: %@", e.localizedDescription);
                else
                    removeCount++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           NSLog(@"Removed %d images in %f ms.", removeCount, CFAbsoluteTimeGetCurrent() - start);
        });
    }];
}

- (void)saveJournal {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges]) {
            NSLog(@"Saving data...");
            
            if (![managedObjectContext save:&error]) {
                NSLog(@"Failed to save data: %@.", [error localizedDescription]);
                
                NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                if (detailedErrors != nil && [detailedErrors count] > 0) {
                    for (NSError* detailedError in detailedErrors) {
                        NSLog(@"DetailedError: %@", [detailedError userInfo]);
                    }
                }
            } else
                NSLog(@"Saved library data.");
        } else
            NSLog(@"No changes made.");
    }
}

- (BOOL)loadJournal {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[self entityNamed:CDE_JOURNAL]];
    NSError *e;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&e];
    
    NSLog(@"CMAJournal fetch request, objects found: %ld", (unsigned long)[results count]);
    
    if ([results count] > 0) {
        self.sharedJournal = [results objectAtIndex:0];
        return true;
    } else {
        return false;
    }
}

- (CMABait *)rapalaBait {
    CMABait *result = [[CMAStorageManager sharedManager] managedBait];
    CMAImage *img = [[CMAStorageManager sharedManager] managedImage];
    [img setFullImage:[UIImage imageNamed:@"rapala.jpg"]];
    
    [result setName:@"Rippin' Rap"];
    [result setColor:@"Blue Chrome"];
    [result setSize:@"2"];
    [result setBaitType:CMABaitTypeArtificial];
    [result setImageData:img];
    [result.imageData saveWithIndex:0 completion:nil];

    return result;
}

- (CMABait *)spinnerBait {
    CMABait *result = [[CMAStorageManager sharedManager] managedBait];
    CMAImage *img = [[CMAStorageManager sharedManager] managedImage];
    [img setFullImage:[UIImage imageNamed:@"spinner.jpg"]];
    
    [result setName:@"Spinner - Blue Fox"];
    [result setColor:@"Silver"];
    [result setSize:@"6"];
    [result setBaitType:CMABaitTypeArtificial];
    [result setImageData:img];
    [result.imageData saveWithIndex:1 completion:nil];
    
    return result;
}

- (void)addJournalDefaults {
    NSArray *species = @[@"Bass - Smallmouth", @"Trout - Rainbow", @"Walleye", @"Bass - Largemouth", @"Salmon - King"];
    NSArray *methods = @[@"Boat", @"Ice", @"Casting", @"Fly", @"Shore", @"Trolling"];
    NSArray *clarities = @[@"Clear", @"Crystal", @"Cloudy", @"3 Feet", @"Dirty"];
    
    for (NSString *s in species) {
        [self.sharedJournal addUserDefine:UDN_SPECIES
                              objectToAdd:[[self.sharedJournal userDefineNamed:UDN_SPECIES] emptyObjectNamed:s]
                                   notify:NO];
    }
    
    for (NSString *s in methods) {
        [self.sharedJournal addUserDefine:UDN_FISHING_METHODS
                              objectToAdd:[[self.sharedJournal userDefineNamed:UDN_FISHING_METHODS] emptyObjectNamed:s]
                                   notify:NO];
    }
    
    for (NSString *s in clarities) {
        [self.sharedJournal addUserDefine:UDN_WATER_CLARITIES
                              objectToAdd:[[self.sharedJournal userDefineNamed:UDN_WATER_CLARITIES] emptyObjectNamed:s]
                                   notify:NO];
    }
    
    [self.sharedJournal addUserDefine:UDN_BAITS objectToAdd:self.rapalaBait notify:NO];
    [self.sharedJournal addUserDefine:UDN_BAITS objectToAdd:self.spinnerBait notify:NO];
}

// Deletes aManagedObject from the context. Will apply changes to context if aBool is true.
- (void)deleteManagedObject:(NSManagedObject *)aManagedObject saveContext:(BOOL)aBool {
    if (aManagedObject) {
        [self.managedObjectContext deleteObject:aManagedObject];
        
        if (aBool) {
            [self saveJournal];
             NSLog(@"Initializing save after delete...");
        }
    }
}

- (void)deleteAllObjectsForEntityName:(NSString *)anEntityName {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext]];
    
    NSError *e;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&e];
    
    for (id obj in results)
        [self.managedObjectContext deleteObject:obj];
    
    [self saveJournal];
}

#pragma mark - Core Data Debugging

- (void)debugCoreDataObjects {
    NSLog(@"Analyzing Core Data objects...");
    
    [self debugCMAImageFetch];
    [self debugCMAUserDefineFetchNamed:UDN_BAITS andEntityName:CDE_BAIT];
    [self debugCMAUserDefineFetchNamed:UDN_LOCATIONS andEntityName:CDE_LOCATION];
    [self debugCMAUserDefineFetchNamed:UDN_FISHING_METHODS andEntityName:CDE_FISHING_METHOD];
    [self debugCMAUserDefineFetchNamed:UDN_WATER_CLARITIES andEntityName:CDE_WATER_CLARITY];
    [self debugCMAUserDefineFetchNamed:UDN_SPECIES andEntityName:CDE_SPECIES];
    [self debugCMAFishingSpotFetch];
    [self debugCMAEntryFetch];
    [self debugCMAWeatherDataFetch];
    [self debugSavedImages];
}

- (void)debugCMAImageFetch {
    NSArray *results = [self fetchEntityNamed:CDE_IMAGE];
    NSInteger journalImageCount = 0;
    
    for (CMAEntry *e in self.sharedJournal.entries)
        journalImageCount += [e imageCount];
    
    for (CMABait *b in [[self.sharedJournal userDefineNamed:UDN_BAITS] activeSet])
        if ([b imageData])
            journalImageCount++;
    
    [self printEntityFetchResultsNamed:CDE_IMAGE withCount:[results count] andExpectedCount:journalImageCount];
}

- (void)debugCMAUserDefineFetchNamed:(NSString *)aName andEntityName:(NSString *)anEntityName {
    NSArray *results = [self fetchEntityNamed:anEntityName];
    NSInteger objCount = [[self.sharedJournal userDefineNamed:aName] count];
    [self printEntityFetchResultsNamed:anEntityName withCount:[results count] andExpectedCount:objCount];
}

- (void)debugCMAFishingSpotFetch {
    NSArray *results = [self fetchEntityNamed:CDE_FISHING_SPOT];
    NSInteger journalFishingSpotCount = 0;
    
    for (CMALocation *l in [[self.sharedJournal userDefineNamed:UDN_LOCATIONS] activeSet])
        journalFishingSpotCount += [l fishingSpotCount];
    
    [self printEntityFetchResultsNamed:CDE_FISHING_SPOT withCount:[results count] andExpectedCount:journalFishingSpotCount];
}

- (void)debugCMAEntryFetch {
    NSArray *results = [self fetchEntityNamed:CDE_ENTRY];
    NSInteger journalEntryCount = [self.sharedJournal entryCount];
    [self printEntityFetchResultsNamed:CDE_ENTRY withCount:[results count] andExpectedCount:journalEntryCount];
}

- (void)debugCMAWeatherDataFetch {
    NSArray *results = [self fetchEntityNamed:CDE_WEATHER_DATA];
    NSInteger journalWeatherCount = 0;
    
    for (CMAEntry *e in [self.sharedJournal entries])
        if (e.weatherData)
            journalWeatherCount++;
    
    [self printEntityFetchResultsNamed:CDE_WEATHER_DATA withCount:[results count] andExpectedCount:journalWeatherCount];
}

- (void)debugSavedImages {
    NSInteger expectedCount = 0;
    NSInteger actualCount = 0;
    
    for (CMAEntry *e in [self.sharedJournal entries])
        expectedCount += e.imageCount;
    
    for (CMABait *b in [[self.sharedJournal userDefineNamed:UDN_BAITS] activeSet])
        expectedCount += (b.imageData != nil);
    
    NSArray *imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsSubDirectory:@"Images"].path error:nil];
    actualCount = [imageFiles count];
    
    [self printEntityFetchResultsNamed:@"Saved Images" withCount:actualCount andExpectedCount:expectedCount];
}

- (NSArray *)fetchEntityNamed:(NSString *)anEntity {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[self entityNamed:anEntity]];
    
    NSError *e;
    return [[self managedObjectContext] executeFetchRequest:fetchRequest error:&e];
}

- (void)printEntityFetchResultsNamed:(NSString *)anEntity withCount:(NSInteger)count andExpectedCount:(NSInteger)expectedCount {
    NSString *fetched = [NSString stringWithFormat:@"Fetched: %ld", (long)count];
    fetched = [fetched stringByPaddingToLength:14 withString:@" " startingAtIndex:0];
    
    NSString *expected = [NSString stringWithFormat:@"Expected: %ld", (long)expectedCount];
    expected = [expected stringByPaddingToLength:15 withString:@" " startingAtIndex:0];
    
    NSLog(@"    %@%@Entity: %@", fetched, expected, anEntity);
}

#pragma mark - Core Data Object Initializers
// These methods are used to make initializing Core Data manged objects easier.
// The managed objects are added to self.managedObjectContext, so they need to be removed when necessary.
// Example:
//   self.bait = [[CMAStorageManager sharedManager] managedBait];

- (NSEntityDescription *)entityNamed:(NSString *)aCDEString {
    return [NSEntityDescription entityForName:aCDEString
                       inManagedObjectContext:self.managedObjectContext];
}

- (CMAJournal *)managedJournal {
    CMAJournal *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_JOURNAL inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"log_1"];
}

- (CMAEntry *)managedEntry {
    CMAEntry *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_ENTRY inManagedObjectContext:self.managedObjectContext];
    return [result initWithDate:[NSDate date]];
}

- (CMABait *)managedBait {
    CMABait *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_BAIT inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"" andUserDefine:[self.sharedJournal userDefineNamed:UDN_BAITS]];
}

- (CMALocation *)managedLocation {
    CMALocation *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_LOCATION inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"" andUserDefine:[self.sharedJournal userDefineNamed:UDN_LOCATIONS]];
}

- (CMAFishingSpot *)managedFishingSpot {
    CMAFishingSpot *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_FISHING_SPOT inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@""];
}

- (CMASpecies *)managedSpecies {
    CMASpecies *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_SPECIES inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"" andUserDefine:[self.sharedJournal userDefineNamed:UDN_SPECIES]];
}

- (CMAFishingMethod *)managedFishingMethod {
    CMAFishingMethod *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_FISHING_METHOD inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"" andUserDefine:[self.sharedJournal userDefineNamed:UDN_FISHING_METHODS]];
}

- (CMAWaterClarity *)managedWaterClarity {
    CMAWaterClarity *result = [NSEntityDescription insertNewObjectForEntityForName:CDE_WATER_CLARITY inManagedObjectContext:self.managedObjectContext];
    return [result initWithName:@"" andUserDefine:[self.sharedJournal userDefineNamed:UDN_WATER_CLARITIES]];
}

- (CMAUserDefine *)managedUserDefine {
    return [NSEntityDescription insertNewObjectForEntityForName:CDE_USER_DEFINE inManagedObjectContext:self.managedObjectContext];
}

- (CMAWeatherData *)managedWeatherData {
    return [NSEntityDescription insertNewObjectForEntityForName:CDE_WEATHER_DATA inManagedObjectContext:self.managedObjectContext];
}

- (CMAImage *)managedImage {
    return [NSEntityDescription insertNewObjectForEntityForName:CDE_IMAGE inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - User Settings

#define kUserSettingMapType @"UserMapType"

// Uses + and - 1 because if the key doesn't exist the default is 0 and the default needs to be 1.
// The type integers are MKMapType and are used in a UISegmentedControl.
// So 1, 2, and 3 are stored rather than 0, 1, 2.
- (void)setUserMapType:(MKMapType)mapType {
    [[NSUserDefaults standardUserDefaults] setInteger:mapType + 1 forKey:kUserSettingMapType];
}

- (MKMapType)getUserMapType {
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:kUserSettingMapType];
    if (type == 0)
        [self setUserMapType:MKMapTypeSatellite];
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUserSettingMapType] - 1;
}

@end
