//
//  CMAStatisticsViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "CMAEntry.h"

@interface CMAStatisticsViewController : UIViewController <XYPieChartDataSource, XYPieChartDelegate, ADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
