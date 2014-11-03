//
//  CMASingleEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleEntryViewController.h"
#import "CMAAddEntryViewController.h"
#import "CMAAppDelegate.h"
#import "CMAConstants.h"
#import "CMAFishingMethod.h"

@interface CMASingleEntryViewController ()

@property (weak, nonatomic)IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic)IBOutlet UILabel *fishSpeciesLabel;
@property (weak, nonatomic)IBOutlet UILabel *entryDateDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *quantityDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *lengthDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *weightDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *methodsDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *baitUsedDetailLabel;
@property (weak, nonatomic)IBOutlet UILabel *notesDetailLabel;

@property (strong, nonatomic)NSArray *entryImageArray;

@end

@implementation CMASingleEntryViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEntryImageArray:[[self.entry images] allObjects]];
    [self setLabels];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabels {
    NSString *temp = [NSString new];
    NSString *naString = @"N/A";
    
    // species
    [self.fishSpeciesLabel setText:[[self.entry fishSpecies] name]];
    
    // date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy 'at' h:mm a"];
    [self.entryDateDetailLabel setText:[dateFormatter stringFromDate:[self.entry date]]];
    
    // location and fishing spot
    NSString *locationString = [NSString stringWithFormat:@"%@: %@", self.entry.location.name, self.entry.fishingSpot.name];
    [self.locationDetailLabel setText:locationString];
    
    // quantity
    if (self.entry.fishQuantity)
        [self.quantityDetailLabel setText:[self.entry.fishQuantity stringValue]];
    
    // length
    if (self.entry.fishLength)
        temp = [NSString stringWithFormat:@"%@%@", self.entry.fishLength.stringValue, [[self journal] lengthUnitsAsString:YES]];
    else
        temp = naString;
    [self.lengthDetailLabel setText:temp];
    
    // weight
    if (self.entry.fishWeight)
        temp = [NSString stringWithFormat:@"%@%@", self.entry.fishWeight.stringValue, [[self journal] weightUnitsAsString:YES]];
    else
        temp = naString;
    [self.weightDetailLabel setText:temp];
    
    // fishing methods
    if (self.entry.fishingMethods)
        [self.methodsDetailLabel setText:[self.entry concatinateFishingMethods]];
    else
        [self.methodsDetailLabel setText:naString];
    
    // bait used
    if (self.entry.baitUsed)
        [self.baitUsedDetailLabel setText:self.entry.baitUsed.name];
    else
        [self.baitUsedDetailLabel setText:naString];
    
    // notes
    if (self.entry.notes)
        [self.notesDetailLabel setText:self.entry.notes];
    else
        [self.notesDetailLabel setText:naString];
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
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView setImage:[self.entryImageArray objectAtIndex:indexPath.item]];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize;
    cellSize.width = collectionView.frame.size.width;
    cellSize.height = collectionView.frame.size.height;
    
    return cellSize;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleEntryToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_SingleEntry;
        destination.entry = self.entry;
    }
}

- (IBAction)unwindToSingleEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToSingleEntryFromAddEntry"]) {
        CMAAddEntryViewController *source = segue.sourceViewController;
        [self setEntry:source.entry];
        [self setEntryImageArray:[[self.entry images] allObjects]];
        [self setLabels];
        [self.tableView reloadData];
        [self.imageCollectionView reloadData];
    }
}

@end
