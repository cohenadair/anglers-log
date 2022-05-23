//
//  CMAImagePicker.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "CMAAlerts.h"
#import "CMAImagePicker.h"
#import "QBImagePickerController.h"

@interface CMAImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
        UIDocumentMenuDelegate, UIDocumentPickerDelegate, QBImagePickerControllerDelegate>

@property (weak, nonatomic) UIViewController<CMAImagePickerDelegate> *viewController;

@property (nonatomic) BOOL canSelectMultiple;

// Used for showing progress when photos need to be downloaded from cloud storage.
@property (strong, nonatomic) UIAlertController *downloadProgressController;
@property (nonatomic) BOOL isProgressAlertShowing;
@property (nonatomic) int downloadIndex;

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
        
        _isProgressAlertShowing = NO;
        _downloadIndex = 0;
        _downloadProgressController =
                [UIAlertController alertControllerWithTitle:nil
                                                    message:@"Downloading..."
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    return self;
}

- (void)presentDocumentPickerFrom:(UIView *)view {
    UIDocumentMenuViewController *menuController = [UIDocumentMenuViewController.alloc
            initWithDocumentTypes:@[(NSString *)kUTTypeImage] inMode:UIDocumentPickerModeImport];
    menuController.delegate = self;
    menuController.popoverPresentationController.sourceView = view;
    menuController.popoverPresentationController.sourceRect = view.bounds;
    
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
        [CMAAlerts showOk:@"Camera unavailable." inVc:self.viewController];
        return;
    }
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.viewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)presentFromView:(UIView *)view {
    [self presentDocumentPickerFrom:view];
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
    
    // In case photos need to be downloaded.
    options.networkAccessAllowed = YES;
    
    __block NSMutableArray<UIImage *> *images = NSMutableArray.new;
    __block BOOL errorGettingPhoto = NO;
    __block NSInteger index = 0;
    
    __weak typeof(QBImagePickerController) *weakImagePicker = imagePickerController;
    __weak typeof(self) weakSelf = self;
    
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop,
            NSDictionary * _Nullable info)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                errorGettingPhoto = YES;
            }
            
            [weakSelf showDownloadProgressAlert:imagePickerController];
        });
    };
    
    void (^processImageBlock)(UIImage *, NSDictionary *) = ^(UIImage * _Nullable result,
            NSDictionary * _Nullable info)
    {
        index++;
        
        if (result == nil) {
            errorGettingPhoto = YES;
        } else {
            [images addObject:result];
        }
        
        // Dismiss after the last image has been processed.
        if (index == assets.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.isProgressAlertShowing) {
                    [weakSelf.downloadProgressController dismissViewControllerAnimated:YES
                                                                            completion:
                    ^{
                        [weakSelf dismissImagePicker:weakImagePicker error:errorGettingPhoto];
                        weakSelf.isProgressAlertShowing = NO;
                    }];
                } else {
                    [weakSelf dismissImagePicker:weakImagePicker error:errorGettingPhoto];
                }
                
                [weakSelf.viewController didPickImages:images];
            });
        }
    };
    
    for (PHAsset *asset in assets) {
        [PHImageManager.defaultManager requestImageForAsset:asset
                                                 targetSize:PHImageManagerMaximumSize
                                                contentMode:PHImageContentModeDefault
                                                    options:options
                                              resultHandler:processImageBlock];
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDownloadProgressAlert:(QBImagePickerController *)imagePicker {
    if (self.isProgressAlertShowing) {
        return;
    }
    
    [imagePicker presentViewController:self.downloadProgressController
                              animated:YES
                            completion:nil];
    
    self.isProgressAlertShowing = YES;
}

- (void)dismissImagePicker:(QBImagePickerController *)picker error:(BOOL)error {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (error) {
            NSString *errorMsg = @"Error attaching photo(s). Please check your "
                    "network connection and try again. If the issue persists, "
                    "contact support@anglerslog.ca.";
            [CMAAlerts showError:errorMsg inVc:self.viewController];
        }
    }];
}

@end
