//
//  CMAImagePicker.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <QBImagePickerController/QBImagePickerController.h>

#import "CMAAlerts.h"
#import "CMAImagePicker.h"

@interface CMAImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UIDocumentMenuDelegate, UIDocumentPickerDelegate, QBImagePickerControllerDelegate>

@property (weak, nonatomic) UIViewController<CMAImagePickerDelegate> *viewController;

@property (nonatomic) BOOL canSelectMultiple;

@end

@implementation CMAImagePicker

+ (CMAImagePicker *)withViewController:(UIViewController<CMAImagePickerDelegate> *)controller
                     canSelectMultiple:(BOOL)canSelectMultiple
{
    return [CMAImagePicker.alloc initWithViewController:controller
                                      canSelectMultiple:canSelectMultiple];
}

#pragma mark - Initializing

- (id)initWithViewController:(UIViewController<CMAImagePickerDelegate> *)controller
            canSelectMultiple:(BOOL)canSelectMultiple
{
    if (self = [super init]) {
        _canSelectMultiple = canSelectMultiple;
        _viewController = controller;
    }
    return self;
}

- (void)presentDocumentPicker {
    UIDocumentMenuViewController *menuController = [UIDocumentMenuViewController.alloc
            initWithDocumentTypes:@[(NSString *)kUTTypeImage] inMode:UIDocumentPickerModeImport];
    menuController.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    
    [menuController addOptionWithTitle:@"Device Photos"
                                 image:nil
                                 order:UIDocumentMenuOrderFirst
                               handler:^{
                                   [weakSelf presentImagePicker];
                               }];
    
    [menuController addOptionWithTitle:@"Camera"
                                 image:nil
                                 order:UIDocumentMenuOrderFirst
                               handler:^{
                                   [weakSelf presentCamera];
                               }];
    
    [self.viewController presentViewController:menuController animated:YES completion:nil];
}

- (void)presentImagePicker {
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = self.canSelectMultiple;
    imagePickerController.showsNumberOfSelectedAssets = self.canSelectMultiple;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    [self.viewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)presentCamera {
    // Do nothing if there is no camera. This will only happen in a simulator.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [CMAAlerts alertAlert:@"Camera unavailable."
   presentationViewController:self.viewController];
        return;
    }
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.viewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)present {
    [self presentDocumentPicker];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.viewController didTakePicture:info[UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIDocumentMenuDelegate

 - (void)documentMenu:(UIDocumentMenuViewController *)documentMenu
didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    if (@available(iOS 11, *)) {
        documentPicker.allowsMultipleSelection = self.canSelectMultiple;
    }
    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (UIImage *)urlToImage:(NSURL *)url {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url
{
    // For iOS 11+, documentPicker:didPickDocumentsAtURLs is called instead.
    if (@available(iOS 11, *)) {
        return;
    }
    [self.viewController didPickImages:@[[self urlToImage:url]]];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    NSMutableArray<UIImage *> *images = NSMutableArray.new;
    for (NSURL *url in urls) {
        [images addObject:[self urlToImage:url]];
    }
    [self.viewController didPickImages:images];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController
          didFinishPickingAssets:(NSArray *)assets
{
    PHImageRequestOptions *options = PHImageRequestOptions.new;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    __block NSMutableArray<UIImage *> *images = NSMutableArray.new;
    
    for (PHAsset *asset in assets) {
        [PHImageManager.defaultManager requestImageForAsset:asset
                                                 targetSize:PHImageManagerMaximumSize
                                                contentMode:PHImageContentModeDefault
                                                    options:options
                                              resultHandler:^(UIImage * _Nullable result,
                                                              NSDictionary * _Nullable info)
                                              {
                                                  [images addObject:result];
                                              }];
    }
    
    [self.viewController didPickImages:images];
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

@end
