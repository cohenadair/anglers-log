//
//  CMAStatisticsViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/15/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "CMAEntry.h"

@interface CMAStatisticsViewController : UITableViewController <XYPieChartDataSource, XYPieChartDelegate>

@end
