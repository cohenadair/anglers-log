//
//  CMASingleEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleEntryViewController.h"
#import "CMAConstants.h"

@interface CMASingleEntryViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

@end

@implementation CMASingleEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.entry = [CMAEntry new];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        if ([self.entry imageCount] == 0)
            return 0;
        else
            return tableView.frame.size.width;
    }
    
    // using the super class's implementation gets the height set in storyboard
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.entry imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCollectionCell" forIndexPath:indexPath];
    
    [[cell.contentView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[cell.contentView layer] setBorderWidth:1.0f];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize;
    cellSize.width = collectionView.frame.size.width;
    cellSize.height = collectionView.frame.size.height;
    
    return cellSize;
}
@end
