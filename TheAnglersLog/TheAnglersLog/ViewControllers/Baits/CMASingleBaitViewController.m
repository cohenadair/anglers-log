//
//  CMASingleBaitViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
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

@end

#define kDefaultCellHeight 30

#define kPhotoCellRow 0
#define kSizeRow 3
#define kDescriptionCellRow 4

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
    
    if (indexPath.row == kSizeRow && !self.bait.size)
        return 0;
    
    if (indexPath.row == kDescriptionCellRow) {
        if (self.bait.description) {
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
    
    [cell setHidden:(indexPath.row == kSizeRow && !self.bait.size)];
    
    return cell;
}

- (void)initTableView {
    [self.imageView setImage:[self.bait.imageData fullImage]];
    [self.baitFishCaughtLabel setText:[self.bait.fishCaught stringValue]];
    [self.baitTypeLabel setText:[self.bait typeAsString]];
    
    if (self.bait.size)
        [self.baitSizeLabel setText:self.bait.size];
    
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
