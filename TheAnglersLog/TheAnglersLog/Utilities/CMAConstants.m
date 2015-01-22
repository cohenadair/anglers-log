//
//  CMAConstants.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAConstants.h"

NSString *const APP_NAME = @"My Fishing Journal";

#pragma mark - User Define Name (UDN)

NSString *const UDN_SPECIES = @"Species";
NSString *const UDN_BAITS = @"Baits";
NSString *const UDN_LOCATIONS = @"Locations";
NSString *const UDN_FISHING_METHODS = @"Fishing Methods";
NSString *const UDN_WATER_CLARITIES = @"Water Clarities";

#pragma mark - Core Data Entities (CDE)

NSString *const CDE_JOURNAL = @"CMAJournal";
NSString *const CDE_ENTRY = @"CMAEntry";
NSString *const CDE_USER_DEFINE = @"CMAUserDefine";
NSString *const CDE_SPECIES = @"CMASpecies";
NSString *const CDE_BAIT = @"CMABait";
NSString *const CDE_LOCATION = @"CMALocation";
NSString *const CDE_FISHING_METHOD = @"CMAFishingMethod";
NSString *const CDE_WATER_CLARITY = @"CMAWaterClarity";
NSString *const CDE_WEATHER_DATA = @"CMAWeatherData";
NSString *const CDE_FISHING_SPOT = @"CMAFishingSPot";

NSString *const TOKEN_FISHING_METHODS = @", ";
NSString *const TOKEN_LOCATION = @": ";

NSString *const ARCHIVE_FILE_NAME = @"journal.db";

NSString *const SHARE_MESSAGE = @"Shared with #MyFishingJournal app.";
NSString *const REMOVED_TEXT = @"Removed By User";

NSString *const GLOBAL_FONT = @"HelveticaNeue";

CGFloat const TABLE_SECTION_SPACING = 20.0f;

NSString *const UNIT_IMPERIAL_LENGTH = @"Inches";
NSString *const UNIT_IMPERIAL_LENGTH_SHORTHAND = @"\"";
NSString *const UNIT_IMPERIAL_WEIGHT = @"Pounds";
NSString *const UNIT_IMPERIAL_WEIGHT_SHORTHAND = @" lbs.";
NSString *const UNIT_IMPERIAL_WEIGHT_SMALL = @"Ounces";
NSString *const UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND = @" oz.";
NSString *const UNIT_IMPERIAL_DEPTH = @"Feet";
NSString *const UNIT_IMPERIAL_DEPTH_SHORTHAND = @" ft.";
NSString *const UNIT_IMPERIAL_TEMPERATURE = @"Ferinheight";
NSString *const UNIT_IMPERIAL_TEMPERATURE_SHORTHAND = @"\u00B0 F";
NSString *const UNIT_IMPERIAL_SPEED = @"Miles Per Hour";
NSString *const UNIT_IMPERIAL_SPEED_SHORTHAND = @"mph";

NSString *const UNIT_METRIC_LENGTH = @"Centimeters";
NSString *const UNIT_METRIC_LENGTH_SHORTHAND = @" cm";
NSString *const UNIT_METRIC_WEIGHT = @"Kilograms";
NSString *const UNIT_METRIC_WEIGHT_SHORTHAND = @" kg";
NSString *const UNIT_METRIC_DEPTH = @"Meters";
NSString *const UNIT_METRIC_DEPTH_SHORTHAND = @" m";
NSString *const UNIT_METRIC_TEMPERATURE = @"Celsius";
NSString *const UNIT_METRIC_TEMPERATURE_SHORTHAND = @"\u00B0 C";
NSString *const UNIT_METRIC_SPEED = @"Kilometers Per Hour";
NSString *const UNIT_METRIC_SPEED_SHORTHAND = @" km/h";

NSString *const NOTIFICATION_CHANGE_JOURNAL = @"OnJournalChangeNotification";
