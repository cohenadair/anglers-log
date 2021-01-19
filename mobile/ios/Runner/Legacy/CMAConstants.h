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

#endif
