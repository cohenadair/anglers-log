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
@property (weak, nonatomic) IBOutlet UISegmentedControl *piChartControl;
@property (weak, nonatomic) IBOutlet UIButton *totalButton;

@property (strong, nonatomic) CMANoXView *noStatsView;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (strong, nonatomic) NSMutableArray *colorsArray;
@property (strong, nonatomic) CMAJournalStats *journalStats;

@property (nonatomic) NSInteger initialSelectedIndex;
@property (nonatomic) NSInteger pieChartType;

@end

// Indexes of pie chart segmented control.
#define kPieChartTypeCaught 0
#define kPieChartTypeWeight 1
#define kPieChartTypeBait 2
#define kPieChartTypeLocation 3

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
        [self setPieChartType:kPieChartTypeCaught];
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

- (NSArray *)pieCenterLabelsForIndex:(NSInteger)anIndex {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger percentValue = 0;
    NSString *detailText = @"";
    NSString *nameLabel = @"";
    
    switch (self.pieChartType) {
        case kPieChartTypeCaught:
            percentValue = [[self.journalStats speciesStatsAtIndex:anIndex] percentOfTotalCaught];
            nameLabel = [NSString stringWithFormat:@"%@", [[self.journalStats speciesStatsAtIndex:anIndex] name]];
            detailText = [NSString stringWithFormat:@"%ld Caught", [[self.journalStats speciesStatsAtIndex:anIndex] numberCaught]];
            break;
            
        case kPieChartTypeWeight:
            percentValue = [[self.journalStats speciesStatsAtIndex:anIndex] percentOfTotalWeight];
            nameLabel = [NSString stringWithFormat:@"%@", [[self.journalStats speciesStatsAtIndex:anIndex] name]];
            detailText = [NSString stringWithFormat:@"%ld %@", [[self.journalStats speciesStatsAtIndex:anIndex] weightCaught], [[self journal] weightUnitsAsString:NO]];
            break;
            
        default:
            NSLog(@"Invalid pieChartType in pieCenterDetailLabelForIndex");
            break;
    }
    
    [result addObject:[NSString stringWithFormat:@"%ld%%", percentValue]]; // percent label
    [result addObject:nameLabel]; // name; middle label
    [result addObject:detailText]; // detail label
    
    return result;
}

- (void)updatePieCenterLabelsForIndex:(NSInteger)anIndex {
    NSArray *labelTexts = [self pieCenterLabelsForIndex:anIndex];
    self.pieChartPercentLabel.text = [labelTexts objectAtIndex:0];
    self.pieChartSpeciesLabel.text = [labelTexts objectAtIndex:1];
    self.pieChartCaughtLabel.text = [labelTexts objectAtIndex:2];
}

- (void)selectPieChartSliceAtIndex:(NSInteger)anIndex {
    [self.pieChart setSliceSelectedAtIndex:anIndex];
    [self updatePieCenterLabelsForIndex:anIndex];
    self.initialSelectedIndex = anIndex;
}

- (void)selectInitialSliceForPieChartType:(NSInteger)aPieChartType {
    switch (aPieChartType) {
        case kPieChartTypeCaught:
            [self selectPieChartSliceAtIndex:[self.journalStats mostCaughtSpeciesIndex]];
            break;
            
        case kPieChartTypeWeight:
            [self selectPieChartSliceAtIndex:[self.journalStats mostWeightSpeciesIndex]];
            break;
            
        default:
            NSLog(@"Invalid pie chart type in selectInitialSliceForPieChartType");
            break;
    }
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
    return [self.journalStats.speciesCaughtStats count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if (self.pieChartType == kPieChartTypeCaught)
        return [[self.journalStats speciesStatsAtIndex:index] numberCaught];
    
    if (self.pieChartType == kPieChartTypeWeight)
        return [[self.journalStats speciesStatsAtIndex:index] weightCaught];
    
    NSLog(@"Invalid pie chart type in valueForSliceAtIndex.");
    return 0.0;
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
    
    [self updatePieCenterLabelsForIndex:index];
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

- (IBAction)changePieChartControl:(UISegmentedControl *)sender {
    self.pieChartType = sender.selectedSegmentIndex;
    [self.pieChart reloadData];
    [self selectInitialSliceForPieChartType:self.pieChartType];
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
