//
//  CMAStorageManager.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournal.h"

@interface CMAStorageManager : NSObject

@property (strong, nonatomic)CMAJournal *sharedJournal;
@property (readonly, strong, nonatomic)NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark - Singleton Methods

+ (CMAStorageManager *)sharedManager;

#pragma mark - Directories

- (NSURL *)documentsSubDirectory:(NSString *)aString;
- (NSURL *)documentsDirectory;

#pragma mark - Core Data Management

- (NSURL *)coreDataLocalURL;
- (NSString *)loadJournal;

@end
