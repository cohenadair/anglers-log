//
//  CMAUtilities.m
//  AnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <netinet/in.h>
#import <sys/socket.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "CMAConstants.h"
#import "CMAUtilities.h"
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

+ (UIImage *)scaleImageToScreenWidth:(UIImage *)image {
    CGFloat imageWidth =
            MIN(CMAUtilities.screenSizeInPixels.width, CMAUtilities.screenSizeInPixels.height);
    return [image resizedImageByMagick:[NSString stringWithFormat:@"%f", imageWidth]];
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

+ (void)run:(void (^)(void))block after:(NSTimeInterval)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
            dispatch_get_main_queue(), ^{
                block();
            });
}

+ (NSString *)stringForDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)displayStringForDate:(NSDate *)date {
    return [self stringForDate:date withFormat:DISPLAY_DATE_FORMAT];
}

+ (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"placeholder_circle"];
}

+ (BOOL)isEmpty:(NSString *)string {
    return string == nil || string.length == 0;
}

@end

