//
//  CMASingleEntryViewController.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMAEntry.h"

@interface CMASingleEntryViewController : UITableViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic)CMAEntry *entry;

@end
