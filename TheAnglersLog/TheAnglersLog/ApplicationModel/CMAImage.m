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

@dynamic imagePath;
@dynamic entry;
@dynamic bait;

@synthesize image = _image;
@synthesize tableCellImage = _tableCellImage;
@synthesize galleryCellImage = _galleryCellImage;

#pragma mark - Model Updating

- (void)handleModelUpdate {

}

#pragma mark - Initializers

// Done in a background thread upon startup.
- (void)initProperties {
    [self initUIImages];
}

- (void)initUIImages {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self initImage];
        [self initTableCellImage];
        [self initGalleryCellImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Initialized image in %f ms.", CFAbsoluteTimeGetCurrent() - start);
        });
    });
}

- (void)initImage {
    _image = [UIImage imageWithContentsOfFile:self.imagePath];
}

- (void)initTableCellImage {
    _tableCellImage = [CMAUtilities imageWithImage:self.image scaledToSize:CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE)];
}

- (void)initGalleryCellImage {
    _galleryCellImage = [CMAUtilities imageWithImage:self.tableCellImage scaledToSize:[CMAUtilities galleryCellSize]];
}

#pragma mark - Saving

// NOTE: Deleting images is done in [[CMAStorageManager sharedManager] deleteManagedObject].

- (void)saveWithImage:(UIImage *)anImage andFileName:(NSString *)aFileName {
    NSString *subDirectory = @"Images";
    NSString *fileName = [aFileName stringByAppendingString:@".png"];
    
    NSString *documentsPath = [[CMAStorageManager sharedManager] documentsSubDirectory:subDirectory].path;
    NSString *path = [documentsPath stringByAppendingPathComponent:fileName];
    NSString *imagePath = [subDirectory stringByAppendingPathComponent:fileName];
    
    NSData *data = UIImagePNGRepresentation(anImage);
    
    if ([data writeToFile:path atomically:YES])
        self.imagePath = imagePath; // stored path has to be relative, not absolute (iOS8 changes UUID every run)
    else
        NSLog(@"Error saving image to path: %@", path);
}

// This method should only be called when adding an image to the journal (ex. adding an entry or bait).
// This method MUST be called. It sets the CMAImage's imagePath property which is needed to access the image later.
- (void)save {
    if (!self.image)
        NSLog(@"WARNING: Trying to save CMAImage with NULL image value.");
    
    if (!self.entry)
        NSLog(@"WARNING: Trying to save CMAImage with NILL entry value.");
    
    [self saveWithImage:self.image andFileName:[self.entry dateAsFileNameString]];
}

#pragma mark - Getters

- (NSString *)imagePath {
    return [[[CMAStorageManager sharedManager] documentsDirectory].path stringByAppendingPathComponent:[self primitiveValueForKey:@"imagePath"]];
}

- (UIImage *)image {
    if (_image)
        return _image;
    
    [self initImage];
    return _image;
}

- (UIImage *)tableCellImage {
    if (_tableCellImage)
        return _tableCellImage;
    
    [self initTableCellImage];
    return _tableCellImage;
}

- (UIImage *)galleryCellImage {
    if (_galleryCellImage)
        return _galleryCellImage;
    
    [self initGalleryCellImage];
    return _galleryCellImage;
}

@end
