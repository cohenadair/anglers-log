//
//  CMAInstagramActivity.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2015-01-19.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAInstagramActivity.h"

@implementation CMAInstagramActivity

NSString *const kTempFileName = @"instagram.igo";

#pragma mark - Method Overrides

- (NSString *)activityType {
    return @"UIActivityTypeInstagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"instagram"];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

// Supported data types:
//   - UIImage
//   - NSString
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    // return NO if the user doesn't have Instagram installed
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL])
        return NO;
    
    for (UIActivityItemProvider *item in activityItems) {
        if (![self isActivityItemValid:item])
            return NO;
    }
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]])
            self.shareImage = item;
        else if ([item isKindOfClass:[NSString class]])
            // concat, with space if already exists.
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""), item];
    }
}

- (void)performActivity {
    if ([self saveTemporaryImage:self.shareImage]) {
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[self tempImagePath]]];
        self.documentController.delegate = self;
        self.documentController.UTI = @"com.instagram.exclusivegram";
        
        if (self.shareString)
            self.documentController.annotation = @{@"InstagramCaption" : self.shareString};
        
        if (![self.documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.presentView animated:YES])
            NSLog(@"CMAInstagramActivity: Failed to open document interaction controller.");
        
        return;
    }
    
    NSLog(@"Error saving UIImage in CMAInstagramActivity.");
    [self activityDidFinish:NO];
}

- (void)activityDidFinish:(BOOL)completed {
    if (completed) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:[self tempImagePath] error:&error])
            NSLog(@"CMAInstagramActivity: Error removing temporary image: %@", error.localizedDescription);
    }
    
    [super activityDidFinish:completed];
}

#pragma mark - Helper Methods

- (BOOL)isActivityItemValid:(UIActivityItemProvider *)activityItem {
    if ([activityItem isKindOfClass:[UIImage class]])
        return YES;
    
    if ([activityItem isKindOfClass:[NSString class]])
        return YES;

    return NO;
}

- (BOOL)saveTemporaryImage:(UIImage *)anImage {
    return [UIImagePNGRepresentation(anImage) writeToFile:[self tempImagePath] atomically:YES];
}

- (BOOL)deleteTemporaryImage:(NSError *)anError {
    return [[NSFileManager defaultManager] removeItemAtPath:[self tempImagePath] error:&anError];
}

- (NSString *)tempImagePath {
    return [NSTemporaryDirectory() stringByAppendingString:kTempFileName];
}

#pragma mark - Document Interaction Delegate

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self activityDidFinish:YES];
}

@end
