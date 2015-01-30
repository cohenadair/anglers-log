//
//  CMAAddFishingSpotTableViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 11/6/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CMAFishingSpot.h"
#import "CMALocation.h"

@interface CMAAddFishingSpotViewController : UITableViewController

@property (strong, nonatomic)CMAFishingSpot *fishingSpot;
@property (strong, nonatomic)CMALocation *locationFromAddLocation;
@property (nonatomic)BOOL isEditingFishingSpot;

@end
