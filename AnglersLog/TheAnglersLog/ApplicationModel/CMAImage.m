 //
//  CMAImage.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-01-27.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMAImage.h"
#import "CMABait.h"
#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAUtilities.h"
#import "CMAJSONWriter.h"

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
    __block NSString *imagePath = [self.imagePath copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
        [self initImageFromPath:imagePath];
        [self initTableCellImage];
        [self initGalleryCellImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

- (void)initImage {
    _image = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.imagePath]];
}

- (void)initImageFromPath:(NSString *)aPath {
    // DO NOT use UIImage's imageWithContentsOfFile. It keeps the file open so it can't be overridden (i.e. can't be edited).
    _image = [UIImage imageWithData:[NSData dataWithContentsOfFile:aPath]];
}

- (void)initTableCellImage {
    _tableCellImage = [CMAUtilities imageWithImage:self.image scaledToSize:CGSizeMake(TABLE_THUMB_SIZE, TABLE_THUMB_SIZE)];
}

- (void)initGalleryCellImage {
    _galleryCellImage = [CMAUtilities imageWithImage:self.tableCellImage scaledToSize:[CMAUtilities galleryCellSize]];
}

#pragma mark - Saving

// NOTE: Deleting images is done in [[CMAStorageManager sharedManager] cleanImages].

- (void)saveWithImage:(UIImage *)anImage andFileName:(NSString *)aFileName {
    NSString *subDirectory = @"Images";
    NSString *fileName = [aFileName stringByAppendingString:@".png"];
    
    NSString *documentsPath = [[CMAStorageManager sharedManager] documentsSubDirectory:subDirectory].path;
    NSString *imagePath = [subDirectory stringByAppendingPathComponent:fileName];
    NSString *path = [documentsPath stringByAppendingPathComponent:fileName];
    __block NSURL *saveURL = [NSURL fileURLWithPath:path];
    __block UIImage *img = anImage;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CGImageDestinationRef imgDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)saveURL, kUTTypePNG, 1, NULL);
        
        if (imgDestination == NULL) {
            NSLog(@"ERROR in saveWithImage:andFileName: -> failed to create image destination.");
            return;
        }
        
        CGImageDestinationAddImage(imgDestination, img.CGImage, NULL);
        
        if (CGImageDestinationFinalize(imgDestination) == NO) {
            NSLog(@"ERROR in saveWithImage:andFileName: -> failed to finailize image.");
            CFRelease(imgDestination);
            return;
        }
        
        CFRelease(imgDestination);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });

    self.image = anImage;
    self.tableCellImage = anImage;
    self.galleryCellImage = anImage;
    self.imagePath = imagePath; // stored path has to be relative, not absolute (iOS8 changes UUID every run)
}

// This method should only be called when adding an image to the journal (ex. adding an entry or bait).
// This method MUST be called. It sets the CMAImage's imagePath property which is needed to access the image later.
// anIndex is the index of the image in an images array. It's added to create a unique file name.
- (void)saveWithIndex:(NSInteger)anIndex {
    if (!self.image)
        NSLog(@"WARNING: Trying to save CMAImage with NULL image value.");
    
    if (!self.entry && !self.bait)
        NSLog(@"WARNING: Trying to save CMAImage with NILL entry/bait value.");
    
    NSString *fileName;
    
    if (self.entry)
        fileName = [[self.entry dateAsFileNameString] stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)anIndex]];
    else if (self.bait) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:[NSString stringWithFormat:@"ddmmyyyyHHmmssSSS_%ld", (long)anIndex]];
        fileName = [formatter stringFromDate:[NSDate date]];
    }
    
    [self saveWithImage:self.image andFileName:fileName];
}

#pragma mark - Getters

- (NSString *)imagePath {
    return [[[CMAStorageManager sharedManager] documentsDirectory].path stringByAppendingPathComponent:[self primitiveValueForKey:@"imagePath"]];
}

// Path relative to /Documents/
- (NSString *)localImagePath {
    return [self primitiveValueForKey:@"imagePath"];
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

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitImage:self];
}

@end
