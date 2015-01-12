//
//  CMAStorageManager.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAJournalDocument.h"

@interface CMAStorageManager : NSObject

@property (nonatomic) __block BOOL _fileDidDownload;

@property (strong, nonatomic)CMAJournal *sharedJournal;
@property (strong, nonatomic)NSMetadataQuery *cloudQuery;
@property (nonatomic)BOOL isCloudBackupEnabled;

+ (id)sharedManager;
- (void)saveJournal:(CMAJournal *)aJournal withFileName:(NSString *)aFileName;
- (void)loadJournalWithCloudEnabled:(BOOL)isCloudEnabled;
- (void)postJournalChangeNotification;

@end
