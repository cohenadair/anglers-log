//
//  CMAUtilities.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAStorageManager.h"
#import "CMAAlerts.h"

@interface CMAUtilities : NSObject

+ (BOOL)validConnection;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;

/**
 * Scales the given UIImage to the screen's width when in portrait orientation
 * (i.e. the shortest side).
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
