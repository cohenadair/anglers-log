//
//  CMAConstants.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#ifndef MyFishingJournal_CMAConstants_h
#define MyFishingJournal_CMAConstants_h

typedef enum {
    CMAViewControllerID_Nil = 0,
    CMAViewControllerID_Home = 1,
    CMAViewControllerID_ViewEntries = 2,
    CMAViewControllerID_EditSettings = 3,
    CMAViewControllerID_AddEntry = 4,
    CMAViewControllerID_SingleEntry = 5,
    CMAViewControllerID_SingleLocation = 6
} CMAViewControllerID;

// Each value represents the index for an item in a UISegmentedControlView.
typedef enum {
    CMAMeasuringSystemType_Imperial = 0,
    CMAMeasuringSystemType_Metric = 1
} CMAMeasuringSystemType;

extern NSString *const SET_SPECIES;
extern NSString *const SET_BAITS;
extern NSString *const SET_LOCATIONS;
extern NSString *const SET_FISHING_METHODS;

// Used for splitting up NSStrings.
extern NSString *const TOKEN_FISHING_METHODS;
extern NSString *const TOKEN_LOCATION;

extern CGFloat const TABLE_SECTION_SPACING;

#endif
