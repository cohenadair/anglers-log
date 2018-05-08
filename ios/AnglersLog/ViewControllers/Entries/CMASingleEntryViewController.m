//
//  CMASingleEntryViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddEntryViewController.h"
#import "CMAAppDelegate.h"
#import "CMAConstants.h"
#import "CMAFishingMethod.h"
#import "CMAInstagramActivity.h"
#import "CMASingleBaitViewController.h"
#import "CMASingleEntryViewController.h"
#import "CMASingleLocationViewController.h"
#import "CMAStorageManager.h"
#import "CMAUtilities.h"
#import "CMAWeatherDataView.h"

// Used to store information on the cells that will be shonw on the table.
// See initTableSettings.
@interface CMATableCellProperties : NSObject

@property (strong, nonatomic)NSString *labelText;
@property (strong, nonatomic)NSString *detailText;
@property (strong, nonatomic)NSString *reuseIdentifier;
@property (nonatomic)CGFloat height;
@property (nonatomic)BOOL hasSeparator;

+ (CMATableCellProperties *)withLabelText:(NSString *)aLabelText
                            andDetailText:(NSString *)aDetailText
                       andReuseIdentifier:(NSString *)aReuseIdentifier
                                andHeight:(CGFloat)aHeight
                             hasSeparator:(BOOL)aBool;

- (id)initWithLabelText:(NSString *)aLabelText
          andDetailText:(NSString *)aDetailText
     andReuseIdentifier:(NSString *)aReuseIdentifier
              andHeight:(CGFloat)aHeight
           hasSeparator:(BOOL)aBool;

@end

@implementation CMATableCellProperties

+ (CMATableCellProperties *)withLabelText:(NSString *)aLabelText
                            andDetailText:(NSString *)aDetailText
                       andReuseIdentifier:(NSString *)aReuseIdentifier
                                andHeight:(CGFloat)aHeight
                             hasSeparator:(BOOL)aBool {
    
    return [[self alloc] initWithLabelText:aLabelText
                             andDetailText:aDetailText
                        andReuseIdentifier:aReuseIdentifier
                                 andHeight:aHeight
                              hasSeparator:aBool];
}

- (id)initWithLabelText:(NSString *)aLabelText
          andDetailText:(NSString *)aDetailText
     andReuseIdentifier:(NSString *)aReuseIdentifier
              andHeight:(CGFloat)aHeight
           hasSeparator:(BOOL)aBool {
    
    if (self = [super init]) {
        _labelText = aLabelText;
        _detailText = aDetailText;
        _reuseIdentifier = aReuseIdentifier;
        _height = aHeight;
        _hasSeparator = aBool;
    }
    
    return self;
}

@end

#define kSubtitleCellHeight 55
#define kRightDetailCellHeight 35
#define kImageCollectionIndex 0
#define kWeatherCellTitlePadding 25

@interface CMASingleEntryViewController ()

@property (strong, nonatomic)UICollectionView *imageCollectionView;

@property (strong, nonatomic)UIBarButtonItem *actionButton;
@property (strong, nonatomic)UIBarButtonItem *editButton;

@property (strong, nonatomic)NSOrderedSet<CMAImage *> *entryImageArray;
@property (strong, nonatomic)NSIndexPath *currentImageIndex;

@property (strong, nonatomic)NSMutableArray<CMATableCellProperties *> *tableCellProperties;

@end

@implementation CMASingleEntryViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBarItems];
    [self initTableSettings];
    [self setEntryImageArray:[self.entry images]];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
    
    [self.navigationController setToolbarHidden:YES];
    
    self.currentImageIndex = [NSIndexPath indexPathForItem:0 inSection:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.imageCollectionView reloadData];
}

#pragma mark - Table View Initializing

// Creates a CMATableCellProperties object for each cell that will be shown on the table.
// Only self.entry properties that were specified by the user are shown.
// Sets self.tableCellProperties property.
- (void)initTableSettings {
    CMAMeasuringSystemType measureType = [[self journal] measurementSystem];
    self.tableCellProperties = [NSMutableArray array];
    
    // images
    [self.tableCellProperties addObject:
     [CMATableCellProperties withLabelText: nil
                             andDetailText: nil
                        andReuseIdentifier: @"collectionViewCell"
                                 andHeight: 0
                              hasSeparator: NO]];
    
    // species and date
    [self.tableCellProperties addObject:
     [CMATableCellProperties withLabelText: self.entry.fishSpecies.name
                             andDetailText: [self.entry dateAsString]
                        andReuseIdentifier: @"subtitleCell"
                                 andHeight: kSubtitleCellHeight
                              hasSeparator: YES]];
    
    // location
    if (self.entry.location) {
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Location"
                                 andDetailText: [self.entry locationAsString]
                            andReuseIdentifier: @"locationCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: YES]];
    }
    
    // bait used
    if (self.entry.baitUsed)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Bait Used"
                                 andDetailText: self.entry.baitUsed.name
                            andReuseIdentifier: @"baitUsedCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: YES]];
    
    // weather conditions
    if (self.entry.weatherData)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: nil
                                 andDetailText: nil
                            andReuseIdentifier: @"weatherDataCell"
                                     andHeight: TABLE_HEIGHT_WEATHER_CELL + kWeatherCellTitlePadding
                                  hasSeparator: YES]];
    
    // length
    if (self.entry.fishLength && [self.entry.fishLength floatValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Length"
                                 andDetailText: [self.entry lengthAsStringWithMeasurementSystem:measureType shorthand:YES]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // weight
    if ((self.entry.fishWeight && [self.entry.fishWeight floatValue] > 0) ||
        (self.entry.fishOunces && [self.entry.fishOunces integerValue] > 0))
    {
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Weight"
                                 andDetailText: [self.entry weightAsStringWithMeasurementSystem:measureType shorthand:YES]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    }
    
    // quantity
    if (self.entry.fishQuantity && [self.entry.fishQuantity integerValue] >= 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Quantity"
                                 andDetailText: [self.entry.fishQuantity stringValue]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    [self.tableCellProperties addObject:
     [CMATableCellProperties withLabelText:@"Result"
                             andDetailText:[self.entry fishResultAsString]
                        andReuseIdentifier:@"rightDetailCell"
                                 andHeight:kRightDetailCellHeight
                              hasSeparator:NO]];
    
    // fishing methods
    if ([self.entry.fishingMethods count] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Methods"
                                 andDetailText: [self.entry fishingMethodsAsString]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: YES]];
    
    // water clarity
    if (self.entry.waterClarity)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Clarity"
                                 andDetailText: [self.entry.waterClarity name]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // water depth
    if (self.entry.waterDepth && [self.entry.waterDepth floatValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Depth"
                                 andDetailText: [NSString stringWithFormat:@"%.2f%@", [self.entry.waterDepth floatValue], [[self journal] depthUnitsAsString:YES]]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // water temperature
    if (self.entry.waterTemperature && [self.entry.waterTemperature integerValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Temperature"
                                 andDetailText: [NSString stringWithFormat:@"%ld%@", (long)[self.entry.waterTemperature integerValue], [[self journal] temperatureUnitsAsString:YES]]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: YES]];
    
    // notes
    if (self.entry.notes)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Notes"
                                 andDetailText: self.entry.notes
                            andReuseIdentifier: @"subtitleCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: NO]];
}

- (CGFloat)heightForImageCollection {
    if (self.entry.imageCount > 0) {
        // It's possible for the currentImageIndex to exceed the image count if an image was
        // deleted. Reset it if needed.
        if (self.currentImageIndex.row > self.entry.imageCount - 1) {
            self.currentImageIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        return [self heightForImageAtIndexPath:self.currentImageIndex];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMATableCellProperties *properties = [self.tableCellProperties objectAtIndex:indexPath.row];
    
    if (indexPath.item == kImageCollectionIndex) {
        return self.heightForImageCollection;
    }
    
    // Notes cell; need to get the occupied space from the notes string
    if ([properties.labelText isEqualToString:@"Notes"]) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:GLOBAL_FONT size:15]};
        CGRect rect = [self.entry.notes boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:attributes
                                                     context:nil];
        return rect.size.height + 40; // + 40 for the "Notes" title
    }
    
    return self.tableCellProperties[indexPath.item].height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableCellProperties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMATableCellProperties *p = [self.tableCellProperties objectAtIndex:indexPath.item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:p.reuseIdentifier];
    
    // images collection view
    if (indexPath.item == kImageCollectionIndex) {
        if (self.imageCollectionView == nil) {
            self.imageCollectionView = (UICollectionView *)[cell viewWithTag:100];
        }
        return cell;
    }
    
    // weather data cell
    if ([p.reuseIdentifier isEqualToString:@"weatherDataCell"]) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CMAWeatherDataView" owner:self options:nil];
        if ([nib count] > 0) {
            CMAWeatherDataView *view = (CMAWeatherDataView *)[nib objectAtIndex:0];
            view.frame = CGRectMake(0, kWeatherCellTitlePadding, self.tableView.frame.size.width,
                    TABLE_HEIGHT_WEATHER_CELL - kWeatherCellTitlePadding);
            
            [view.temperatureLabel setText:[self.entry.weatherData temperatureAsStringWithUnits:[[self journal] temperatureUnitsAsString:YES]]];
            [view.windSpeedLabel setText:[self.entry.weatherData windSpeedAsStringWithUnits:[[self journal] speedUnitsAsString:YES]]];
            [view.skyConditionsLabel setText:[self.entry.weatherData skyConditionsAsString]];
            
            [cell addSubview:view];
        }
    } else {
        cell.textLabel.text = p.labelText;
        cell.detailTextLabel.text = p.detailText;
    }
    
    // add separator to required cells
    if ((p.hasSeparator && !(indexPath.item == [self.tableCellProperties count] - 1)) || // if property has a separator AND the index path isn't the last
        
        // OR the indexPath isn't the last AND the next property contains "Water" OR "Notes"
        (!(indexPath.item == [self.tableCellProperties count] - 1) &&
        (([[[self.tableCellProperties objectAtIndex:indexPath.row + 1] labelText] containsString:@"Water"] && ![[[self.tableCellProperties objectAtIndex:indexPath.row] labelText] containsString:@"Water"]) ||
        [[[self.tableCellProperties objectAtIndex:indexPath.row + 1] labelText] isEqualToString:@"Notes"])))
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, p.height - 0.5, self.view.frame.size.width - 15, 0.5)];
        [line setBackgroundColor:[UIColor colorWithWhite:0.80 alpha:1.0]];
        [cell addSubview:line];
    } else {
        if (!(indexPath.item == [self.tableCellProperties count] - 1)) {
            // needed for proper rendering after an unwind from Add Entry Scene
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, p.height - 0.5, self.view.frame.size.width - 15, 0.5)];
            [line setBackgroundColor:[UIColor whiteColor]];
            [cell addSubview:line];
        }
    }
    
    return cell;
}

#pragma mark - Images Views

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.entry imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCollectionCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = self.entryImageArray[indexPath.item].imageForFullWidthDisplay;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, [self heightForImageAtIndexPath:indexPath]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.imageCollectionView) {
        // Reset the collection view's cell after the image has been fully shown. If done in
        // collectionView:willShowItem:forRowAtIndexPath, the animation starts too early and
        // the photos will be cut off if the user cancels the scroll gestrure.
        self.currentImageIndex = self.imageCollectionView.indexPathsForVisibleItems[0];
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
    }
}

- (CGFloat)heightForImageAtIndexPath:(NSIndexPath *)indexPath {
    return [self.entryImageArray objectAtIndex:indexPath.item].heightForFullWidthDisplay;
}

#pragma mark - Events

- (void)clickActionButton {
    [self shareEntry];
}

- (void)clickEditButton {
    [self performSegueWithIdentifier:@"fromSingleEntryToAddEntry" sender:self];
}

#pragma mark - Sharing

// Should share:
//      Image
//      Text: "Steelhead Length: 32" Weight: 3 lbs. 9 oz. #AnglersLogApp."
- (void)shareEntry {
    NSMutableArray *shareItems = [NSMutableArray array];
    
    NSArray *images = [self.imageCollectionView visibleCells];
    UIImage *currentImage = NULL;
    
    if (images.count > 0)
        currentImage = [(UIImageView *)[[images objectAtIndex:0] viewWithTag:100] image];
    
    if (currentImage)
        [shareItems addObject:currentImage];
    
    [shareItems addObject:[self.entry shareString]]; // shareString is never nil
    
    CMAInstagramActivity *instagramActivity = [CMAInstagramActivity new];
    [instagramActivity setPresentView:self.view];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:@[instagramActivity]];
    activityController.popoverPresentationController.sourceView = self.view;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeAddToReadingList];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)initNavigationBarItems {
    self.actionButton =
        [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                    target:self
                                                    action:@selector(clickActionButton)];
    self.editButton =
        [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                    target:self
                                                    action:@selector(clickEditButton)];
    
    self.navigationItem.rightBarButtonItems = @[self.editButton, self.actionButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleEntryToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleEntry;
        destination.entry = self.entry;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleEntryToSingleLocation"]) {
        CMASingleLocationViewController *destination = segue.destinationViewController;
        destination.previousViewID = CMAViewControllerIDSingleEntry;
        destination.location = self.entry.location;
        destination.fishingSpotFromSingleEntry = self.entry.fishingSpot;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleEntryToSingleBait"]) {
        CMASingleBaitViewController *destination = segue.destinationViewController;
        destination.bait = self.entry.baitUsed;
        destination.isReadOnly = YES;
    }
}

- (IBAction)unwindToSingleEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToSingleEntryFromAddEntry"]) {
        CMAAddEntryViewController *source = segue.sourceViewController;
        [self setEntry:source.entry];
        [self setEntryImageArray:[self.entry images]];
        
        [self initTableSettings];
        
        source.entry = nil;
    }
}

@end
