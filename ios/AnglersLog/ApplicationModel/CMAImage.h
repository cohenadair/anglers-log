//
//  CMAImage.h
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMABait, CMAEntry;

@interface CMAImage : NSManagedObject

@property (strong, nonatomic)NSString *imagePath;
@property (strong, nonatomic)CMAEntry *entry;
@property (strong, nonatomic)CMABait *bait;

@property (strong, nonatomic)UIImage *fullImage;
@property (strong, nonatomic)UIImage *image;
@property (strong, nonatomic)UIImage *tableCellImage;
@property (strong, nonatomic)UIImage *galleryCellImage;

- (void)handleModelUpdate;
- (void)initProperties;

/**
 * Saves the receiver to disk in a background thread.
 * @param index The index of the receiver as it appears in an entity images list.
 * @param completion Called on the main thread when the save attempt is finished.
 * @param success YES if the save was successful; false otherwise.
 */
- (void)saveWithIndex:(NSInteger)index completion:(void (^)(BOOL success))completion;

- (void)resaveAsJpgWithIndex:(NSInteger)index;

// accessing
- (NSString *)localImagePath;
- (NSString *)fileNameWithoutExtension;

// visiting
- (void)accept:(id)aVisitor;

@end
