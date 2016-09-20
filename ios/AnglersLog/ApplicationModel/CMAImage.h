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

- (void)saveWithIndex:(NSInteger)anIndex;
- (void)resaveAsJpgWithIndex:(NSInteger)index;

// accessing
- (NSString *)localImagePath;
- (NSString *)fileNameWithoutExtension;

// visiting
- (void)accept:(id)aVisitor;

@end
