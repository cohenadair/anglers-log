//
//  CMAAdBanner.m
//  AnglersLog
//
//  Created by Cohen Adair on 2015-03-19.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAAdBanner.h"
#import "CMAUtilities.h"

@implementation CMAAdBanner

#pragma mark - Initializing

+ (CMAAdBanner *)withFrame:(CGRect)aFrame delegate:(id<ADBannerViewDelegate>)aDelegate superView:(UIView *)aSuperview {
    return [[self alloc] initWithFrame:aFrame delegate:aDelegate superView:aSuperview];
}

- (id)initWithFrame:(CGRect)aFrame delegate:(id<ADBannerViewDelegate>)aDelegate superView:(UIView *)aSuperview {
    if (self = [super init]) {
        if (![CMAAdBanner shouldDisplayBanners]) {
            NSLog(@"User has paid to remove ads.");
            self.isNil = YES;
            return self;
        }
        
        self.adBanner = [[ADBannerView alloc] initWithFrame:aFrame];
        self.adBanner.delegate = aDelegate;
        self.showTime = 0.5;
        self.hideTime = 0.5;
        self.mySuperview = aSuperview;
        
        [aSuperview addSubview:self.adBanner];
    }
    
    return self;
}

#pragma mark - Showing/Hiding

- (void)showWithCompletion:(void (^)())completionBlock {
    if (self.isNil || self.bannerIsVisible)
        return;
    
    if (self.constraint) {
        if (self.bannerIsOnBottom)
            self.constraint.constant -= self.adBanner.frame.size.height;
        else
            self.constraint.constant += self.adBanner.frame.size.height;
    }
    
    [UIView animateWithDuration:self.showTime animations:^{
        if (self.noXView) {
            CGRect f = self.noXView.frame;
            CGFloat h = self.adBanner.frame.size.height;
            self.noXView.frame = CGRectMake(f.origin.x, f.origin.y + (!self.bannerIsOnBottom * h), f.size.width, f.size.height - h);
        }
        
        if (self.bannerIsOnBottom)
            self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -self.adBanner.frame.size.height);
        else
            self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, self.adBanner.frame.size.height);
        
        [self.mySuperview layoutIfNeeded]; // so constraint changes are animated
    }];
    
    self.bannerIsVisible = YES;
    
    if (completionBlock)
        completionBlock();
}

- (void)hideWithCompletion:(void (^)())completionBlock {
    if (self.isNil || !self.bannerIsVisible)
        return;
    
    if (self.constraint) {
        if (self.bannerIsOnBottom)
            self.constraint.constant += self.adBanner.frame.size.height;
        else
            self.constraint.constant -= self.adBanner.frame.size.height;
    }
    
    [UIView animateWithDuration:self.hideTime animations:^{
        if (self.noXView) {
            CGRect f = self.noXView.frame;
            CGFloat h = self.adBanner.frame.size.height;
            self.noXView.frame = CGRectMake(f.origin.x, f.origin.y - (!self.bannerIsOnBottom * h), f.size.width, f.size.height + h);
        }
        
        if (self.bannerIsOnBottom)
            self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, self.adBanner.frame.size.height);
        else
            self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -self.adBanner.frame.size.height);
        
        [self.mySuperview layoutIfNeeded]; // so constraint changes are animated
    }];
    
    self.bannerIsVisible = NO;
    
    if (completionBlock)
        completionBlock();
}

#define kAdsRemovedKey @"AnglersLogAreAdsRemoved"

// Returns true if the app should display iAd banners.
// Returns false if the user has paid to remove ads.
+ (BOOL)shouldDisplayBanners {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kAdsRemovedKey];
}

+ (void)setShouldDisplayBanners:(BOOL)aBool {
    [[NSUserDefaults standardUserDefaults] setBool:!aBool forKey:kAdsRemovedKey];
}

@end
