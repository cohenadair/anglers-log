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
    if (self.isCloudBackupEnabled)
        [self archiveJournal:aJournal toURL:[self cloudURL] withFileName:aFileName isLocal:NO];
    else
        [self archiveJournal:aJournal toURL:[self localURL] withFileName:aFileName isLocal:YES];
    
    [self setSharedJournal:aJournal];
}

- (void)archiveJournal:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName isLocal:(BOOL)isLocal {
    if (aURL) {
        if (isLocal)
            [self archiveJournalToLocalStorage:aJournal toURL:aURL withFileName:aFileName];
        else
            [self archiveJournalToCloud:aJournal toURL:aURL withFileName:aFileName];
    } else
        NSLog(@"%@ URL = NULL", isLocal ? @"Local" : @"iCloud");
}

- (void)archiveJournalToCloud:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName {
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

#pragma mark - Journal Loading

// Initializing this property allows the app to receive updates about the iCloud container.
// Required to receive iCloud updates.
// Reference: http://code.tutsplus.com/tutorials/working-with-icloud-document-storage--pre-37952
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

- (void)cloudQueryDidFinish:(NSNotification *)notification {
    NSLog(@"Cloud query finished.");
    
    NSMetadataQuery *cloudQuery = [notification object];
    [cloudQuery disableUpdates];
    [cloudQuery stopQuery];

    [cloudQuery.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *documentURL = [(NSMetadataItem *)obj valueForAttribute:NSMetadataItemURLKey];
        CMAJournalDocument *document = [[CMAJournalDocument alloc] initWithFileURL:documentURL];
        
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self setSharedJournal:document.journal];
                [self postJournalChangeNotification];
            } else
                NSLog(@"Failed to load journal from iCloud.");
        }];
    }];
    
    if (cloudQuery.resultCount <= 0) {
        NSLog(@"No journal data found in iCloud, initializing from local storage.");
        [self loadJournalFromLocalStorage];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cloudQueryDidUpdate:(NSNotification *)notification {
    NSLog(@"Cloud query update.");
}

- (void)loadJournalWithCloudEnabled:(BOOL)isCloudEnabled {
    self.isCloudBackupEnabled = isCloudEnabled;
    
    if (isCloudEnabled)
        [self initCloudQuery];
    else
        [self loadJournalFromLocalStorage];
}

- (void)loadJournalFromLocalStorage {
    NSLog(@"Local path: %@", [[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path);
    
    self.sharedJournal = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path];
    
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
