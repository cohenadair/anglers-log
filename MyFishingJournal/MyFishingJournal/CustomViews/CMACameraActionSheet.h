//
//  CMACameraActionSheet.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 11/18/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMACameraActionSheet : UIActionSheet

+ (CMACameraActionSheet *)withDelegate:(id<UIActionSheetDelegate>)aDelegate;

@end
