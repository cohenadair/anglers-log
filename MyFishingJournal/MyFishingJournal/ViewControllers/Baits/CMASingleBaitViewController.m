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

@end

@implementation CMASingleBaitViewController

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
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
            return 0;
    }
    
    if (indexPath.row == 1 && !self.bait.name)
        return 0;
    
    if (indexPath.row == 2) {
        if (!self.bait.description)
            return 0;
        else {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:GLOBAL_FONT size:17]};
            CGRect rect = [self.bait.baitDescription boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:attributes
                                                                  context:nil];
            return rect.size.height;
        }
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)initTableView {
    [self.imageView setImage:self.bait.image];
    [self.baitNameLabel setText:self.bait.name];
    
    if (self.bait.baitDescription)
        [self.baitDescriptionLabel setText:self.bait.baitDescription];
    else
        [self.baitDescriptionLabel setText:@"No description provided."];
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
