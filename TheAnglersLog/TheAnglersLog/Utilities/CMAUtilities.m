//
//  CMAUtilities.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 2014-12-29.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUtilities.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

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
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
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
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

// Called when the "Done" button is tapped in the different "add scenes" throughout the app.
// For example, called in CMAAddEntryViewController.m's clickDoneButton event.
+ (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)())aCheckInputBlock
                   isEditingBlock:(BOOL(^)())anIsEditingBlock
                  editObjectBlock:(void(^)())anEditBlock
                   addObjectBlock:(BOOL(^)())anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)())aSegueBlock
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
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
            word = [item capitalizedString]; // capitalize that word.

        [newWords addObject:word];
    }
    
    return [newWords componentsJoinedByString:@" "];
}

#define kAdsRemovedKey @"TheAnglersLogAreAdsRemoved"

// Returns true if the app should display iAd banners.
// Returns false if the user has paid to remove ads.
+ (BOOL)shouldDisplayBanners {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kAdsRemovedKey];
}

+ (void)setShouldDisplayBanners:(BOOL)aBool {
    [[NSUserDefaults standardUserDefaults] setBool:!aBool forKey:kAdsRemovedKey];
}

@end
