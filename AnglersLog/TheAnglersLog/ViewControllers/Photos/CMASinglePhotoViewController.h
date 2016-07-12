//
//  CMASinglePhotoViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface CMASinglePhotoViewController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, ADBannerViewDelegate>

@property (strong, nonatomic)NSArray *imagesArray;
@property (strong, nonatomic)NSIndexPath *startingImageIndexPath;

@end
