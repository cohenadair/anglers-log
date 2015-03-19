//
//  CMASinglePhotoViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/16/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASinglePhotoViewController.h"
#import "CMASinglePhotoCollectionViewCell.h"
#import "CMAConstants.h"
#import "CMAInstagramActivity.h"
#import "CMAImage.h"
#import "CMAAdBanner.h"

@interface CMASinglePhotoViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottom;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@property (strong, nonatomic)CMAAdBanner *adBanner;
@property (nonatomic)CGSize cellSizeInPoints;

@end

@implementation CMASinglePhotoViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAdBanner];
    
    CGSize screenSize = [[UIApplication sharedApplication] delegate].window.frame.size;
    self.cellSizeInPoints = CGSizeMake(screenSize.width, screenSize.width);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded]; // needed for the scroll to work properly (not exactly sure why)
    [self.collectionView scrollToItemAtIndexPath:self.startingImageIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self setNavigationTitleForIndexPath:self.startingImageIndexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationTitleForIndexPath:(NSIndexPath *)anIndexPath {
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Photos (%ld of %lu)", (unsigned long)anIndexPath.item + 1, (unsigned long)[self.imagesArray count]]];
}

#pragma mark - Ad Banner Initializing

- (void)initAdBanner {
    // the height of the view excluding the navigation bar and status bar
    CGFloat y = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect f = CGRectMake(0, y, self.view.frame.size.width, 50);
    
    self.adBanner = [CMAAdBanner withFrame:f delegate:self superView:self.view];
    self.adBanner.bannerIsOnBottom = YES;
    self.adBanner.constraint = self.collectionViewBottom;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self.adBanner showWithCompletion:nil];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self.adBanner hideWithCompletion:nil];
}

#pragma mark - Collection View Initializing

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMASinglePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    [cell.imageView setImage:[self.imagesArray objectAtIndex:indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSizeInPoints;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.collectionView.contentOffset.x / self.collectionView.frame.size.width inSection:0];
    [self setNavigationTitleForIndexPath:indexPath];
}

#pragma mark - Events

- (IBAction)clickActionButton:(UIBarButtonItem *)sender {
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForVisibleItems] objectAtIndex:0];
    UIImage *selectedImage = [[self.imagesArray objectAtIndex:selectedIndexPath.item] image];
    [self shareImage:selectedImage];
}

#pragma mark - Sharing

- (void)shareImage:(UIImage *)anImage {
    CMAInstagramActivity *instagramActivity = [CMAInstagramActivity new];
    [instagramActivity setPresentView:self.view];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[anImage, SHARE_MESSAGE] applicationActivities:@[instagramActivity]];
    activityController.popoverPresentationController.sourceView = self.view;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeAddToReadingList];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
