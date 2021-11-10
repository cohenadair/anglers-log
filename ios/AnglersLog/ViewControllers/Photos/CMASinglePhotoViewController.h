//
//  CMASinglePhotoViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 11/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface CMASinglePhotoViewController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic)NSArray *imagesArray;
@property (strong, nonatomic)NSIndexPath *startingImageIndexPath;

@end
