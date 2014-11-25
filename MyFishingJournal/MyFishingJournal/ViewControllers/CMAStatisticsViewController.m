//
//  CMAStatisticsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAStatisticsViewController.h"
#import "CMAUserDefinesViewController.h"
#import "CMANoXView.h"
#import "CMAAppDelegate.h"
#import "CMAJournalStats.h"
#import "SWRevealViewController.h"

@interface CMAStatisticsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIView *pieChartCenterView;
@property (weak, nonatomic) IBOutlet UILabel *pieChartPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *pieChartSpeciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pieChartCaughtLabel;
@property (weak, nonatomic) IBOutlet UIButton *totalButton;

@property (strong, nonatomic) CMANoXView *noStatsView;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (strong, nonatomic) NSMutableArray *colorsArray;
@property (strong, nonatomic) CMAJournalStats *journalStats;

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
        [self setJournalStats:[CMAJournalStats withJournal:[self journal]]];
        [self initColorsArray];
        [self initChartView];
        [self setInitialSelectedIndex:self.journalStats.mostCaughtSpeciesIndex];
        
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

- (NSString *)speciesNameLabelForIndex:(NSInteger)anIndex {
    return [NSString stringWithFormat:@"%@", [[self.journalStats speciesStatsAtIndex:anIndex] name]];
}

- (NSString *)speciesCaughtLabelForIndex:(NSInteger)anIndex {
    return [NSString stringWithFormat:@"%ld Caught", [[self.journalStats speciesStatsAtIndex:anIndex] numberCaught]];
}

- (NSString *)speciesPercentLabelForIndex:(NSInteger)anIndex {
    return [NSString stringWithFormat:@"%ld%%", [[self.journalStats speciesStatsAtIndex:anIndex] percentOfTotalCaught]];
}

- (void)selectPieChartSliceAtIndex:(NSInteger)anIndex {
    [self.pieChart setSliceSelectedAtIndex:anIndex];
    
    self.pieChartPercentLabel.text = [self speciesPercentLabelForIndex:anIndex];
    self.pieChartSpeciesLabel.text = [self speciesNameLabelForIndex:anIndex];
    self.pieChartCaughtLabel.text = [self speciesCaughtLabelForIndex:anIndex];
    
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
    for (speciesIndex = 0; speciesIndex < [self.journalStats speciesCaughtStatsCount]; speciesIndex++) {
        [self.colorsArray addObject:[colors objectAtIndex:colorsIndex]];
        
        colorsIndex++;
        if (colorsIndex == [colors count])
            colorsIndex = 0;
    }
}

#define CHART_RADUIS 125
#define CHART_FRAME_HEIGHT 290
#define CHART_FRAME_WIDTH 270

- (void)initChartView {
    CGRect frame = CGRectMake((self.view.frame.size.width - CHART_FRAME_WIDTH) / 2, 0, CHART_FRAME_WIDTH, CHART_FRAME_HEIGHT);
    CGPoint center = CGPointMake(frame.size.width / 2, (frame.size.height / 2));
    self.pieChart = [[XYPieChart alloc] initWithFrame:frame Center:center Radius:CHART_RADUIS];
    
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setAnimationSpeed:1.0];
    [self.pieChart setLabelColor:[UIColor blackColor]];
    [self.pieChart setShowLabel:NO];
    [self.pieChart setLabelRadius:CHART_RADUIS - 15];
    [self.pieChart setShowPercentage:NO];
    
    [self.chartView setFrame:frame];
    [self.chartView addSubview:self.pieChart];
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return [self.journalStats.speciesCaughtStats count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.journalStats speciesStatsAtIndex:index] numberCaught];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.colorsArray objectAtIndex:index];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    return [[self.journalStats speciesStatsAtIndex:index] name];
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    if (self.initialSelectedIndex != -1) {
        [pieChart setSliceDeselectedAtIndex:self.initialSelectedIndex];
        self.initialSelectedIndex = -1;
    }
    
    self.pieChartPercentLabel.text = [self speciesPercentLabelForIndex:index];
    self.pieChartSpeciesLabel.text = [self speciesNameLabelForIndex:index];
    self.pieChartCaughtLabel.text = [self speciesCaughtLabelForIndex:index];
}

#pragma mark - Events

- (IBAction)tapPieChartCenter:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"fromStatisticsToUserDefines" sender:self];
}

- (IBAction)tapTotalButton:(UIButton *)sender {
    [self.pieChart reloadData];
    
    self.pieChartPercentLabel.text = [NSString stringWithFormat:@"%ld", self.journalStats.totalFishCaught];
    self.pieChartSpeciesLabel.text = @"Total Fish Caught";
    
    // get the earliest entry date
    NSDate *earliestDate = [self.journalStats earliestEntryDate];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    self.pieChartCaughtLabel.text = [NSString stringWithFormat:@"Since %@", [dateFormatter stringFromDate:earliestDate]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // bait used
    if ([segue.identifier isEqualToString:@"fromStatisticsToUserDefines"]) {
        CMAUserDefinesViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.userDefine = [[self journal] userDefineNamed:SET_SPECIES];
        destination.previousViewID = CMAViewControllerID_Statistics;
    }
}

- (IBAction)unwindToStatistics:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToStatisticsFromUserDefines"]) {
        CMAUserDefinesViewController *source = [segue sourceViewController];
        
        NSInteger index = [self.journalStats speciesCaughtStatsIndexForName:source.selectedCellLabelText];
        
        if (index != -1) {
            self.initialSelectedIndex = index;
        } else {
            self.pieChartPercentLabel.text = @"0%";
            self.pieChartSpeciesLabel.text = source.selectedCellLabelText;
            self.pieChartCaughtLabel.text = @"0 Caught";
            
            self.initialSelectedIndex = -1;
        }
        
        source.previousViewID = CMAViewControllerID_Nil;
    }
}

@end
