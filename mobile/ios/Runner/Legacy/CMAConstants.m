//
//  CMAConstants.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAConstants.h"

#pragma mark - Date Formats

NSString *const DATE_FILE_STRING = @"MM-dd-yyyy_h-mm_a";
NSString *const ACCURATE_DATE_FILE_STRING = @"MM-dd-yyyy_h-mm_a_ss.SSS";

NSString *const DISPLAY_DATE_FORMAT = @"MMM dd, yyyy 'at' h:mm a";

#pragma mark - Application Constants

NSString *const APP_NAME        = @"Anglers' Log";
NSString *const APP_STORE_LINK  = @"itms-apps://itunes.apple.com/app/id959989008";
NSString *const FAQ_LINK        = @"https://anglerslog.ca/";
NSString *const SHARE_MESSAGE   = @"#AnglersLogApp";
NSString *const HASHTAG_TEXT    = @"AnglersLogApp";
NSString *const GLOBAL_FONT     = @"HelveticaNeue";
NSInteger const MODEL_VERSION   = 4;

#pragma mark - File Name Constants

NSString *const PNG = @".png";
NSString *const JPG = @".jpg";

#pragma mark - User Define Name (UDN)

NSString *const UDN_SPECIES         = @"Species";
NSString *const UDN_BAITS           = @"Baits";
NSString *const UDN_LOCATIONS       = @"Locations";
NSString *const UDN_FISHING_METHODS = @"Fishing Methods";
NSString *const UDN_WATER_CLARITIES = @"Water Clarities";

#pragma mark - Core Data Entities (CDE)

NSString *const CDE_JOURNAL         = @"CMAJournal";
NSString *const CDE_ENTRY           = @"CMAEntry";
NSString *const CDE_USER_DEFINE     = @"CMAUserDefine";
NSString *const CDE_SPECIES         = @"CMASpecies";
NSString *const CDE_BAIT            = @"CMABait";
NSString *const CDE_LOCATION        = @"CMALocation";
NSString *const CDE_FISHING_METHOD  = @"CMAFishingMethod";
NSString *const CDE_WATER_CLARITY   = @"CMAWaterClarity";
NSString *const CDE_WEATHER_DATA    = @"CMAWeatherData";
NSString *const CDE_FISHING_SPOT    = @"CMAFishingSpot";
NSString *const CDE_IMAGE           = @"CMAImage";

#pragma mark - Token Separators

NSString *const TOKEN_FISHING_METHODS = @", ";
NSString *const TOKEN_LOCATION = @": ";

#pragma mark - Unit Constants

NSString *const UNIT_IMPERIAL_LENGTH                    = @"Inches";
NSString *const UNIT_IMPERIAL_LENGTH_SHORTHAND          = @"\"";
NSString *const UNIT_IMPERIAL_WEIGHT                    = @"Pounds";
NSString *const UNIT_IMPERIAL_WEIGHT_SHORTHAND          = @" lbs.";
NSString *const UNIT_IMPERIAL_WEIGHT_SMALL              = @"Ounces";
NSString *const UNIT_IMPERIAL_WEIGHT_SMALL_SHORTHAND    = @" oz.";
NSString *const UNIT_IMPERIAL_WEIGHT_SINGLE             = @"Pound";
NSString *const UNIT_IMPERIAL_WEIGHT_SINGLE_SHORTHAND   = @" lb.";
NSString *const UNIT_IMPERIAL_DEPTH                     = @"Feet";
NSString *const UNIT_IMPERIAL_DEPTH_SHORTHAND           = @" ft.";
NSString *const UNIT_IMPERIAL_TEMPERATURE               = @"Ferinheight";
NSString *const UNIT_IMPERIAL_TEMPERATURE_SHORTHAND     = @"\u00B0F";
NSString *const UNIT_IMPERIAL_SPEED                     = @"Miles Per Hour";
NSString *const UNIT_IMPERIAL_SPEED_SHORTHAND           = @"mph";

NSString *const UNIT_METRIC_LENGTH                      = @"Centimeters";
NSString *const UNIT_METRIC_LENGTH_SHORTHAND            = @" cm";
NSString *const UNIT_METRIC_WEIGHT                      = @"Kilograms";
NSString *const UNIT_METRIC_WEIGHT_SHORTHAND            = @" kg";
NSString *const UNIT_METRIC_DEPTH                       = @"Meters";
NSString *const UNIT_METRIC_DEPTH_SHORTHAND             = @" m";
NSString *const UNIT_METRIC_TEMPERATURE                 = @"Celsius";
NSString *const UNIT_METRIC_TEMPERATURE_SHORTHAND       = @"\u00B0C";
NSString *const UNIT_METRIC_SPEED                       = @"Kilometers Per Hour";
NSString *const UNIT_METRIC_SPEED_SHORTHAND             = @"km/h";

#pragma mark - UI Constants

CGFloat const TABLE_SECTION_SPACING     = 20.0f;
CGFloat const TABLE_HEIGHT_FOOTER       = 25.0f;
CGFloat const TABLE_HEIGHT_HEADER       = 40.0f;
CGFloat const TABLE_HEIGHT_WEATHER_CELL = 90.0f;
NSInteger const GALLERY_CELL_SPACING    = 2;
NSInteger const TABLE_THUMB_SIZE        = 50;

CGFloat const SEARCH_BAR_HEIGHT = 54;
CGFloat const SPACING_NORMAL = 16;

#pragma mark - Math Constants

NSInteger const OUNCES_PER_POUND = 16;

#pragma mark - Errors

NSString *const ERROR_INVALID_FILE      = @"1";
NSString *const ERROR_FILE_NOT_FOUND    = @"2";
NSString *const ERROR_JSON_PARSE        = @"3";
NSString *const ERROR_JSON_READ         = @"4"; // Couldn't read JSON file
NSString *const ERROR_USER_DEFINE_DELETE = @"5";



