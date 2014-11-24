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
#import "SWRevealViewController.h"

@interface CMAStatisticsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *selectSpeciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectSpeciesDetailLabel;

@property (strong, nonatomic) CMANoXView *noStatsView;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (strong, nonatomic) NSDictionary *speciesDictionary;
@property (strong, nonatomic) NSArray *speciesKeys;
@property (strong, nonatomic) NSMutableArray *colorsArray;
@property (strong, nonatomic) NSString *initialSelectedKey;
@property (nonatomic) NSInteger initialSelectedIndex;
@property (nonatomic) BOOL didUnwind;

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
        self.speciesDictionary = [self setSpeciesCounts];
        self.speciesKeys = [self.speciesDictionary allKeys];
        [self initColorsArray];
        
        [self initChartView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    [self.pieChart reloadData];
    
    if (self.initialSelectedKey != nil)
        [self selectPieChartSliceForKey:self.initialSelectedKey];
    
    if (!self.didUnwind)
        self.didUnwind = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (NSString *)speciesLabelForIndex:(NSInteger)anIndex {
    return [NSString stringWithFormat:@"%@ Caught", [self.speciesKeys objectAtIndex:anIndex]];
}

- (NSString *)speciesCountLabelForIndex:(NSInteger)anIndex {
    return [[self.speciesDictionary objectForKey:[self.speciesKeys objectAtIndex:anIndex]] stringValue];
}

#pragma mark - Chart View Initializing

- (NSInteger)sliceIndexForKey:(NSString *)aKey {
    for (NSInteger i = 0; i < [self.speciesKeys count]; i++)
        if ([self.speciesKeys[i] isEqualToString:aKey])
            return i;
    
    return -1;
}

- (void)selectPieChartSliceAtIndex:(NSInteger)anIndex {
    [self.pieChart setSliceSelectedAtIndex:anIndex];
    self.selectSpeciesLabel.text = [self speciesLabelForIndex:anIndex];
    self.selectSpeciesDetailLabel.text = [self speciesCountLabelForIndex:anIndex];
    self.initialSelectedIndex = anIndex;
}

- (void)selectPieChartSliceForKey:(NSString *)aKey {
    [self selectPieChartSliceAtIndex:[self sliceIndexForKey:aKey]];
}

- (void)initColorsArray {
    NSMutableArray *colors = [NSMutableArray array];
    
    float INCREMENT = 0.05;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:0.5];
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
    NSInteger keyIndex = 0;
    
    for (keyIndex = 0; keyIndex < [self.speciesKeys count]; keyIndex++) {
        [self.colorsArray addObject:[colors objectAtIndex:colorsIndex]];
        
        colorsIndex++;
        if (colorsIndex == [colors count])
            colorsIndex = 0;
    }
}

- (NSDictionary *)setSpeciesCounts {
    NSArray *allEntries = [[self journal] entries];
    NSArray *allSpecies = [[[self journal] userDefineNamed:SET_SPECIES] objects];
    NSMutableDictionary *allSpeciesCounts = [NSMutableDictionary dictionary];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // initialize a dictionary will all species names with value of 0
    for (CMASpecies *species in allSpecies)
        [allSpeciesCounts setObject:[NSNumber numberWithInteger:0] forKey:species.name];
    
    // count number of catches by iterating through the journal's entries
    for (CMAEntry *entry in allEntries) {
        NSInteger oldCount = [[allSpeciesCounts objectForKey:entry.fishSpecies.name] integerValue];
        
        NSInteger temp = 0;
        if ([entry.fishQuantity integerValue] <= 0)
            temp = 1;
        else
            temp = [entry.fishQuantity integerValue];
        
        NSNumber *newCount = [NSNumber numberWithInteger:oldCount + temp];
        [allSpeciesCounts setObject:newCount forKey:entry.fishSpecies.name];
    }
    
    NSInteger highest = 0;
    
    // get species that only have more that 0 catches
    for (NSString *key in allSpeciesCounts) {
        NSInteger c = [[allSpeciesCounts objectForKey:key] integerValue];
        
        if (c > 0)
            [result setObject:[NSNumber numberWithInteger:c] forKey:key];
        
        if (c > highest) {
            highest = c;
            self.initialSelectedKey = key;
        }
    }
    
    return result;
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
    return [self.speciesKeys count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.speciesDictionary objectForKey:[self.speciesKeys objectAtIndex:index]] floatValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.colorsArray objectAtIndex:index];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    return [self.speciesKeys objectAtIndex:index];
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    if (self.initialSelectedIndex != -1) {
        [pieChart setSliceDeselectedAtIndex:self.initialSelectedIndex];
        self.initialSelectedIndex = -1;
    }
    
    self.selectSpeciesLabel.text = [self speciesLabelForIndex:index];
    self.selectSpeciesDetailLabel.text = [self speciesCountLabelForIndex:index];
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
        
        NSInteger index = [self sliceIndexForKey:source.selectedCellLabelText];
        
        if (index != -1) {
            self.initialSelectedKey = source.selectedCellLabelText;
            self.didUnwind = YES;
        } else {
            self.initialSelectedKey = nil;
            self.selectSpeciesLabel.text = source.selectedCellLabelText;
            self.selectSpeciesDetailLabel.text = @"0";
            self.initialSelectedIndex = -1;
        }
        
        source.previousViewID = CMAViewControllerID_Nil;
    }
}

@end
