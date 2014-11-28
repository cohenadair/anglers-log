//
//  CMAPhotosViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAViewPhotosViewController.h"
#import "SWRevealViewController.h"
#import "CMAAppDelegate.h"
#import "CMASinglePhotoViewController.h"
#import "CMANoXView.h"

@interface CMAViewPhotosViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) CMANoXView *noImagesView;

@end

@implementation CMAViewPhotosViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoImagesView {
    self.noImagesView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noImagesView.imageView.image = [UIImage imageNamed:@"photos_large.png"];
    self.noImagesView.titleView.text = @"Entries with photos.";
    self.noImagesView.subtitleView.text = @"Add a photo to a new or existing Entry to begin.";
    
    [self.noImagesView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.noImagesView];
}

- (void)handleNoImagesView {
    if ([self.imagesArray count] <= 0)
        [self initNoImagesView];
    else {
        [self.noImagesView removeFromSuperview];
        self.noImagesView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideBarMenu];
    [self initImagesArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    [self handleNoImagesView];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Colletion View Initializing

#define CELL_SPACING 2
#define CELLS_PER_ROW 4

// Loops through the journal entries creating an array of UIImages.
- (void)initImagesArray {
    self.imagesArray = [NSMutableArray array];
    NSMutableArray *entries = [[self journal] entries];
    
    for (CMAEntry *entry in entries)
        for (UIImage *img in entry.images)
            [self.imagesArray addObject:img];
}

- (CGSize)cellSize {
    CGSize result;
    
    result.width = (self.collectionView.frame.size.width - ((CELLS_PER_ROW - 1) * CELL_SPACING)) / CELLS_PER_ROW;
    result.height = result.width;
    
    return result;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView setImage:[self.imagesArray objectAtIndex:indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromPhotosToSinglePhoto" sender:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_SPACING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CELL_SPACING;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromPhotosToSinglePhoto"]) {
        CMASinglePhotoViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.imagesArray = self.imagesArray;
        destination.startingImageIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    }
}

@end
