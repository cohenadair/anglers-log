//
//  CMAStorageManager.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournalDocument.h"
#import "CMAFishingMethod.h"
#import "CMAImage.h"

@interface CMAStorageManager : NSObject

@property (nonatomic) __block BOOL cloudFileDidDownload;
@property (nonatomic) __block BOOL cloudDownloadInitiated;

@property (strong, nonatomic)CMAJournal *sharedJournal;
@property (strong, nonatomic)NSMetadataQuery *cloudQuery;
@property (nonatomic)BOOL isCloudBackupEnabled;

+ (id)sharedManager;
- (void)saveJournal:(CMAJournal *)aJournal withFileName:(NSString *)aFileName;
- (void)loadJournalWithCloudEnabled:(BOOL)isCloudEnabled;
- (void)postJournalChangeNotification;
- (NSURL *)cloudURLWithFileName;
- (NSURL *)localURLWithFileName;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark - Core Data

- (NSURL *)coreDataURL;
- (void)saveContext;
- (void)deleteManagedObject:(NSManagedObject *)aManagedObject;

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
