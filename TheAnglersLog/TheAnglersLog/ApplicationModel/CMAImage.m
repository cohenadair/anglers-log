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

@synthesize fullImage = _fullImage;
@synthesize tableThumbnailImage = _tableThumbnailImage;
@synthesize galleryThumbnailImage = _galleryThumbnailImage;

#pragma mark - Model Updating

- (void)handleModelUpdate {
    if (!self.tableThumbnailData)
        [self initTableThumbnailDataForSize];
    
    if (!self.galleryThumbnailData)
        [self initGalleryThumbnailDataForSize];
}

// Done in a background thread upon startup.
- (void)initProperties {
    [self initUIImages];
}

- (void)initUIImages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        _fullImage = [self dataAsUIImage];
        _tableThumbnailImage = [self dataAsUIImage:self.tableThumbnailData];
        _galleryThumbnailImage = [self dataAsUIImage:self.galleryThumbnailData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

#pragma mark - Coversion Methods

- (CGFloat)scale {
    return [UIScreen mainScreen].scale;
}

- (UIImage *)dataAsUIImage {
    return [UIImage imageWithData:self.data];
}

- (UIImage *)dataAsUIImage:(NSData *)data {
    return [UIImage imageWithData:data];
}

- (NSData *)dataFromUIImage:(UIImage *)anImage {
    return UIImagePNGRepresentation(anImage);
}

#pragma mark - Setters

- (void)setDataFromUIImage:(UIImage *)anImage {
    self.data = [self dataFromUIImage:anImage];
    
    [self initTableThumbnailDataForSize];
    [self initGalleryThumbnailDataForSize];
}

- (void)initTableThumbnailDataForSize {
    CGSize size = CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE);
    self.tableThumbnailData = [self dataFromUIImage:[CMAUtilities imageWithImage:[self dataAsUIImage] scaledToSize:size]];
}

- (void)initGalleryThumbnailDataForSize {
    CGSize sizeInPoints = [CMAUtilities galleryCellSize];
    CGSize size = CGSizeMake(sizeInPoints.width, sizeInPoints.height);
    self.galleryThumbnailData = [self dataFromUIImage:[CMAUtilities imageWithImage:[self dataAsUIImage] scaledToSize:size]];
}

#pragma mark - Getters

- (UIImage *)fullImage {
    if (_fullImage)
        return _fullImage;
    
    _fullImage = [self dataAsUIImage];
    return _fullImage;
}

- (UIImage *)tableThumbnailImage {
    if (_tableThumbnailImage)
        return _tableThumbnailImage;
    
    _tableThumbnailImage = [self dataAsUIImage:self.tableThumbnailData];
    return _tableThumbnailImage;
}

- (UIImage *)galleryThumbnailImage {
    if (_galleryThumbnailImage)
        return _galleryThumbnailImage;
    
    _galleryThumbnailImage = [self dataAsUIImage:self.galleryThumbnailData];
    return _galleryThumbnailImage;
}

@end
