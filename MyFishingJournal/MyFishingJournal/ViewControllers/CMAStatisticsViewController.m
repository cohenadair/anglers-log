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
@property (weak, nonatomic) IBOutlet UISegmentedControl *piChartControl;
@property (weak, nonatomic) IBOutlet UIButton *totalButton;

@property (strong, nonatomic) CMANoXView *noStatsView;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (strong, nonatomic) NSMutableArray *colorsArray;
@property (strong, nonatomic) CMAStats *stats;

@property (nonatomic) NSInteger initialSelectedIndex;

@end

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
        
        [self.pieChartCenterView.layer setCornerRadius:self.pieChartCenterView.frame.size.height / 2];
        [self.chartView bringSubviewToFront:self.pieChartCenterView];
        [self.chartView bringSubviewToFront:self.totalButton];
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
    NSInteger chartRadius = 125;
    NSInteger chartHeight = 290;
    NSInteger chartWidth  = 270;
    
    CGRect frame = CGRectMake((self.view.frame.size.width - chartWidth) / 2, 0, chartWidth, chartHeight);
    CGPoint center = CGPointMake(frame.size.width / 2, (frame.size.height / 2));
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
