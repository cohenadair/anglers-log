//
//  CMAUtilities.h
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import "CMAStorageManager.h"
#import "CMAAlerts.h"

@interface CMAUtilities : NSObject

+ (BOOL)validConnection;
+ (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)())aCheckInputBlock
                   isEditingBlock:(BOOL(^)())anIsEditingBlock
                  editObjectBlock:(void(^)())anEditBlock
                   addObjectBlock:(BOOL(^)())anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)())aSegueBlock
                  removeObjToEdit:(BOOL)rmObjToEdit;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
+ (UIImage *)scaleImageToScreenSize:(UIImage *)anImage;
+ (CGSize)galleryCellSize;
+ (NSString *)capitalizedString:(NSString *)aString;
+ (void)deleteFileAtPath:(NSString *)aPath;
+ (CGSize)screenSize;
+ (CGSize)screenSizeInPixels;
+ (UIColor *)themeColorDark;

@end
