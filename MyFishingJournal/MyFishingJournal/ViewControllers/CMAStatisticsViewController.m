//
//  CMAStatisticsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAStatisticsViewController.h"
#import "CMAUserDefinesViewController.h"
#import "CMAViewBaitsViewController.h"
#import "CMASingleEntryViewController.h"
#import "CMANoXView.h"
#import "CMAAppDelegate.h"
#import "CMAStats.h"
#import "SWRevealViewController.h"

@interface CMAStatisticsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIView *pieChartCenterView;
@property (weak, nonatomic) IBOutlet UILabel *pieChartPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *pieChartSpeciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pieChartCaughtLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pieChartControl;
@property (weak, nonatomic) IBOutlet UIButton *totalButton;
@property (weak, nonatomic) IBOutlet UIImageView *longestCatchImage;
@property (weak, nonatomic) IBOutlet UILabel *longestCatchNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestCatchValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *heaviestCatchImage;
@property (weak, nonatomic) IBOutlet UILabel *heaviestCatchNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *heaviestCatchValueLabel;

@property (strong, nonatomic) CMANoXView *noStatsView;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (strong, nonatomic) NSMutableArray *colorsArray;
@property (strong, nonatomic) CMAStats *stats;
@property (strong, nonatomic) CMAEntry *longestCatchEntry;
@property (strong, nonatomic) CMAEntry *heaviestCatchEntry;
@property (strong, nonatomic) CMAEntry *entryForSingleEntry;

@property (nonatomic) NSInteger initialSelectedIndex;

@end

#define kSectionLongestFish 1
#define kSectionHeaviestFish 2

#define kDefaultHeaderHeight 30

@implementation CMAStatisticsViewController

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

- (void)initNoStatsView {
    self.noStatsView = (CMANoXView *)[[[NSBundle mainBundle] loadNibNamed:@"CMANoXView" owner:self options:nil] objectAtIndex:0];
    
    self.noStatsView.imageView.image = [UIImage imageNamed:@"stats_large.png"];
    self.noStatsView.titleView.text = @"Entries.";
    self.noStatsView.subtitleView.text = @"Visit the \"All Entries\" page to begin.";
    
    [self.noStatsView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.noStatsView];
}

- (void)handleNoStatsView {
    if ([[self journal] entryCount] <= 0)
        [self initNoStatsView];
    else {
        [self.noStatsView removeFromSuperview];
        self.noStatsView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideBarMenu];
    [self handleNoStatsView];
    
    if ([[self journal] entryCount] > 0) {
        [self setStats:[CMAStats forCaughtWithJournal:[self journal]]];
        [self initColorsArray];
        [self initChartView];
        [self setInitialSelectedIndex:[self.stats highestValueIndex]];
        
        [self.chartView bringSubviewToFront:self.pieChartCenterView];
        [self.chartView bringSubviewToFront:self.totalButton];
        [self.chartView bringSubviewToFront:self.pieChartControl];
        
        [self initTableView];
    }
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    [self.pieChart reloadData];
    
    if (self.initialSelectedIndex != -1)
        [self selectPieChartSliceAtIndex:self.initialSelectedIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kSectionLongestFish || section == kSectionHeaviestFish)
        return kDefaultHeaderHeight;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)initTableView {
    self.longestCatchEntry = [self.stats highCatchEntryFor:kHighCatchEntryLength];
    self.heaviestCatchEntry = [self.stats highCatchEntryFor:kHighCatchEntryWeight];
    
    if ([self.longestCatchEntry imageCount] > 0)
        [self.longestCatchImage setImage:[self.longestCatchEntry.images anyObject]];
    else
        [self.longestCatchImage setImage:[UIImage imageNamed:@"no-image.png"]];
    
    [self.longestCatchNameLabel setText:self.longestCatchEntry.fishSpecies.name];
    [self.longestCatchValueLabel setText:[NSString stringWithFormat:@"%@ %@", [self.longestCatchEntry.fishLength stringValue], [[self journal] lengthUnitsAsString:NO]]];
    
    if ([self.heaviestCatchEntry imageCount] > 0)
        [self.heaviestCatchImage setImage:[self.heaviestCatchEntry.images anyObject]];
    else
        [self.heaviestCatchImage setImage:[UIImage imageNamed:@"no-image.png"]];
    
    [self.heaviestCatchNameLabel setText:self.heaviestCatchEntry.fishSpecies.name];
    [self.heaviestCatchValueLabel setText:[NSString stringWithFormat:@"%@ %@", [self.heaviestCatchEntry.fishWeight stringValue], [[self journal] weightUnitsAsString:NO]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionLongestFish) {
        self.entryForSingleEntry = self.longestCatchEntry;
        [self performSegueWithIdentifier:@"fromStatisticsToSingleEntry" sender:self];
    }
    
    if (indexPath.section == kSectionHeaviestFish) {
        self.entryForSingleEntry = self.heaviestCatchEntry;
        [self performSegueWithIdentifier:@"fromStatisticsToSingleEntry" sender:self];
    }
}

#pragma mark - Chart View Initializing

- (void)updatePieCenterLabelsForIndex:(NSInteger)anIndex {
    self.pieChartPercentLabel.text = [self.stats stringForPercentAtIndex:anIndex];
    self.pieChartSpeciesLabel.text = [self.stats nameAtIndex:anIndex];
    self.pieChartCaughtLabel.text = [self.stats detailTextAtIndex:anIndex];
}

- (void)updatePieCenterLabelsForTotal {
    self.pieChartPercentLabel.text = [NSString stringWithFormat:@"%ld", [self.stats totalValue]];
    self.pieChartSpeciesLabel.text = [self.stats totalDescription];
    
    // get the earliest entry date
    NSDate *earliestDate = [self.stats earliestEntryDate];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    self.pieChartCaughtLabel.text = [NSString stringWithFormat:@"Since %@", [dateFormatter stringFromDate:earliestDate]];
}

- (void)selectPieChartSliceAtIndex:(NSInteger)anIndex {
    [self.pieChart setSliceSelectedAtIndex:anIndex];
    [self updatePieCenterLabelsForIndex:anIndex];
    self.initialSelectedIndex = anIndex;
}

- (void)initColorsArray {
    NSMutableArray *colors = [NSMutableArray array];
    
    float INCREMENT = 0.05;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:0.5
                                    brightness:1.0
                                         alpha:1.0];
        [colors addObject:color];
    }
    
    // shuffle colors
    NSUInteger count = [colors count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [colors exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    self.colorsArray = [NSMutableArray array];
    NSInteger colorsIndex = 0;
    NSInteger speciesIndex = 0;
    
    // cycle through "colors" until there's a color for every species
    for (speciesIndex = 0; speciesIndex < [self.stats sliceObjectCount]; speciesIndex++) {
        [self.colorsArray addObject:[colors objectAtIndex:colorsIndex]];
        
        colorsIndex++;
        if (colorsIndex == [colors count])
            colorsIndex = 0;
    }
}

- (void)initChartView {
    CGFloat screenWidth = self.view.frame.size.width;
    
    NSInteger chartRadius = screenWidth * 0.40;
    NSInteger chartViewHeight = 335;
    NSInteger chartViewWidth  = screenWidth * 0.85;
    
    CGRect frame = CGRectMake((screenWidth - chartViewWidth) / 2, 0, chartViewWidth, chartViewHeight);
    CGPoint center = CGPointMake(frame.size.width / 2, self.pieChartCenterView.center.y);
    self.pieChart = [[XYPieChart alloc] initWithFrame:frame Center:center Radius:chartRadius];
    
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setLabelColor:[UIColor blackColor]];
    [self.pieChart setShowLabel:NO];
    [self.pieChart setLabelRadius:chartRadius - 15];
    [self.pieChart setShowPercentage:NO];
    
    [self.chartView setFrame:frame];
    [self.chartView addSubview:self.pieChart];

    [self.pieChartCenterView.layer setCornerRadius:self.pieChartCenterView.frame.size.width / 2];
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return [self.stats sliceObjectCount];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [self.stats valueForSliceAtIndex:index];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.colorsArray objectAtIndex:index];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    return [self.stats nameAtIndex:index];
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    if (self.initialSelectedIndex != -1) {
        [pieChart setSliceDeselectedAtIndex:self.initialSelectedIndex];
        self.initialSelectedIndex = -1;
    }
    
    [self updatePieCenterLabelsForIndex:index];
}

#pragma mark - Events

- (IBAction)tapPieChartCenter:(UITapGestureRecognizer *)sender {
    if (self.stats.pieChartDataType == CMAPieChartDataTypeBait)
        [self performSegueWithIdentifier:@"fromStatisticsToViewBaits" sender:self];
    else
        [self performSegueWithIdentifier:@"fromStatisticsToUserDefines" sender:self];
}

- (IBAction)tapTotalButton:(UIButton *)sender {
    [self.pieChart reloadData];
    [self updatePieCenterLabelsForTotal];
}

- (IBAction)changePieChartControl:(UISegmentedControl *)sender {
    self.stats = nil;
    
    if (sender.selectedSegmentIndex == CMAPieChartDataTypeCaught)
        self.stats = [CMAStats forCaughtWithJournal:[self journal]];
    
    if (sender.selectedSegmentIndex == CMAPieChartDataTypeWeight)
        self.stats = [CMAStats forWeightWithJournal:[self journal]];
    
    if (sender.selectedSegmentIndex == CMAPieChartDataTypeBait)
        self.stats = [CMAStats forBaitWithJournal:[self journal]];
    
    if (sender.selectedSegmentIndex == CMAPieChartDataTypeLocation)
        self.stats = [CMAStats forLocationWithJournal:[self journal]];
    
    [self initColorsArray];
    [self.pieChart reloadData];
    [self selectPieChartSliceAtIndex:[self.stats highestValueIndex]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // bait used
    if ([segue.identifier isEqualToString:@"fromStatisticsToViewBaits"]){
        CMAViewBaitsViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.isSelectingForStatistics = YES;
    }
    
    if ([segue.identifier isEqualToString:@"fromStatisticsToUserDefines"]) {
        CMAUserDefinesViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.userDefine = [[self journal] userDefineNamed:self.stats.userDefineName];
        destination.previousViewID = CMAViewControllerID_Statistics;
    }
    
    if ([segue.identifier isEqualToString:@"fromStatisticsToSingleEntry"]) {
        CMASingleEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.entry = self.entryForSingleEntry;
    }
}

- (IBAction)unwindToStatistics:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToStatisticsFromUserDefines"]) {
        CMAUserDefinesViewController *source = [segue sourceViewController];
        self.initialSelectedIndex = [self.stats indexForName:source.selectedCellLabelText]; // this property is used in viewWillAppear
        source.previousViewID = CMAViewControllerID_Nil;
    }
    
    if ([segue.identifier isEqualToString:@"unwindToStatisticsFromViewBaits"]) {
        CMAViewBaitsViewController *source = [segue sourceViewController];
        self.initialSelectedIndex = [self.stats indexForName:source.baitNameForStatistics]; // this property is used in viewWillAppear
        source.isSelectingForStatistics = NO;
    }
}

@end
