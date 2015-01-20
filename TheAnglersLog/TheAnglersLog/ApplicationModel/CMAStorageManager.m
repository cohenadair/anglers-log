//
//  CMAStorageManager.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAStorageManager.h"

@implementation CMAStorageManager

#pragma mark - Initializing

- (void)setSharedJournal:(CMAJournal *)sharedJournal {
    _sharedJournal = sharedJournal;
    [_sharedJournal validateUserDefines];
}

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static CMAStorageManager *sharedStorageManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedStorageManager = [self new];
    });
    
    return sharedStorageManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Journal Saving

// If saving to iCloud, will use CMAJournalDocument to archive and save data in a UIDocument.
// If saving to local storage, will simply archive the journal object.

- (void)saveJournal:(CMAJournal *)aJournal withFileName:(NSString *)aFileName {
    [self setSharedJournal:aJournal];
    __block CMAJournal *journal = [aJournal copy];
    
    // archive the journal in a separate thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.isCloudBackupEnabled)
            [self archiveJournal:journal toURL:[self cloudURL] withFileName:aFileName isLocal:NO];

        [self archiveJournal:journal toURL:[self localURL] withFileName:aFileName isLocal:YES]; // always save locally as well incase iCloud is disabled later
        journal = nil;
    });
}

- (void)archiveJournal:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName isLocal:(BOOL)isLocal {
    if (aURL) {
        if (isLocal)
            [self archiveJournalToLocalStorage:aJournal toURL:aURL withFileName:aFileName];
        else
            [self archiveJournalToCloudStorage:aJournal toURL:aURL withFileName:aFileName];
    } else
        NSLog(@"%@ URL = NULL", isLocal ? @"Local" : @"iCloud");
}

- (void)archiveJournalToCloudStorage:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName {
    NSURL *documentURL = [aURL URLByAppendingPathComponent:aFileName];
    
    CMAJournalDocument *document = [[CMAJournalDocument alloc] initWithFileURL:documentURL];
    document.journal = aJournal;
    
    [document saveToURL:documentURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        NSLog(@"Was iCloud save successful? %@", success ? @"YES" : @"NO");
    }];
}

- (void)archiveJournalToLocalStorage:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName {
    NSString *filePath = [aURL URLByAppendingPathComponent:aFileName].path;
    BOOL success = [NSKeyedArchiver archiveRootObject:aJournal toFile:filePath];
    
    NSLog(@"Was local save successful? %@", success ? @"YES" : @"NO");
}

#pragma mark - Cloud URL Methods

- (NSURL *)cloudURL {
    NSURL *result = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (result)
        result = [result URLByAppendingPathComponent:@"Documents"];
    else
        NSLog(@"Ubiquity URL is nil.");
    
    return result;
}

- (NSURL *)localURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *result = [NSURL fileURLWithPath:[paths firstObject]];
    
    if (!result)
        NSLog(@"Local URL is nil.");
    
    return result;
}

- (NSURL *)cloudURLWithFileName {
    return [[self cloudURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME];
}

- (NSURL *)localURLWithFileName {
    return [[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME];
}

#pragma mark - Journal Loading

// An NSMetadataQuery allows the app to receive notifications when the file is updated on iCloud.
// Reference: http://code.tutsplus.com/tutorials/working-with-icloud-document-storage--pre-37952

// Using an NSMetadataQuery is required according to the Apple Documentation because the URL can be changed at any time.

- (void)initCloudQuery {
    NSURL *cloudURL = [self cloudURL];
    
    if (cloudURL) {
        [self setCloudQuery:[NSMetadataQuery new]];
        [self.cloudQuery setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(cloudQueryDidFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:self.cloudQuery];
        [nc addObserver:self selector:@selector(cloudQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.cloudQuery];
        
        [self.cloudQuery startQuery];
    }
}

- (void)cloudQueryDidFinish:(NSNotification *)aNotification {
    [self.cloudQuery disableUpdates];
    
    NSLog(@"Cloud query finished.");
    [self loadJournalFromQueryNotification:aNotification forLiveUpdates:NO];
    
    [self.cloudQuery enableUpdates];
}

- (void)cloudQueryDidUpdate:(NSNotification *)aNotification {
    [self.cloudQuery disableUpdates];
    
    NSLog(@"Cloud query updated.");
    [self loadJournalFromQueryNotification:aNotification forLiveUpdates:YES];
    
    [self.cloudQuery enableUpdates];
}

- (void)loadJournalFromQueryNotification:(NSNotification *)aNotification forLiveUpdates:(BOOL)aBool {
    NSMetadataQuery *cloudQuery = [aNotification object];
    __block BOOL didUpdate = aBool;
    
    [cloudQuery.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = (NSMetadataItem *)obj;
        NSString *downloadingKey = [item valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        NSError *error;
        
        // download the file if it isn't already downloaded or being downloaded
        if (!self.cloudDownloadInitiated && [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusNotDownloaded]) {
            NSLog(@"Downloading data from iCloud...");
            [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:[item valueForAttribute:NSMetadataItemURLKey] error:&error];
            self.cloudDownloadInitiated = YES;
            self.cloudFileDidDownload = YES;
        }
        
        // self.cloudFileDidDownload is used so the journal data isn't updated several times during the initial query
        if (didUpdate && !self.cloudFileDidDownload)
            self.cloudFileDidDownload = [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusDownloaded];
        else
            self.cloudFileDidDownload = YES;
        
        // only update journal data if there is a working local copy (NSMetadataUbiquitousItemDownloadingStatusCurrent)
        if (self.cloudFileDidDownload && [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusCurrent]) {
            NSLog(@"File downloaded, updating journal data.");
            [self loadJournalFromMetadataItem:item];
            self.cloudFileDidDownload = NO;
            self.cloudDownloadInitiated = NO;
        }
    }];
    
    if (cloudQuery.resultCount <= 0) {
        NSLog(@"No journal data found in iCloud, initializing from local storage.");
        [self loadJournalFromLocalStorage];
        
        // move data file to iCloud
        NSError *error;
        [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:[self localURLWithFileName] destinationURL:[self cloudURLWithFileName] error:&error];
        if (error)
            NSLog(@"Error moving file to iCloud: %@", error.localizedDescription);
        else
            NSLog(@"Successfully moved data file to iCloud.");
    }
}

- (void)loadJournalFromMetadataItem:(NSMetadataItem *)item {
    NSURL *documentURL = [item valueForAttribute:NSMetadataItemURLKey];
    CMAJournalDocument *document = [[CMAJournalDocument alloc] initWithFileURL:documentURL];
    
    // gets data from the most recently updated data file, whether it's from iCloud or local storage
    // this is done so the user's data isn't lost if iCloud was disabled for a period time
    
    NSDictionary *localFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path error:NULL];
    NSDictionary *cloudFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self cloudURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path error:NULL];
    NSDate *localLastModified = [localFileAttributes fileModificationDate];
    NSDate *cloudLastModified = [cloudFileAttributes fileModificationDate];
    
    if ([localLastModified compare:cloudLastModified] == NSOrderedDescending) { // if local is newer than cloud
        NSLog(@"iCloud data found, but it's older than local data. Loading local data.");
        [self loadJournalFromLocalStorage];
        [[self sharedJournal] archive]; // save the newer, local data to iCloud
    } else
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self setSharedJournal:document.journal];
                [self postJournalChangeNotification];
            } else
                NSLog(@"Failed to load journal from iCloud.");
        }];
}

- (void)loadJournalWithCloudEnabled:(BOOL)isCloudEnabled {
    self.isCloudBackupEnabled = isCloudEnabled;
    
    if (isCloudEnabled)
        [self initCloudQuery];
    else
        [self loadJournalFromLocalStorage];
}

- (void)loadJournalFromLocalStorage {
    NSLog(@"Local path: %@", [self localURLWithFileName].path);
    
    self.sharedJournal = [NSKeyedUnarchiver unarchiveObjectWithFile:[self localURLWithFileName].path];
    
    if (!self.sharedJournal) {
        NSLog(@"No local data found, initializing new journal.");
        self.sharedJournal = [CMAJournal new];
    }
    
    [self postJournalChangeNotification];
}

#pragma mark - Notifications

- (void)postJournalChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGE_JOURNAL object:nil];
}

@end
