//
//  CMAConstants.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#ifndef AnglersLog_CMAConstants_h
#define AnglersLog_CMAConstants_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define mark = Typedefs

typedef enum cvID_e : int16_t {
    CMAViewControllerIDNil                  = -1,
    CMAViewControllerIDViewEntries          = 0,
    CMAViewControllerIDEditSettings         = 1,
    CMAViewControllerIDAddEntry             = 2,
    CMAViewControllerIDSingleEntry          = 3,
    CMAViewControllerIDSingleLocation       = 4,
    CMAViewControllerIDSingleBait           = 5,
    CMAViewControllerIDViewBaits            = 6,
    CMAViewControllerIDStatistics           = 7,
    CMAViewControllerIDSelectFishingSpot    = 8
} CMAViewControllerID;

// Each value represents the index for an item in a UISegmentedControlView.
typedef enum msID_e : int16_t {
    CMAMeasuringSystemTypeImperial  = 0,
    CMAMeasuringSystemTypeMetric    = 1
} CMAMeasuringSystemType;

// Each value represents the index for an item in a UISegmentedControlView.
typedef enum soID_e : int16_t {
    CMASortOrderAscending   = 0,
    CMASortOrderDescending  = 1
} CMASortOrder;

// Each value represents the index for an item in a UISegmentedControlView.
typedef enum btID_e : int16_t {
    CMABaitTypeArtificial   = 0,
    CMABaitTypeLive         = 1,
    CMABaitTypeReal         = 2
} CMABaitType;

// Each value >= 0 represents an index for a row in a UITableView.
typedef enum smID_e : int16_t {
    CMAEntrySortMethodNil       = -1,
    CMAEntrySortMethodDate      = 0,
    CMAEntrySortMethodSpecies   = 1,
    CMAEntrySortMethodLocation  = 2,
    CMAEntrySortMethodLength    = 3,
    CMAEntrySortMethodWeight    = 4,
    CMAEntrySortMethodBaitUsed  = 5,
    CMAEntrySortMethodResult    = 6
} CMAEntrySortMethod;

// Each value represents the index for an item in a UISegmentedControlView.
typedef enum frID_e : int16_t {
    CMAFishResultReleased   = 0,
    CMAFishResultKept       = 1
} CMAFishResult;

#pragma mark - Global Variables

extern NSString *const DATE_FILE_STRING;
extern NSString *const ACCURATE_DATE_FILE_STRING;
extern NSString *const DISPLAY_DATE_FORMAT;

#pragma mark - Application Constants

extern NSString *const APP_NAME;
extern NSString *const APP_STORE_LINK;
extern NSString *const FAQ_LINK;
extern NSString *const SHARE_MESSAGE;
extern NSString *const HASHTAG_TEXT;
extern NSString *const GLOBAL_FONT;
extern NSInteger const MODEL_VERSION;

#pragma mark - File Name Constants

extern NSString *const PNG;
extern NSString *const JPG;

#pragma mark - User Define Name (UDN)

extern NSString *const UDN_SPECIES;
extern NSString *const UDN_BAITS;
extern NSString *const UDN_LOCATIONS;
extern NSString *const UDN_FISHING_METHODS;
extern NSString *const UDN_WATER_CLARITIES;

#pragma mark - Core Data Entities (CDE)

extern NSString *const CDE_JOURNAL;
extern NSString *const CDE_ENTRY;
extern NSString *const CDE_USER_DEFINE;
extern NSString *const CDE_SPECIES;
extern NSString *const CDE_BAIT;
extern NSString *const CDE_LOCATION;
extern NSString *const CDE_FISHING_METHOD;
extern NSString *const CDE_WATER_CLARITY;
extern NSString *const CDE_WEATHER_DATA;
extern NSString *const CDE_FISHING_SPOT;
extern NSString *const CDE_IMAGE;

#pragma mark - Token Separators

extern NSString *const TOKEN_FISHING_METHODS;
extern NSString *const TOKEN_LOCATION;

#pragma mark - Unit Constants

extern NSString *const UNIT_IMPERIAL_LENGTH;
extern NSString *const UNIT_IMPERIAL_LENGTH_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_WEIGHT;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SMALL;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SINGLE;
extern NSString *const UNIT_IMPERIAL_WEIGHT_SINGLE_SHORTHAND;
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

#pragma mark - UI Constants

extern CGFloat const TABLE_SECTION_SPACING;
extern CGFloat const TABLE_HEIGHT_FOOTER;
extern CGFloat const TABLE_HEIGHT_HEADER;
extern CGFloat const TABLE_HEIGHT_WEATHER_CELL;
extern NSInteger const GALLERY_CELL_SPACING;
extern NSInteger const TABLE_THUMB_SIZE;

extern CGFloat const SEARCH_BAR_HEIGHT;
extern CGFloat const SPACING_NORMAL;

#pragma mark - Math Constants

extern NSInteger const OUNCES_PER_POUND;

#pragma mark - Errors

extern NSString *const ERROR_INVALID_FILE;
extern NSString *const ERROR_FILE_NOT_FOUND;
extern NSString *const ERROR_JSON_PARSE;
extern NSString *const ERROR_JSON_READ;
extern NSString *const ERROR_USER_DEFINE_DELETE;

#endif
