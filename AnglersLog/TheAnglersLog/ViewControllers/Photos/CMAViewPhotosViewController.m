//
//  CMAPhotosViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMAViewPhotosViewController.h"
#import "SWRevealViewController.h"
#import "CMAAppDelegate.h"
#import "CMASinglePhotoViewController.h"
#import "CMANoXView.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"

@interface CMAViewPhotosViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) NSMutableArray *thumbnails;
@property (strong, nonatomic) NSMutableArray *fullImages;
@property (strong, nonatomic) CMANoXView *noImagesView;

@property (nonatomic)CGFloat currentOffsetY;

@end

@implementation CMAViewPhotosViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - Side Bar Navigation

- (void)initSideBarMenu {
    [self.menuButton setTarget:self.revealViewController];
    [self.menuButton setAction:@selector(revealToggle:)];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

#pragma mark - View Management

- (void)initNoImagesView {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil];
    if (nib.count <= 0)
        return;
    
    self.noImagesView = (CMANoXView *)[nib objectAtIndex:0];
    
    self.noImagesView.imageView.image = [UIImage imageNamed:@"photos_large.png"];
    self.noImagesView.titleView.text = @"Entries with photos.";
    self.noImagesView.subtitleView.text = @"Add a photo to a new or existing Entry to begin.";
    
    CGRect f = self.view.frame;
    [self.noImagesView centerInParent:self.view];
    [self.noImagesView setFrame:CGRectMake(f.origin.x, -10, f.size.width, f.size.height)];
    [self.view addSubview:self.noImagesView];
}

- (void)handleNoImagesView {
    if ([self.thumbnails count] <= 0)
        [self initNoImagesView];
    else if (self.noImagesView != nil) {
        [self.noImagesView removeFromSuperview];
        self.noImagesView = nil;
    }
}

- (void)setupView {
    [self.collectionView setContentOffset:CGPointMake(0, self.currentOffsetY)];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Photos (%lu)", (unsigned long)[self.thumbnails count]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initThumbnails];
    [self initSideBarMenu];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Colletion View Initializing

// Loops through the journal entries creating an array of UIImages.
- (void)initThumbnails {
    __weak typeof(self) weakSelf = self;
    
    self.thumbnails = [NSMutableArray array];
    self.fullImages = [NSMutableArray array];
    NSMutableOrderedSet *entries = [[self journal] entries];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (CMAEntry *entry in entries)
            for (CMAImage *img in entry.images) {
                [[weakSelf thumbnails] addObject:img.galleryCellImage];
                [[weakSelf fullImages] addObject:img];
            }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf handleNoImagesView];
            [self.navigationItem setTitle:[NSString stringWithFormat:@"Photos (%lu)", (unsigned long)[self.thumbnails count]]];
        });
    });
}

- (CGSize)cellSize {
    return [CMAUtilities galleryCellSize];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.thumbnails count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView setImage:[self.thumbnails objectAtIndex:indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"fromPhotosToSinglePhoto" sender:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return GALLERY_CELL_SPACING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return GALLERY_CELL_SPACING;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromPhotosToSinglePhoto"]) {
        CMASinglePhotoViewController *destination = segue.destinationViewController;
        destination.imagesArray = self.fullImages;
        destination.startingImageIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    }
    
    self.currentOffsetY = self.collectionView.contentOffset.y;
}

@end
