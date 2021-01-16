//
//  CMAUtilities.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAStorageManager.h"

@interface CMAUtilities : NSObject

+ (BOOL)validConnection;

/**
 * Scales the given old size to the new width, keeping aspect ratio.
 */
+ (CGSize)scaleSize:(CGSize)oldSize toWidth:(CGFloat)newWidth;

/**
 * Scales the given image to an image of the given new size, keeping aspect ratio. This method
 * may cut off part of the original image.
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

/**
 * Scales the given image to a square image of the given new size, keeping aspect ratio. This method
 * will cut off part of the original image if the original image isn't already square.
 */
+ (UIImage *)scaleImage:(UIImage *)image toSquareSize:(CGFloat)size;

/**
 * Scales the given image to the new width, keeping aspect ratio. This method will not cut off any
 * of the original image.
 */
+ (UIImage *)scaleImage:(UIImage *)image toWidth:(CGFloat)newWidth;

/**
 * Scales the given image to the screen's width. This method will not cut off any of the original
 * image.
 */
+ (UIImage *)scaleImageToScreenWidth:(UIImage *)image;

+ (CGSize)galleryCellSize;
+ (NSString *)capitalizedString:(NSString *)aString;
+ (void)deleteFileAtPath:(NSString *)aPath;
+ (CGSize)screenSize;
+ (CGSize)screenSizeInPixels;
+ (UIColor *)themeColorDark;
+ (void)runInBackground:(void(^)(void))aBlock;
+ (void)run:(void (^)(void))block after:(NSTimeInterval)seconds;
+ (NSString *)stringForDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)displayStringForDate:(NSDate *)date;
+ (UIImage *)placeholderImage;

/**
 * @return YES if the given NSString is nil or empty; NO otherwise.
 */
+ (BOOL)isEmpty:(NSString *)string;

@end
