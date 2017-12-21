//
//  CMAUtilities.m
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUtilities.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "UIImage+ResizeMagick.h"

@implementation CMAUtilities

/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+ (BOOL)validConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                CFRelease(reachability);
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                CFRelease(reachability);
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    CFRelease(reachability);
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                CFRelease(reachability);
                return YES;
            }
        }
        CFRelease(reachability);
    }
    
    return NO;
}

// Called when the "Done" button is tapped in the different "add scenes" throughout the app.
// For example, called in CMAAddEntryViewController.m's clickDoneButton event.
+ (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)(void))aCheckInputBlock
                   isEditingBlock:(BOOL(^)(void))anIsEditingBlock
                  editObjectBlock:(void(^)(void))anEditBlock
                   addObjectBlock:(BOOL(^)(void))anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)(void))aSegueBlock
                  removeObjToEdit:(BOOL)rmObjToEdit
{
    if (aCheckInputBlock()) {
        if (anIsEditingBlock()) {
            anEditBlock();
            [[CMAStorageManager sharedManager] deleteManagedObject:anObjToAdd saveContext:YES];
        } else {
            if (!anAddObjectBlock()) {
                [CMAAlerts errorAlert:anErrorMsg presentationViewController:aVC];
                [[CMAStorageManager sharedManager] deleteManagedObject:anObjToAdd saveContext:YES];
                return;
            }
            
            if (rmObjToEdit)
                [[CMAStorageManager sharedManager] deleteManagedObject:anObjToEdit saveContext:YES];
            
            anObjToEdit = nil;
        }
        
        [[[CMAStorageManager sharedManager] sharedJournal] archive];
        aSegueBlock();
    } else
        [[CMAStorageManager sharedManager] deleteManagedObject:anObjToAdd saveContext:YES];
}

// From http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
// Scales the given UIImage to the given size, keeping aspect ratio.
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    CGFloat scale = MAX(size.width / image.size.width, size.height / image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width) / 2.0f, (size.height - height) / 2.0f, width, height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)scaleImageToScreenSize:(UIImage *)anImage {
    NSString *widthStr = [NSString stringWithFormat:@"%f", [CMAUtilities screenSizeInPixels].width];
    NSString *heightStr = [NSString stringWithFormat:@"x%f", [CMAUtilities screenSizeInPixels].height];
    
    if (anImage.size.width < anImage.size.height)
        return [anImage resizedImageByMagick:widthStr];
    else
        return [anImage resizedImageByMagick:heightStr];
}

// Uses the current window size to return a CGSize for the photo gallery collection view cells.
+ (CGSize)galleryCellSize {
    CGSize result;
    int cellsPerRow = 4;
    
    result.width = ([[UIApplication sharedApplication] delegate].window.frame.size.width - ((cellsPerRow - 1) * GALLERY_CELL_SPACING)) / cellsPerRow;
    result.height = result.width;
    
    return result;
}

// Works for strings like "1st and 2nd" so the 's' and 'n' aren't capitalized.
+ (NSString *)capitalizedString:(NSString *)aString {
    NSArray *words = [aString componentsSeparatedByString:@" "];
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
    
    for (NSString *item in words) {
        NSString *word = item;
        
        if ([word isEqualToString:@""])
            continue;
        
        if ([num numberFromString:[item substringWithRange:NSMakeRange(0, 1)]] == nil)
            word = [item stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[item substringToIndex:1] capitalizedString]]; // capitalize that word.

        [newWords addObject:word];
    }
    
    return [newWords componentsJoinedByString:@" "];
}

// Deletes a file at the given path.
+ (void)deleteFileAtPath:(NSString *)aPath {
    NSError *e;
    if (![[NSFileManager defaultManager] removeItemAtPath:aPath error:&e])
        NSLog(@"Failed to delete file %@: %@", aPath, e.localizedDescription);
}

+ (CGSize)screenSizeInPixels {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    return CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
}

+ (CGSize)screenSize {
    return [[UIApplication sharedApplication] delegate].window.frame.size;
}

+ (UIColor *)themeColorDark {
    return [UIColor colorWithRed:212.0f/255.0f green:191.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
}

+ (void)runInBackground:(void(^)(void))aBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             0), ^{
        aBlock();
    });
}

+ (NSString *)stringForDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

@end
