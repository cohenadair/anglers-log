//
//  CMASingleBaitViewController.m
//  AnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "CMASingleBaitViewController.h"
#import "CMAAddBaitViewController.h"
#import "CMAConstants.h"
#import "CMAImage.h"

@interface CMASingleBaitViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *baitDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitFishCaughtLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitColorLabel;

@end

#define kDefaultCellHeight 30

#define kPhotoCellRow 0
#define kSizeRow 3
#define kColorRow 4
#define kDescriptionRow 5

@implementation CMASingleBaitViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kPhotoCellRow) {
        if (self.bait.imageData)
            return self.tableView.frame.size.width;
        else
            return 10;
    }
    
    if ((indexPath.row == kSizeRow && !self.bait.size) || (indexPath.row == kColorRow && !self.bait.color))
        return 0;
    
    if (indexPath.row == kDescriptionRow) {
        if (self.bait.baitDescription) {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:GLOBAL_FONT size:16]};
            CGRect rect = [self.bait.baitDescription boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 40, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:attributes
                                                                  context:nil];
        
            if (rect.size.height > kDefaultCellHeight)
                return rect.size.height + 18;
        } else
            return 0;
    }
    
    return kDefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [cell setHidden:
     (indexPath.row == kSizeRow && !self.bait.size) ||
     (indexPath.row == kColorRow && !self.bait.color) ||
     (indexPath.row == kDescriptionRow && !self.bait.baitDescription)];
    
    return cell;
}

- (void)initTableView {
    [self.imageView setImage:[self.bait.imageData image]];
    [self.baitFishCaughtLabel setText:[self.bait.fishCaught stringValue]];
    [self.baitTypeLabel setText:[self.bait typeAsString]];
    
    if (self.bait.size)
        [self.baitSizeLabel setText:self.bait.size];
    
    if (self.bait.color)
        [self.baitColorLabel setText:self.bait.color];
    
    if (self.bait.baitDescription) {
        [self.baitDescriptionLabel setText:self.bait.baitDescription];
        
        // a hack to get hide a mysterious horizontal line that appears when the description is on multiple lines
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
        [line setBackgroundColor:[UIColor whiteColor]];
        [self.baitDescriptionLabel addSubview:line];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleBaitToAddBait"]) {
        CMAAddBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.bait = self.bait;
        destination.previousViewID = CMAViewControllerIDSingleBait;
    }
}

- (IBAction)unwindToSingleBait:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToSingleBaitFromAddBait"]) {
        CMAAddBaitViewController *source = segue.sourceViewController;
        
        self.bait = source.bait;
        self.navigationItem.title = self.bait.name;
        
        [self initTableView];
        
        source.bait = nil;
    }
}

@end