 //
//  CMAImage.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "CMABait.h"
#import "CMAConstants.h"
#import "CMAEntry.h"
#import "CMAImage.h"
#import "CMAJSONWriter.h"
#import "CMAUtilities.h"

@implementation CMAImage

@dynamic imagePath;
@dynamic entry;
@dynamic bait;

@synthesize fullImage = _fullImage;
@synthesize image = _image;
@synthesize tableCellImage = _tableCellImage;
@synthesize galleryCellImage = _galleryCellImage;

#pragma mark - Model Updating

- (void)handleModelUpdate {

}

#pragma mark - Initializers

// Done in a background thread upon startup.
- (void)initProperties {
    [self initThumbnails];
}

- (void)initThumbnails {
    [self initThumbnailsWithImage:self.fullImage];
}

- (void)initThumbnailsWithImage:(UIImage *)image {
    _tableCellImage = [CMAUtilities imageWithImage:image scaledToSize:CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE)];
    _galleryCellImage = [CMAUtilities imageWithImage:self.tableCellImage scaledToSize:[CMAUtilities galleryCellSize]];
}

#pragma mark - Saving

// NOTE: Deleting images is done in [[CMAStorageManager sharedManager] cleanImages].

- (void)saveWithImage:(UIImage *)image
             fileName:(NSString *)fileName
           completion:(void (^)(BOOL))completion
{
    NSString *subDirectory = @"Images";
    fileName = [fileName stringByAppendingString:JPG];
    
    NSString *documentsPath = [CMAStorageManager.sharedManager documentsSubDirectory:subDirectory].path;
    NSString *imagePath = [subDirectory stringByAppendingPathComponent:fileName];
    __block NSString *path = [documentsPath stringByAppendingPathComponent:fileName];
    __block UIImage *img = image;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL success = [UIImageJPEGRepresentation(img, 0.50f) writeToFile:path atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imagePath = imagePath;
            
            if (completion != nil) {
                completion(success);
            }
        });
    });
    
    // Generate thumbnail images right away so they're shown even before the image is saved to disk.
    [self initThumbnailsWithImage:image];
}

// This method should only be called when adding an image to the journal (ex. adding an entry or bait).
// This method MUST be called. It sets the CMAImage's imagePath property which is needed to access the image later.
// anIndex is the index of the image in an images array. It's added to create a unique file name.
- (void)saveWithIndex:(NSInteger)index completion:(void (^)(BOOL success))completion {
    UIImage *fullImage = self.fullImage;
    
    if (fullImage == nil) {
        NSLog(@"WARNING: Trying to save CMAImage with nil image value.");
    }
    
    if (self.entry == nil && self.bait == nil) {
        NSLog(@"WARNING: Trying to save CMAImage with nil entry/bait value.");
    }
    
    NSString *fileName;
    
    if (self.entry != nil) {
        fileName = [self.entry.accurateDateAsFileNameString stringByAppendingFormat:@"-%ld",
                (long)index];
    } else if (self.bait != nil) {
        NSString *dateString =
                [CMAUtilities stringForDate:[NSDate date] withFormat:ACCURATE_DATE_FILE_STRING];
        dateString = [dateString stringByAppendingFormat:@"-%ld", (long)index];
        fileName = [@"Bait_" stringByAppendingString:dateString];
    }
    
    [self saveWithImage:fullImage fileName:fileName completion:completion];
}

/**
 * Resaves the associated image file as a JPG if necessary. This greatly
 * reduces the size of the file. All future photos are saved as JPG.
 */
- (void)resaveAsJpgWithIndex:(NSInteger)index {
    if ([self.imagePath hasSuffix:JPG]) {
        return;
    }
    
    NSString *oldFilePath = [self.imagePath copy];
    NSLog(@"Converting file: %@", self.fileName);
    
    // save new file
    [self saveWithIndex:index completion:nil];
    
    // delete old file
    [CMAUtilities deleteFileAtPath:oldFilePath];
}

#pragma mark - Getters

- (NSString *)imagePath {
    return [[[CMAStorageManager sharedManager] documentsDirectory].path stringByAppendingPathComponent:[self primitiveValueForKey:@"imagePath"]];
}

// Path relative to /Documents/
- (NSString *)localImagePath {
    return [self primitiveValueForKey:@"imagePath"];
}

- (NSString *)fileName {
    return self.imagePath.lastPathComponent;
}

- (NSString *)fileNameWithoutExtension {
    return [self.fileName stringByDeletingPathExtension];
}

- (UIImage *)fullImage {
    if (_fullImage)
        return _fullImage;
    
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:self.imagePath]];
}

- (UIImage *)image {
    CGSize screenSize = [CMAUtilities screenSize];
    return [CMAUtilities imageWithImage:self.fullImage scaledToSize:CGSizeMake(screenSize.width, screenSize.width)];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitImage:self];
}

@end
