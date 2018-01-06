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

/**
 * Scales the receiver's fullImage dimensions so that its width is equal to the width of the screen.
 * If the scaled size's height is greater than the screen width, the screen width is returned,
 * otherwise the scale size's height is returned.
 *
 * This allows portrait photos to be shown as square, instead of taking up the entire screen, and
 * landscape photos to be shown in full.
 *
 * @return The height, in points, of the receiver's image to be displayed in the full width of the
 *         screen.
 */
- (CGFloat)heightForFullWidthDisplay;

/**
 * @return The receiver's full image scaled to the screen's width. Aspect ratio is kept, and it is
 *         possible this method will cut off the original image if the original image is portrait.
 */
- (UIImage *)imageForFullWidthDisplay;

/**
 * @return The receiver's full image scaled to a square image of the given size. This method will
 *         cut off the original image if the original image isn't already square.
 */
- (UIImage *)thumbnailWithSize:(CGFloat)size;

// visiting
- (void)accept:(id)aVisitor;

@end
