//
//  CMAStorageManager.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"
#import "CMAFishingMethod.h"

@interface CMAStorageManager : NSObject

@property (strong, nonatomic)CMAJournal *sharedJournal;
@property (readonly, strong, nonatomic)NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark - Singleton Methods

+ (id)sharedManager;

#pragma mark - Directories

- (NSURL *)documentsSubDirectory:(NSString *)aString;
- (NSURL *)documentsDirectory;

#pragma mark - Core Data Management

- (void)cleanImages;
- (NSURL *)coreDataLocalURL;
- (void)saveJournal;
- (void)loadJournal;
- (void)deleteManagedObject:(NSManagedObject *)aManagedObject saveContext:(BOOL)aBool;
- (void)deleteAllObjectsForEntityName:(NSString *)anEntityName;

#pragma mark - Core Data Debugging

- (void)debugCoreDataObjects;

#pragma mark - Core Data Object Initializers

- (CMAJournal *)managedJournal;
- (CMAEntry *)managedEntry;
- (CMABait *)managedBait;
- (CMALocation *)managedLocation;
- (CMAFishingSpot *)managedFishingSpot;
- (CMASpecies *)managedSpecies;
- (CMAFishingMethod *)managedFishingMethod;
- (CMAWaterClarity *)managedWaterClarity;
- (CMAUserDefine *)managedUserDefine;
- (CMAWeatherData *)managedWeatherData;
- (CMAImage *)managedImage;

@end
