//
//  CMASingleEntryViewController.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>
#import "CMAEntry.h"

@interface CMASingleEntryViewController : UITableViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic)CMAEntry *entry;

@end
