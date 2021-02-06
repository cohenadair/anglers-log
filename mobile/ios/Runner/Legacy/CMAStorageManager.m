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

- (NSString *)loadJournal {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:[NSEntityDescription entityForName:CDE_JOURNAL
                                        inManagedObjectContext:self.managedObjectContext]];
    NSError *e;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&e];
    
    NSLog(@"CMAJournal fetch request, objects found: %ld", (unsigned long)[results count]);
    
    if ([results count] > 0) {
        self.sharedJournal = [results objectAtIndex:0];
        return [self coreDataLocalURL].path;
    } else {
        return nil;
    }
}

@end
