//
//  CMASingleBaitViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleBaitViewController.h"
#import "CMAAddBaitViewController.h"
#import "CMAConstants.h"

@interface CMASingleBaitViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *baitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *baitFishCaughtLabel;

@end

#define kDefaultCellHeight 30

@implementation CMASingleBaitViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    if (self.isReadOnly)
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (self.bait.image)
            return self.tableView.frame.size.width;
        else
            return 10;
    }
    
    if (indexPath.row == 2) {
        if (self.bait.description) {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:GLOBAL_FONT size:16]};
            CGRect rect = [self.bait.baitDescription boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:attributes
                                                                  context:nil];
            
            if (rect.size.height > kDefaultCellHeight)
                return rect.size.height + 20;
        }
    }
    
    return kDefaultCellHeight;
}

- (void)initTableView {
    [self.navigationItem setTitle:self.bait.name];
    [self.imageView setImage:self.bait.image];
    [self.baitFishCaughtLabel setText:[self.bait.fishCaught stringValue]];
    
    if (self.bait.baitDescription)
        [self.baitDescriptionLabel setText:self.bait.baitDescription];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleBaitToAddBait"]) {
        CMAAddBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.bait = self.bait;
        destination.previousViewID = CMAViewControllerID_SingleBait;
    }
}

- (IBAction)unwindToSingleBait:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToSingleBaitFromAddBait"]) {
        CMAAddBaitViewController *source = segue.sourceViewController;
        self.bait = source.bait;
        source.bait = nil;
        [self initTableView];
    }
}

@end
