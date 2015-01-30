//
//  CMASinglePhotoViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMASinglePhotoViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic)NSArray *imagesArray;
@property (strong, nonatomic)NSIndexPath *startingImageIndexPath;

@end
