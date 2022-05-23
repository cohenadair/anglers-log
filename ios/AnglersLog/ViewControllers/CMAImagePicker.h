//
//  CMAImagePicker.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

@protocol CMAImagePickerDelegate

- (void)didTakePicture:(UIImage *)image;
- (void)didPickImages:(NSArray<UIImage *> *)images;

@end

@interface CMAImagePicker : NSObject

+ (CMAImagePicker *)withViewController:(UIViewController<CMAImagePickerDelegate> *)controller
                     canSelectMultiple:(BOOL)canSelectMultiple;

- (void)presentFromView:(UIView *)view;

@end
