//
//  CMAConstants.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#ifndef MyFishingJournal_CMAConstants_h
#define MyFishingJournal_CMAConstants_h

typedef NS_ENUM(NSInteger, CMAViewControllerID) {
    CMAViewControllerIDNil = -1,
    CMAViewControllerIDViewEntries = 0,
    CMAViewControllerIDEditSettings = 1,
    CMAViewControllerIDAddEntry = 2,
    CMAViewControllerIDSingleEntry = 3,
    CMAViewControllerIDSingleLocation = 4,
    CMAViewControllerIDSingleBait = 5,
    CMAViewControllerIDViewBaits = 6,
    CMAViewControllerIDStatistics = 7,
    CMAViewControllerIDSelectFishingSpot = 8
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMAMeasuringSystemType) {
    CMAMeasuringSystemTypeImperial = 0,
    CMAMeasuringSystemTypeMetric = 1
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMASortOrder) {
    CMASortOrderAscending = 0,
    CMASortOrderDescending = 1
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMABaitType) {
    CMABaitTypeArtificial = 0,
    CMABaitTypeLive = 1
};

// Each value >= 0 represents an index for a row in a UITableView.
typedef NS_ENUM(NSInteger, CMAEntrySortMethod) {
    CMAEntrySortMethodNil = -1,
    CMAEntrySortMethodDate = 0,
    CMAEntrySortMethodSpecies = 1,
    CMAEntrySortMethodLocation = 2,
    CMAEntrySortMethodLength = 3,
    CMAEntrySortMethodWeight = 4,
    CMAEntrySortMethodBaitUsed = 5
};

extern NSString *const APP_NAME;

// user defines
extern NSString *const SET_SPECIES;
extern NSString *const SET_BAITS;
extern NSString *const SET_LOCATIONS;
extern NSString *const SET_FISHING_METHODS;
extern NSString *const SET_WATER_CLARITIES;

// Used for splitting up NSStrings.
extern NSString *const TOKEN_FISHING_METHODS;
extern NSString *const TOKEN_LOCATION;

// User data file name.
extern NSString *const ARCHIVE_FILE_NAME;

extern NSString *const SHARE_MESSAGE;
extern NSString *const REMOVED_TEXT; // text displayed in an entry when a user define has been removed

// measurement units
extern NSString *const UNIT_IMPERIAL_LENGTH;
extern NSString *const UNIT_IMPERIAL_LENGTH_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_WEIGHT;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SMALL;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_DEPTH;
extern NSString *const UNIT_IMPERIAL_DEPTH_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_TEMPERATURE;
extern NSString *const UNIT_IMPERIAL_TEMPERATURE_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_SPEED;
extern NSString *const UNIT_IMPERIAL_SPEED_SHORTHAND;

extern NSString *const UNIT_METRIC_LENGTH;
extern NSString *const UNIT_METRIC_LENGTH_SHORTHAND;
extern NSString *const UNIT_METRIC_WEIGHT;
extern NSString *const UNIT_METRIC_WEIGHT_SHORTHAND;
extern NSString *const UNIT_METRIC_DEPTH;
extern NSString *const UNIT_METRIC_DEPTH_SHORTHAND;
extern NSString *const UNIT_METRIC_TEMPERATURE;
extern NSString *const UNIT_METRIC_TEMPERATURE_SHORTHAND;
extern NSString *const UNIT_METRIC_SPEED;
extern NSString *const UNIT_METRIC_SPEED_SHORTHAND;

// notifications
extern NSString *const NOTIFICATION_CHANGE_JOURNAL;

extern NSString *const GLOBAL_FONT;

extern CGFloat const TABLE_SECTION_SPACING;

UIColor *CELL_COLOR_DARK; // initialized in AppDelegate.m
UIColor *CELL_COLOR_LIGHT; // initialized in AppDelegate.m

#define kTableSectionHeaderHeight 40
#define kTableFooterHeight 25

#define kWeatherCellHeightExpanded 90

#define kOuncesInAPound 16

#endif
