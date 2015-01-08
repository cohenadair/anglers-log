//
//  CMAJournalDocument.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-06.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAJournalDocument.h"

@implementation CMAJournalDocument

#define kArchiveKey @"CMAJournalDocument"

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    // unarchive the journal object if it exists
    if ([contents length] > 0) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:contents];
        self.journal = [unarchiver decodeObjectForKey:kArchiveKey];
        [unarchiver finishDecoding];
    } else
        self.journal = [CMAJournal new];
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSMutableData *data = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.journal forKey:kArchiveKey];
    [archiver finishEncoding];
    
    return data;
}

@end
