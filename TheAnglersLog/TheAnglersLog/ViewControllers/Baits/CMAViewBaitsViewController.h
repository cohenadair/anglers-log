//
//  CMAViewBaitsViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
#import "CMABait.h"

@interface CMAViewBaitsViewController : UIViewController <ADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic)BOOL isSelectingForAddEntry;
@property (nonatomic)BOOL isSelectingForStatistics;
@property (strong, nonatomic)CMABait *baitForAddEntry;
@property (strong, nonatomic)NSString *baitNameForStatistics; // used for unwind to statistics

@end
