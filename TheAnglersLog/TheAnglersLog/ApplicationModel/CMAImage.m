//
//  CMAImage.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAImage.h"
#import "CMABait.h"
#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAUtilities.h"

@implementation CMAImage

@dynamic data;
@dynamic entry;
@dynamic bait;
@dynamic tableThumbnailData;
@dynamic galleryThumbnailData;

- (void)handleModelUpdate {
    if (!self.tableThumbnailData)
        [self setTableThumbnailDataForSize:CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE)];
    
    if (!self.galleryThumbnailData)
        [self setGalleryThumbnailDataForSize:[CMAUtilities galleryCellSize]];
}

- (UIImage *)dataAsUIImage {
    return [UIImage imageWithData:self.data];
}

- (UIImage *)dataAsUIImage:(NSData *)data {
    return [UIImage imageWithData:data];
}

- (void)setDataFromUIImage:(UIImage *)anImage {
    self.data = [self dataFromUIImage:anImage];
    [self setTableThumbnailDataForSize:CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE)];
    [self setGalleryThumbnailDataForSize:[CMAUtilities galleryCellSize]];
}

- (void)setTableThumbnailDataForSize:(CGSize)size {
    self.tableThumbnailData = [self dataFromUIImage:[CMAUtilities imageWithImage:[self dataAsUIImage] scaledToSize:size]];
}

- (void)setGalleryThumbnailDataForSize:(CGSize)size {
    self.galleryThumbnailData = [self dataFromUIImage:[CMAUtilities imageWithImage:[self dataAsUIImage] scaledToSize:size]];
}

- (NSData *)dataFromUIImage:(UIImage *)anImage {
    return UIImagePNGRepresentation(anImage);
}

@end
