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
+ (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)(void))aCheckInputBlock
                   isEditingBlock:(BOOL(^)(void))anIsEditingBlock
                  editObjectBlock:(void(^)(void))anEditBlock
                   addObjectBlock:(BOOL(^)(void))anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)(void))aSegueBlock
                  removeObjToEdit:(BOOL)rmObjToEdit;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
+ (UIImage *)scaleImageToScreenSize:(UIImage *)anImage;
+ (CGSize)galleryCellSize;
+ (NSString *)capitalizedString:(NSString *)aString;
+ (void)deleteFileAtPath:(NSString *)aPath;
+ (CGSize)screenSize;
+ (CGSize)screenSizeInPixels;
+ (UIColor *)themeColorDark;
+ (void)runInBackground:(void(^)(void))aBlock;
+ (NSString *)stringForDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)displayStringForDate:(NSDate *)date;
+ (UIImage *)placeholderImage;

@end
