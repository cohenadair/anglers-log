//
//  CMASinglePhotoViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASinglePhotoViewController.h"
#import "CMAConstants.h"

@interface CMASinglePhotoViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@end

@implementation CMASinglePhotoViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView scrollToItemAtIndexPath:self.startingImageIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Initializing

- (CGSize)cellSize {
    CGSize result;
    
    result.width = self.collectionView.frame.size.width;
    result.height = self.collectionView.frame.size.width;
    
    return result;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView setImage:[self.imagesArray objectAtIndex:indexPath.item]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellSize];
}

#pragma mark - Events

- (IBAction)clickActionButton:(UIBarButtonItem *)sender {
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];
    UIImage *selectedImage = [self.imagesArray objectAtIndex:selectedIndexPath.item];
    [self shareImage:selectedImage];
}

#pragma mark - Sharing

- (void)shareImage:(UIImage *)anImage {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[anImage, SHARE_MESSAGE] applicationActivities:nil];
    activityController.popoverPresentationController.sourceView = self.view;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeAddToReadingList];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
