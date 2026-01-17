import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_en.dart';
import 'localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AnglersLogLocalizations
/// returned by `AnglersLogLocalizations.of(context)`.
///
/// Applications need to include `AnglersLogLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AnglersLogLocalizations.localizationsDelegates,
///   supportedLocales: AnglersLogLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AnglersLogLocalizations.supportedLocales
/// property.
abstract class AnglersLogLocalizations {
  AnglersLogLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AnglersLogLocalizations of(BuildContext context) {
    return Localizations.of<AnglersLogLocalizations>(
      context,
      AnglersLogLocalizations,
    )!;
  }

  static const LocalizationsDelegate<AnglersLogLocalizations> delegate =
      _AnglersLogLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('en', 'US'),
    Locale('es'),
  ];

  /// No description provided for @catchFieldFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get catchFieldFavorite;

  /// No description provided for @catchFieldFavoriteDescription.
  ///
  /// In en, this message translates to:
  /// **'Whether a catch was one of your favourites.'**
  String get catchFieldFavoriteDescription;

  /// No description provided for @saveReportPageFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favourites Only'**
  String get saveReportPageFavorites;

  /// No description provided for @saveReportPageFavoritesFilter.
  ///
  /// In en, this message translates to:
  /// **'Favourites only'**
  String get saveReportPageFavoritesFilter;

  /// No description provided for @unitsPageCentimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimetres ({value})'**
  String unitsPageCentimeters(String value);

  /// No description provided for @unitsPageMeters.
  ///
  /// In en, this message translates to:
  /// **'Metres ({value})'**
  String unitsPageMeters(String value);

  /// No description provided for @unitsPageAirVisibilityKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometres ({value})'**
  String unitsPageAirVisibilityKilometers(String value);

  /// No description provided for @unitsPageWindSpeedKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometres per hour ({value})'**
  String unitsPageWindSpeedKilometers(String value);

  /// No description provided for @unitsPageWindSpeedMeters.
  ///
  /// In en, this message translates to:
  /// **'Metres per second ({value})'**
  String unitsPageWindSpeedMeters(String value);

  /// No description provided for @keywordsSpeedMetric.
  ///
  /// In en, this message translates to:
  /// **'kilometers kilometres per hour speed wind'**
  String get keywordsSpeedMetric;

  /// No description provided for @inputColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get inputColorLabel;

  /// No description provided for @hashtag.
  ///
  /// In en, this message translates to:
  /// **'#AnglersLogApp'**
  String get hashtag;

  /// No description provided for @shareTextAndroid.
  ///
  /// In en, this message translates to:
  /// **'Shared with #AnglersLogApp for Android.'**
  String get shareTextAndroid;

  /// No description provided for @shareTextApple.
  ///
  /// In en, this message translates to:
  /// **'Shared with #AnglersLogApp for iOS.'**
  String get shareTextApple;

  /// No description provided for @shareLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {value}'**
  String shareLength(String value);

  /// No description provided for @shareWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value}'**
  String shareWeight(String value);

  /// No description provided for @shareBait.
  ///
  /// In en, this message translates to:
  /// **'Bait: {value}'**
  String shareBait(String value);

  /// No description provided for @shareBaits.
  ///
  /// In en, this message translates to:
  /// **'Baits: {value}'**
  String shareBaits(String value);

  /// No description provided for @shareCatches.
  ///
  /// In en, this message translates to:
  /// **'Catches: {value}'**
  String shareCatches(int value);

  /// No description provided for @rateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Anglers\'\' Log'**
  String get rateDialogTitle;

  /// No description provided for @rateDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Please take a moment to write a review of Anglers\'\' Log. All feedback is greatly appreciated!'**
  String get rateDialogDescription;

  /// No description provided for @rateDialogRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateDialogRate;

  /// No description provided for @rateDialogLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get rateDialogLater;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @latLng.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}, Lng: {lng}'**
  String latLng(String lat, String lng);

  /// No description provided for @latLngNoLabels.
  ///
  /// In en, this message translates to:
  /// **'{lat}, {lng}'**
  String latLngNoLabels(String lat, String lng);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @numberOfCatches.
  ///
  /// In en, this message translates to:
  /// **'{numOfCatches} Catches'**
  String numberOfCatches(int numOfCatches);

  /// No description provided for @numberOfCatchesSingular.
  ///
  /// In en, this message translates to:
  /// **'1 Catch'**
  String get numberOfCatchesSingular;

  /// No description provided for @unknownSpecies.
  ///
  /// In en, this message translates to:
  /// **'Unknown Species'**
  String get unknownSpecies;

  /// No description provided for @unknownBait.
  ///
  /// In en, this message translates to:
  /// **'Unknown Bait'**
  String get unknownBait;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @fieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeNumber;

  /// No description provided for @fieldTypeBoolean.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get fieldTypeBoolean;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// No description provided for @inputRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'{inputLabel} is required'**
  String inputRequiredMessage(String inputLabel);

  /// No description provided for @inputNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get inputNameLabel;

  /// No description provided for @inputGenericRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get inputGenericRequired;

  /// No description provided for @inputDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get inputDescriptionLabel;

  /// No description provided for @inputNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inputNotesLabel;

  /// No description provided for @inputInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number input'**
  String get inputInvalidNumber;

  /// No description provided for @inputPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get inputPhotoLabel;

  /// No description provided for @inputPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get inputPhotosLabel;

  /// No description provided for @inputNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get inputNotSelected;

  /// No description provided for @inputEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get inputEmailLabel;

  /// No description provided for @inputInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get inputInvalidEmail;

  /// No description provided for @inputAtmosphere.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere and Weather'**
  String get inputAtmosphere;

  /// No description provided for @inputFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get inputFetch;

  /// No description provided for @inputAutoFetch.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetch'**
  String get inputAutoFetch;

  /// No description provided for @inputCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get inputCurrentLocation;

  /// No description provided for @inputGenericFetchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch data at this time. Please ensure your device is connected to the internet and try again.'**
  String get inputGenericFetchError;

  /// No description provided for @fieldWaterClarityLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Clarity'**
  String get fieldWaterClarityLabel;

  /// No description provided for @fieldWaterDepthLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Depth'**
  String get fieldWaterDepthLabel;

  /// No description provided for @fieldWaterTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Temperature'**
  String get fieldWaterTemperatureLabel;

  /// No description provided for @catchListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Catches ({numOfCatches})'**
  String catchListPageTitle(int numOfCatches);

  /// No description provided for @catchListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search catches'**
  String get catchListPageSearchHint;

  /// No description provided for @catchListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Catches'**
  String get catchListPageEmptyListTitle;

  /// No description provided for @catchListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any catches. Tap the %s button to begin.'**
  String get catchListPageEmptyListDescription;

  /// No description provided for @catchListItemLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {value}'**
  String catchListItemLength(String value);

  /// No description provided for @catchListItemWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value}'**
  String catchListItemWeight(String value);

  /// No description provided for @catchListItemNotSet.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get catchListItemNotSet;

  /// No description provided for @catchPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete catch {value}? This cannot be undone.'**
  String catchPageDeleteMessage(String value);

  /// No description provided for @catchPageDeleteWithTripMessage.
  ///
  /// In en, this message translates to:
  /// **'{value} is associated with a trip; Are you sure you want to delete it? This cannot be undone.'**
  String catchPageDeleteWithTripMessage(String value);

  /// No description provided for @catchPageReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get catchPageReleased;

  /// No description provided for @catchPageKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get catchPageKept;

  /// No description provided for @catchPageQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {value}'**
  String catchPageQuantityLabel(int value);

  /// No description provided for @saveCatchPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Catch'**
  String get saveCatchPageNewTitle;

  /// No description provided for @saveCatchPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Catch'**
  String get saveCatchPageEditTitle;

  /// No description provided for @catchFieldTide.
  ///
  /// In en, this message translates to:
  /// **'Tide'**
  String get catchFieldTide;

  /// No description provided for @catchFieldDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get catchFieldDateTime;

  /// No description provided for @catchFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get catchFieldDate;

  /// No description provided for @catchFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get catchFieldTime;

  /// No description provided for @catchFieldPeriod.
  ///
  /// In en, this message translates to:
  /// **'Time of Day'**
  String get catchFieldPeriod;

  /// No description provided for @catchFieldPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Such as dawn, morning, dusk, etc.'**
  String get catchFieldPeriodDescription;

  /// No description provided for @catchFieldSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get catchFieldSeason;

  /// No description provided for @catchFieldSeasonDescription.
  ///
  /// In en, this message translates to:
  /// **'Winter, spring, summer, or autumn.'**
  String get catchFieldSeasonDescription;

  /// No description provided for @catchFieldImages.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get catchFieldImages;

  /// No description provided for @catchFieldFishingSpot.
  ///
  /// In en, this message translates to:
  /// **'Fishing Spot'**
  String get catchFieldFishingSpot;

  /// No description provided for @catchFieldFishingSpotDescription.
  ///
  /// In en, this message translates to:
  /// **'Coordinates of where a catch was made.'**
  String get catchFieldFishingSpotDescription;

  /// No description provided for @catchFieldBait.
  ///
  /// In en, this message translates to:
  /// **'Bait'**
  String get catchFieldBait;

  /// No description provided for @catchFieldAngler.
  ///
  /// In en, this message translates to:
  /// **'Angler'**
  String get catchFieldAngler;

  /// No description provided for @catchFieldGear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get catchFieldGear;

  /// No description provided for @catchFieldMethodsDescription.
  ///
  /// In en, this message translates to:
  /// **'The way in which a catch was made.'**
  String get catchFieldMethodsDescription;

  /// No description provided for @catchFieldNoMethods.
  ///
  /// In en, this message translates to:
  /// **'No fishing methods'**
  String get catchFieldNoMethods;

  /// No description provided for @catchFieldNoBaits.
  ///
  /// In en, this message translates to:
  /// **'No baits'**
  String get catchFieldNoBaits;

  /// No description provided for @catchFieldNoGear.
  ///
  /// In en, this message translates to:
  /// **'No gear'**
  String get catchFieldNoGear;

  /// No description provided for @catchFieldCatchAndRelease.
  ///
  /// In en, this message translates to:
  /// **'Catch and Release'**
  String get catchFieldCatchAndRelease;

  /// No description provided for @catchFieldCatchAndReleaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Whether or not this catch was released.'**
  String get catchFieldCatchAndReleaseDescription;

  /// No description provided for @catchFieldTideHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Tide Height'**
  String get catchFieldTideHeightLabel;

  /// No description provided for @catchFieldLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get catchFieldLengthLabel;

  /// No description provided for @catchFieldWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get catchFieldWeightLabel;

  /// No description provided for @catchFieldQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get catchFieldQuantityLabel;

  /// No description provided for @catchFieldQuantityDescription.
  ///
  /// In en, this message translates to:
  /// **'The number of the selected species caught.'**
  String get catchFieldQuantityDescription;

  /// No description provided for @catchFieldNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get catchFieldNotesLabel;

  /// No description provided for @saveReportPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get saveReportPageNewTitle;

  /// No description provided for @saveReportPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get saveReportPageEditTitle;

  /// No description provided for @saveReportPageNameExists.
  ///
  /// In en, this message translates to:
  /// **'Report name already exists'**
  String get saveReportPageNameExists;

  /// No description provided for @saveReportPageTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get saveReportPageTypeTitle;

  /// No description provided for @saveReportPageComparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get saveReportPageComparison;

  /// No description provided for @saveReportPageSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get saveReportPageSummary;

  /// No description provided for @saveReportPageStartDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get saveReportPageStartDateRangeLabel;

  /// No description provided for @saveReportPageEndDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get saveReportPageEndDateRangeLabel;

  /// No description provided for @saveReportPageAllAnglers.
  ///
  /// In en, this message translates to:
  /// **'All anglers'**
  String get saveReportPageAllAnglers;

  /// No description provided for @saveReportPageAllWaterClarities.
  ///
  /// In en, this message translates to:
  /// **'All water clarities'**
  String get saveReportPageAllWaterClarities;

  /// No description provided for @saveReportPageAllSpecies.
  ///
  /// In en, this message translates to:
  /// **'All species'**
  String get saveReportPageAllSpecies;

  /// No description provided for @saveReportPageAllBaits.
  ///
  /// In en, this message translates to:
  /// **'All baits'**
  String get saveReportPageAllBaits;

  /// No description provided for @saveReportPageAllGear.
  ///
  /// In en, this message translates to:
  /// **'All gear'**
  String get saveReportPageAllGear;

  /// No description provided for @saveReportPageAllBodiesOfWater.
  ///
  /// In en, this message translates to:
  /// **'All bodies of water'**
  String get saveReportPageAllBodiesOfWater;

  /// No description provided for @saveReportPageAllFishingSpots.
  ///
  /// In en, this message translates to:
  /// **'All fishing spots'**
  String get saveReportPageAllFishingSpots;

  /// No description provided for @saveReportPageAllMethods.
  ///
  /// In en, this message translates to:
  /// **'All fishing methods'**
  String get saveReportPageAllMethods;

  /// No description provided for @saveReportPageCatchAndRelease.
  ///
  /// In en, this message translates to:
  /// **'Catch and Release Only'**
  String get saveReportPageCatchAndRelease;

  /// No description provided for @saveReportPageCatchAndReleaseFilter.
  ///
  /// In en, this message translates to:
  /// **'Catch and release only'**
  String get saveReportPageCatchAndReleaseFilter;

  /// No description provided for @saveReportPageAllWindDirections.
  ///
  /// In en, this message translates to:
  /// **'All wind directions'**
  String get saveReportPageAllWindDirections;

  /// No description provided for @saveReportPageAllSkyConditions.
  ///
  /// In en, this message translates to:
  /// **'All sky conditions'**
  String get saveReportPageAllSkyConditions;

  /// No description provided for @saveReportPageAllMoonPhases.
  ///
  /// In en, this message translates to:
  /// **'All moon phases'**
  String get saveReportPageAllMoonPhases;

  /// No description provided for @saveReportPageAllTideTypes.
  ///
  /// In en, this message translates to:
  /// **'All tides'**
  String get saveReportPageAllTideTypes;

  /// No description provided for @photosPageMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosPageMenuLabel;

  /// No description provided for @photosPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos ({numOfPhotos})'**
  String photosPageTitle(int numOfPhotos);

  /// No description provided for @photosPageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Photos'**
  String get photosPageEmptyTitle;

  /// No description provided for @photosPageEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'All photos attached to catches will be displayed here. To add a catch, tap the %s icon.'**
  String get photosPageEmptyDescription;

  /// No description provided for @baitListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Baits ({numOfBaits})'**
  String baitListPageTitle(int numOfBaits);

  /// No description provided for @baitListPageOtherCategory.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get baitListPageOtherCategory;

  /// No description provided for @baitListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search baits'**
  String get baitListPageSearchHint;

  /// No description provided for @baitListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{bait} is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String baitListPageDeleteMessage(String bait, int numOfCatches);

  /// No description provided for @baitListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{bait} is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String baitListPageDeleteMessageSingular(String bait);

  /// No description provided for @baitListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Baits'**
  String get baitListPageEmptyListTitle;

  /// No description provided for @baitListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any baits. Tap the %s button to begin.'**
  String get baitListPageEmptyListDescription;

  /// No description provided for @baitsSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When baits are added to your log, a summary of their catches will be shown here.'**
  String get baitsSummaryEmpty;

  /// No description provided for @baitListPageVariantsLabel.
  ///
  /// In en, this message translates to:
  /// **'{numOfVariants} Variants'**
  String baitListPageVariantsLabel(int numOfVariants);

  /// No description provided for @baitListPageVariantLabel.
  ///
  /// In en, this message translates to:
  /// **'1 Variant'**
  String get baitListPageVariantLabel;

  /// No description provided for @saveBaitPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Bait'**
  String get saveBaitPageNewTitle;

  /// No description provided for @saveBaitPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bait'**
  String get saveBaitPageEditTitle;

  /// No description provided for @saveBaitPageCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Bait Category'**
  String get saveBaitPageCategoryLabel;

  /// No description provided for @saveBaitPageBaitExists.
  ///
  /// In en, this message translates to:
  /// **'A bait with these properties already exists. Please change at least one field and try again.'**
  String get saveBaitPageBaitExists;

  /// No description provided for @saveBaitPageVariants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get saveBaitPageVariants;

  /// No description provided for @saveBaitPageDeleteVariantSingular.
  ///
  /// In en, this message translates to:
  /// **'This variant is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String get saveBaitPageDeleteVariantSingular;

  /// No description provided for @saveBaitPageDeleteVariantPlural.
  ///
  /// In en, this message translates to:
  /// **'This variant is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String saveBaitPageDeleteVariantPlural(int numOfCatches);

  /// No description provided for @saveBaitCategoryPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Bait Category'**
  String get saveBaitCategoryPageNewTitle;

  /// No description provided for @saveBaitCategoryPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bait Category'**
  String get saveBaitCategoryPageEditTitle;

  /// No description provided for @saveBaitCategoryPageExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'Bait category already exists'**
  String get saveBaitCategoryPageExistsMessage;

  /// No description provided for @baitCategoryListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Bait Categories ({numOfCategories})'**
  String baitCategoryListPageTitle(int numOfCategories);

  /// No description provided for @baitCategoryListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{bait} is associated with {numOfBaits} baits; are you sure you want to delete it? This cannot be undone.'**
  String baitCategoryListPageDeleteMessage(String bait, int numOfBaits);

  /// No description provided for @baitCategoryListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{category} is associated with 1 bait; are you sure you want to delete it? This cannot be undone.'**
  String baitCategoryListPageDeleteMessageSingular(String category);

  /// No description provided for @baitCategoryListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search bait categories'**
  String get baitCategoryListPageSearchHint;

  /// No description provided for @baitCategoryListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bait Categories'**
  String get baitCategoryListPageEmptyListTitle;

  /// No description provided for @baitCategoryListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any bait categories. Tap the %s button to begin.'**
  String get baitCategoryListPageEmptyListDescription;

  /// No description provided for @saveAnglerPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Angler'**
  String get saveAnglerPageNewTitle;

  /// No description provided for @saveAnglerPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Angler'**
  String get saveAnglerPageEditTitle;

  /// No description provided for @saveAnglerPageExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'Angler already exists'**
  String get saveAnglerPageExistsMessage;

  /// No description provided for @anglerListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Anglers ({numOfAnglers})'**
  String anglerListPageTitle(int numOfAnglers);

  /// No description provided for @anglerListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{angler} is associated with {numOfCatches} catches; are you sure you want to delete them? This cannot be undone.'**
  String anglerListPageDeleteMessage(String angler, int numOfCatches);

  /// No description provided for @anglerListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{angler} is associated with 1 catch; are you sure you want to delete them? This cannot be undone.'**
  String anglerListPageDeleteMessageSingular(String angler);

  /// No description provided for @anglerListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search anglers'**
  String get anglerListPageSearchHint;

  /// No description provided for @anglerListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Anglers'**
  String get anglerListPageEmptyListTitle;

  /// No description provided for @anglerListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any anglers. Tap the %s button to begin.'**
  String get anglerListPageEmptyListDescription;

  /// No description provided for @anglersSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When anglers are added to your log, a summary of their catches will be shown here.'**
  String get anglersSummaryEmpty;

  /// No description provided for @saveMethodPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Fishing Method'**
  String get saveMethodPageNewTitle;

  /// No description provided for @saveMethodPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Fishing Method'**
  String get saveMethodPageEditTitle;

  /// No description provided for @saveMethodPageExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'Fishing method already exists'**
  String get saveMethodPageExistsMessage;

  /// No description provided for @methodListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Fishing Methods ({numOfMethods})'**
  String methodListPageTitle(int numOfMethods);

  /// No description provided for @methodListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{method} is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String methodListPageDeleteMessage(String method, int numOfCatches);

  /// No description provided for @methodListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{method} is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String methodListPageDeleteMessageSingular(String method);

  /// No description provided for @methodListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fishing methods'**
  String get methodListPageSearchHint;

  /// No description provided for @methodListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Fishing Methods'**
  String get methodListPageEmptyListTitle;

  /// No description provided for @methodListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any fishing methods. Tap the %s button to begin.'**
  String get methodListPageEmptyListDescription;

  /// No description provided for @methodSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When fishing methods are added to your log, a summary of their catches will be shown here.'**
  String get methodSummaryEmpty;

  /// No description provided for @saveWaterClarityPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Water Clarity'**
  String get saveWaterClarityPageNewTitle;

  /// No description provided for @saveWaterClarityPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Water Clarity'**
  String get saveWaterClarityPageEditTitle;

  /// No description provided for @saveWaterClarityPageExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'Water Clarity already exists'**
  String get saveWaterClarityPageExistsMessage;

  /// No description provided for @waterClarityListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Clarities ({numOfClarities})'**
  String waterClarityListPageTitle(int numOfClarities);

  /// No description provided for @waterClarityListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{clarity} is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String waterClarityListPageDeleteMessage(String clarity, int numOfCatches);

  /// No description provided for @waterClarityListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{clarity} is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String waterClarityListPageDeleteMessageSingular(String clarity);

  /// No description provided for @waterClarityListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search water clarities'**
  String get waterClarityListPageSearchHint;

  /// No description provided for @waterClarityListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Water Clarities'**
  String get waterClarityListPageEmptyListTitle;

  /// No description provided for @waterClarityListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any water clarities. Tap the %s button to begin.'**
  String get waterClarityListPageEmptyListDescription;

  /// No description provided for @waterClaritiesSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When water clarities are added to your log, a summary of their catches will be shown here.'**
  String get waterClaritiesSummaryEmpty;

  /// No description provided for @statsPageMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsPageMenuTitle;

  /// No description provided for @statsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsPageTitle;

  /// No description provided for @statsPageNewReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get statsPageNewReport;

  /// No description provided for @statsPageSpeciesSummary.
  ///
  /// In en, this message translates to:
  /// **'Species Summary'**
  String get statsPageSpeciesSummary;

  /// No description provided for @statsPageCatchSummary.
  ///
  /// In en, this message translates to:
  /// **'Catch Summary'**
  String get statsPageCatchSummary;

  /// No description provided for @statsPageAnglerSummary.
  ///
  /// In en, this message translates to:
  /// **'Angler Summary'**
  String get statsPageAnglerSummary;

  /// No description provided for @statsPageBaitSummary.
  ///
  /// In en, this message translates to:
  /// **'Bait Summary'**
  String get statsPageBaitSummary;

  /// No description provided for @statsPageBaitVariantAllLabel.
  ///
  /// In en, this message translates to:
  /// **'{bait} (All Variants)'**
  String statsPageBaitVariantAllLabel(String bait);

  /// No description provided for @statsPageBodyOfWaterSummary.
  ///
  /// In en, this message translates to:
  /// **'Body of Water Summary'**
  String get statsPageBodyOfWaterSummary;

  /// No description provided for @statsPageFishingSpotSummary.
  ///
  /// In en, this message translates to:
  /// **'Fishing Spot Summary'**
  String get statsPageFishingSpotSummary;

  /// No description provided for @statsPageMethodSummary.
  ///
  /// In en, this message translates to:
  /// **'Fishing Method Summary'**
  String get statsPageMethodSummary;

  /// No description provided for @statsPageMoonPhaseSummary.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase Summary'**
  String get statsPageMoonPhaseSummary;

  /// No description provided for @statsPagePeriodSummary.
  ///
  /// In en, this message translates to:
  /// **'Time of Day Summary'**
  String get statsPagePeriodSummary;

  /// No description provided for @statsPageSeasonSummary.
  ///
  /// In en, this message translates to:
  /// **'Season Summary'**
  String get statsPageSeasonSummary;

  /// No description provided for @statsPageTideSummary.
  ///
  /// In en, this message translates to:
  /// **'Tide Summary'**
  String get statsPageTideSummary;

  /// No description provided for @statsPageWaterClaritySummary.
  ///
  /// In en, this message translates to:
  /// **'Water Clarity Summary'**
  String get statsPageWaterClaritySummary;

  /// No description provided for @statsPageGearSummary.
  ///
  /// In en, this message translates to:
  /// **'Gear Summary'**
  String get statsPageGearSummary;

  /// No description provided for @statsPagePersonalBests.
  ///
  /// In en, this message translates to:
  /// **'Personal Bests'**
  String get statsPagePersonalBests;

  /// No description provided for @personalBestsTrip.
  ///
  /// In en, this message translates to:
  /// **'Best Trip'**
  String get personalBestsTrip;

  /// No description provided for @personalBestsLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get personalBestsLongest;

  /// No description provided for @personalBestsHeaviest.
  ///
  /// In en, this message translates to:
  /// **'Heaviest'**
  String get personalBestsHeaviest;

  /// No description provided for @personalBestsSpeciesByLength.
  ///
  /// In en, this message translates to:
  /// **'Species By Length'**
  String get personalBestsSpeciesByLength;

  /// No description provided for @personalBestsSpeciesByLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get personalBestsSpeciesByLengthLabel;

  /// No description provided for @personalBestsSpeciesByWeight.
  ///
  /// In en, this message translates to:
  /// **'Species By Weight'**
  String get personalBestsSpeciesByWeight;

  /// No description provided for @personalBestsSpeciesByWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Heaviest'**
  String get personalBestsSpeciesByWeightLabel;

  /// No description provided for @personalBestsShowAllSpecies.
  ///
  /// In en, this message translates to:
  /// **'View all species'**
  String get personalBestsShowAllSpecies;

  /// No description provided for @personalBestsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get personalBestsAverage;

  /// No description provided for @personalBestsNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get personalBestsNoDataTitle;

  /// No description provided for @personalBestsNoDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Cannot determine your personal bests for the selected date range. Ensure you’ve added a trip, or added a catch with a length or weight value.'**
  String get personalBestsNoDataDescription;

  /// No description provided for @reportViewEmptyLog.
  ///
  /// In en, this message translates to:
  /// **'Empty Log'**
  String get reportViewEmptyLog;

  /// No description provided for @reportViewEmptyLogDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any catches. To add a catch, tap the %s icon.'**
  String get reportViewEmptyLogDescription;

  /// No description provided for @reportViewNoCatches.
  ///
  /// In en, this message translates to:
  /// **'No catches found'**
  String get reportViewNoCatches;

  /// No description provided for @reportViewNoCatchesDescription.
  ///
  /// In en, this message translates to:
  /// **'No catches found in the selected date range.'**
  String get reportViewNoCatchesDescription;

  /// No description provided for @reportViewNoCatchesReportDescription.
  ///
  /// In en, this message translates to:
  /// **'No catches found in the selected report\'\'s date range.'**
  String get reportViewNoCatchesReportDescription;

  /// No description provided for @reportSummaryCatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Catch Summary'**
  String get reportSummaryCatchTitle;

  /// No description provided for @reportSummaryPerSpecies.
  ///
  /// In en, this message translates to:
  /// **'Per Species'**
  String get reportSummaryPerSpecies;

  /// No description provided for @reportSummaryPerFishingSpot.
  ///
  /// In en, this message translates to:
  /// **'Per Fishing Spot'**
  String get reportSummaryPerFishingSpot;

  /// No description provided for @reportSummaryPerBait.
  ///
  /// In en, this message translates to:
  /// **'Per Bait'**
  String get reportSummaryPerBait;

  /// No description provided for @reportSummaryPerAngler.
  ///
  /// In en, this message translates to:
  /// **'Per Angler'**
  String get reportSummaryPerAngler;

  /// No description provided for @reportSummaryPerBodyOfWater.
  ///
  /// In en, this message translates to:
  /// **'Per Body of Water'**
  String get reportSummaryPerBodyOfWater;

  /// No description provided for @reportSummaryPerMethod.
  ///
  /// In en, this message translates to:
  /// **'Per Fishing Method'**
  String get reportSummaryPerMethod;

  /// No description provided for @reportSummaryPerMoonPhase.
  ///
  /// In en, this message translates to:
  /// **'Per Moon Phase'**
  String get reportSummaryPerMoonPhase;

  /// No description provided for @reportSummaryPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Per Time of Day'**
  String get reportSummaryPerPeriod;

  /// No description provided for @reportSummaryPerSeason.
  ///
  /// In en, this message translates to:
  /// **'Per Season'**
  String get reportSummaryPerSeason;

  /// No description provided for @reportSummaryPerTideType.
  ///
  /// In en, this message translates to:
  /// **'Per Tide'**
  String get reportSummaryPerTideType;

  /// No description provided for @reportSummaryPerWaterClarity.
  ///
  /// In en, this message translates to:
  /// **'Per Water Clarity'**
  String get reportSummaryPerWaterClarity;

  /// No description provided for @reportSummarySinceLastCatch.
  ///
  /// In en, this message translates to:
  /// **'Since Last Catch'**
  String get reportSummarySinceLastCatch;

  /// No description provided for @reportSummaryNumberOfCatches.
  ///
  /// In en, this message translates to:
  /// **'Number of catches'**
  String get reportSummaryNumberOfCatches;

  /// No description provided for @reportSummaryFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get reportSummaryFilters;

  /// No description provided for @reportSummaryViewSpecies.
  ///
  /// In en, this message translates to:
  /// **'View all species'**
  String get reportSummaryViewSpecies;

  /// No description provided for @reportSummaryPerSpeciesDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per species.'**
  String get reportSummaryPerSpeciesDescription;

  /// No description provided for @reportSummaryViewFishingSpots.
  ///
  /// In en, this message translates to:
  /// **'View all fishing spots'**
  String get reportSummaryViewFishingSpots;

  /// No description provided for @reportSummaryPerFishingSpotDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per fishing spot.'**
  String get reportSummaryPerFishingSpotDescription;

  /// No description provided for @reportSummaryViewBaits.
  ///
  /// In en, this message translates to:
  /// **'View all baits'**
  String get reportSummaryViewBaits;

  /// No description provided for @reportSummaryPerBaitDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per bait.'**
  String get reportSummaryPerBaitDescription;

  /// No description provided for @reportSummaryViewMoonPhases.
  ///
  /// In en, this message translates to:
  /// **'View all moon phases'**
  String get reportSummaryViewMoonPhases;

  /// No description provided for @reportSummaryPerMoonPhaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per moon phase.'**
  String get reportSummaryPerMoonPhaseDescription;

  /// No description provided for @reportSummaryViewTides.
  ///
  /// In en, this message translates to:
  /// **'View all tide types'**
  String get reportSummaryViewTides;

  /// No description provided for @reportSummaryPerTideDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per tide type.'**
  String get reportSummaryPerTideDescription;

  /// No description provided for @reportSummaryViewAnglers.
  ///
  /// In en, this message translates to:
  /// **'View all anglers'**
  String get reportSummaryViewAnglers;

  /// No description provided for @reportSummaryPerAnglerDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per angler.'**
  String get reportSummaryPerAnglerDescription;

  /// No description provided for @reportSummaryViewBodiesOfWater.
  ///
  /// In en, this message translates to:
  /// **'View all bodies of water'**
  String get reportSummaryViewBodiesOfWater;

  /// No description provided for @reportSummaryPerBodyOfWaterDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per body of water.'**
  String get reportSummaryPerBodyOfWaterDescription;

  /// No description provided for @reportSummaryViewMethods.
  ///
  /// In en, this message translates to:
  /// **'View all fishing methods'**
  String get reportSummaryViewMethods;

  /// No description provided for @reportSummaryPerMethodDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per fishing method.'**
  String get reportSummaryPerMethodDescription;

  /// No description provided for @reportSummaryViewPeriods.
  ///
  /// In en, this message translates to:
  /// **'View all times of day'**
  String get reportSummaryViewPeriods;

  /// No description provided for @reportSummaryPerPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per time of day.'**
  String get reportSummaryPerPeriodDescription;

  /// No description provided for @reportSummaryViewSeasons.
  ///
  /// In en, this message translates to:
  /// **'View all seasons'**
  String get reportSummaryViewSeasons;

  /// No description provided for @reportSummaryPerSeasonDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per season.'**
  String get reportSummaryPerSeasonDescription;

  /// No description provided for @reportSummaryViewWaterClarities.
  ///
  /// In en, this message translates to:
  /// **'View all water clarities'**
  String get reportSummaryViewWaterClarities;

  /// No description provided for @reportSummaryPerWaterClarityDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per water clarity.'**
  String get reportSummaryPerWaterClarityDescription;

  /// No description provided for @reportSummaryPerHour.
  ///
  /// In en, this message translates to:
  /// **'Per Hour'**
  String get reportSummaryPerHour;

  /// No description provided for @reportSummaryViewAllHours.
  ///
  /// In en, this message translates to:
  /// **'View all hours'**
  String get reportSummaryViewAllHours;

  /// No description provided for @reportSummaryViewAllHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches for each hour in the day.'**
  String get reportSummaryViewAllHoursDescription;

  /// No description provided for @reportSummaryPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per Month'**
  String get reportSummaryPerMonth;

  /// No description provided for @reportSummaryViewAllMonths.
  ///
  /// In en, this message translates to:
  /// **'View all months'**
  String get reportSummaryViewAllMonths;

  /// No description provided for @reportSummaryViewAllMonthsDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches for each month in the year.'**
  String get reportSummaryViewAllMonthsDescription;

  /// No description provided for @reportSummaryPerGear.
  ///
  /// In en, this message translates to:
  /// **'Per Gear'**
  String get reportSummaryPerGear;

  /// No description provided for @reportSummaryViewGear.
  ///
  /// In en, this message translates to:
  /// **'View all gear'**
  String get reportSummaryViewGear;

  /// No description provided for @reportSummaryPerGearDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewing number of catches per gear.'**
  String get reportSummaryPerGearDescription;

  /// No description provided for @morePageTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get morePageTitle;

  /// No description provided for @morePageRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Anglers\'\' Log'**
  String get morePageRateApp;

  /// No description provided for @morePagePro.
  ///
  /// In en, this message translates to:
  /// **'Anglers\'\' Log Pro'**
  String get morePagePro;

  /// No description provided for @morePageRateErrorApple.
  ///
  /// In en, this message translates to:
  /// **'Device does not have App Store installed.'**
  String get morePageRateErrorApple;

  /// No description provided for @morePageRateErrorAndroid.
  ///
  /// In en, this message translates to:
  /// **'Device has no web browser app installed.'**
  String get morePageRateErrorAndroid;

  /// No description provided for @tripListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips ({numOfTrips})'**
  String tripListPageTitle(int numOfTrips);

  /// No description provided for @tripListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trips'**
  String get tripListPageSearchHint;

  /// No description provided for @tripListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Trips'**
  String get tripListPageEmptyListTitle;

  /// No description provided for @tripListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any trips. Tap the %s button to begin.'**
  String get tripListPageEmptyListDescription;

  /// No description provided for @tripListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete trip {trip}? This cannot be undone.'**
  String tripListPageDeleteMessage(String trip);

  /// No description provided for @saveTripPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Trip'**
  String get saveTripPageEditTitle;

  /// No description provided for @saveTripPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Trip'**
  String get saveTripPageNewTitle;

  /// No description provided for @saveTripPageAutoSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-set Fields'**
  String get saveTripPageAutoSetTitle;

  /// No description provided for @saveTripPageAutoSetDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically set applicable fields when catches are selected.'**
  String get saveTripPageAutoSetDescription;

  /// No description provided for @saveTripPageStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get saveTripPageStartDate;

  /// No description provided for @saveTripPageStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get saveTripPageStartTime;

  /// No description provided for @saveTripPageStartDateTime.
  ///
  /// In en, this message translates to:
  /// **'Start Date and Time'**
  String get saveTripPageStartDateTime;

  /// No description provided for @saveTripPageEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get saveTripPageEndDate;

  /// No description provided for @saveTripPageEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get saveTripPageEndTime;

  /// No description provided for @saveTripPageEndDateTime.
  ///
  /// In en, this message translates to:
  /// **'End Date and Time'**
  String get saveTripPageEndDateTime;

  /// No description provided for @saveTripPageAllDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get saveTripPageAllDay;

  /// No description provided for @saveTripPageCatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Trophies logged on this trip.'**
  String get saveTripPageCatchesDesc;

  /// No description provided for @saveTripPageNoCatches.
  ///
  /// In en, this message translates to:
  /// **'No catches'**
  String get saveTripPageNoCatches;

  /// No description provided for @saveTripPageNoBodiesOfWater.
  ///
  /// In en, this message translates to:
  /// **'No bodies of water'**
  String get saveTripPageNoBodiesOfWater;

  /// No description provided for @saveTripPageNoGpsTrails.
  ///
  /// In en, this message translates to:
  /// **'No GPS trails'**
  String get saveTripPageNoGpsTrails;

  /// No description provided for @tripCatchesPerSpecies.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Species'**
  String get tripCatchesPerSpecies;

  /// No description provided for @tripCatchesPerFishingSpot.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Fishing Spot'**
  String get tripCatchesPerFishingSpot;

  /// No description provided for @tripCatchesPerAngler.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Angler'**
  String get tripCatchesPerAngler;

  /// No description provided for @tripCatchesPerBait.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Bait'**
  String get tripCatchesPerBait;

  /// No description provided for @tripSkunked.
  ///
  /// In en, this message translates to:
  /// **'Skunked'**
  String get tripSkunked;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsPageFetchAtmosphereTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetch Weather'**
  String get settingsPageFetchAtmosphereTitle;

  /// No description provided for @settingsPageFetchAtmosphereDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically fetch atmosphere and weather data when adding new catches and trips.'**
  String get settingsPageFetchAtmosphereDescription;

  /// No description provided for @settingsPageFetchTideTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetch Tide'**
  String get settingsPageFetchTideTitle;

  /// No description provided for @settingsPageFetchTideDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically fetch tide data when adding new catches.'**
  String get settingsPageFetchTideDescription;

  /// No description provided for @settingsPageLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsPageLogout;

  /// No description provided for @settingsPageLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsPageLogoutConfirmMessage;

  /// No description provided for @settingsPageAbout.
  ///
  /// In en, this message translates to:
  /// **'About, Terms, and Privacy'**
  String get settingsPageAbout;

  /// No description provided for @settingsPageFishingSpotDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fishing Spot Distance'**
  String get settingsPageFishingSpotDistanceTitle;

  /// No description provided for @settingsPageFishingSpotDistanceDescription.
  ///
  /// In en, this message translates to:
  /// **'The distance within which to automatically pick fishing spots when adding catches.'**
  String get settingsPageFishingSpotDistanceDescription;

  /// No description provided for @settingsPageMinGpsTrailDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Trail Distance'**
  String get settingsPageMinGpsTrailDistanceTitle;

  /// No description provided for @settingsPageMinGpsTrailDistanceDescription.
  ///
  /// In en, this message translates to:
  /// **'The minimum distance between points in a GPS trail.'**
  String get settingsPageMinGpsTrailDistanceDescription;

  /// No description provided for @settingsPageThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsPageThemeTitle;

  /// No description provided for @settingsPageThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsPageThemeSystem;

  /// No description provided for @settingsPageThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsPageThemeLight;

  /// No description provided for @settingsPageThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsPageThemeDark;

  /// No description provided for @settingsPageThemeSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get settingsPageThemeSelect;

  /// No description provided for @unitsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement Units'**
  String get unitsPageTitle;

  /// No description provided for @unitsPageCatchLength.
  ///
  /// In en, this message translates to:
  /// **'Catch Length'**
  String get unitsPageCatchLength;

  /// No description provided for @unitsPageFractionalInches.
  ///
  /// In en, this message translates to:
  /// **'Fractional inches ({value})'**
  String unitsPageFractionalInches(String value);

  /// No description provided for @unitsPageInches.
  ///
  /// In en, this message translates to:
  /// **'Inches ({value})'**
  String unitsPageInches(String value);

  /// No description provided for @unitsPageCatchWeight.
  ///
  /// In en, this message translates to:
  /// **'Catch Weight'**
  String get unitsPageCatchWeight;

  /// No description provided for @unitsPageCatchWeightPoundsOunces.
  ///
  /// In en, this message translates to:
  /// **'Pounds and ounces ({value})'**
  String unitsPageCatchWeightPoundsOunces(String value);

  /// No description provided for @unitsPageCatchWeightPounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds ({value})'**
  String unitsPageCatchWeightPounds(String value);

  /// No description provided for @unitsPageCatchWeightKilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms ({value})'**
  String unitsPageCatchWeightKilograms(String value);

  /// No description provided for @unitsPageWaterTemperatureFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit ({value})'**
  String unitsPageWaterTemperatureFahrenheit(String value);

  /// No description provided for @unitsPageWaterTemperatureCelsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius ({value})'**
  String unitsPageWaterTemperatureCelsius(String value);

  /// No description provided for @unitsPageFeetInches.
  ///
  /// In en, this message translates to:
  /// **'Feet and inches ({value})'**
  String unitsPageFeetInches(String value);

  /// No description provided for @unitsPageFeet.
  ///
  /// In en, this message translates to:
  /// **'Feet ({value})'**
  String unitsPageFeet(String value);

  /// No description provided for @unitsPageAirTemperatureFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit ({value})'**
  String unitsPageAirTemperatureFahrenheit(String value);

  /// No description provided for @unitsPageAirTemperatureCelsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius ({value})'**
  String unitsPageAirTemperatureCelsius(String value);

  /// No description provided for @unitsPageAirPressureInHg.
  ///
  /// In en, this message translates to:
  /// **'Inch of mercury ({value})'**
  String unitsPageAirPressureInHg(String value);

  /// No description provided for @unitsPageAirPressurePsi.
  ///
  /// In en, this message translates to:
  /// **'Pounds per square inch ({value})'**
  String unitsPageAirPressurePsi(String value);

  /// No description provided for @unitsPageAirPressureMillibars.
  ///
  /// In en, this message translates to:
  /// **'Millibars ({value})'**
  String unitsPageAirPressureMillibars(String value);

  /// No description provided for @unitsPageAirVisibilityMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles ({value})'**
  String unitsPageAirVisibilityMiles(String value);

  /// No description provided for @unitsPageWindSpeedMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles per hour ({value})'**
  String unitsPageWindSpeedMiles(String value);

  /// No description provided for @unitsPageDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get unitsPageDistanceTitle;

  /// No description provided for @unitsPageRodLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Rod Length'**
  String get unitsPageRodLengthTitle;

  /// No description provided for @unitsPageLeaderLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Leader Length'**
  String get unitsPageLeaderLengthTitle;

  /// No description provided for @unitsPageTippetLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Tippet Length'**
  String get unitsPageTippetLengthTitle;

  /// No description provided for @mapPageMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapPageMenuLabel;

  /// No description provided for @mapPageDeleteFishingSpot.
  ///
  /// In en, this message translates to:
  /// **'{spot} is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String mapPageDeleteFishingSpot(String spot, int numOfCatches);

  /// No description provided for @mapPageDeleteFishingSpotSingular.
  ///
  /// In en, this message translates to:
  /// **'{spot} is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String mapPageDeleteFishingSpotSingular(String spot);

  /// No description provided for @mapPageDeleteFishingSpotNoName.
  ///
  /// In en, this message translates to:
  /// **'This fishing spot is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String mapPageDeleteFishingSpotNoName(int numOfCatches);

  /// No description provided for @mapPageDeleteFishingSpotNoNameSingular.
  ///
  /// In en, this message translates to:
  /// **'This fishing spot is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String get mapPageDeleteFishingSpotNoNameSingular;

  /// No description provided for @mapPageAddCatch.
  ///
  /// In en, this message translates to:
  /// **'Add Catch'**
  String get mapPageAddCatch;

  /// No description provided for @mapPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fishing spots'**
  String get mapPageSearchHint;

  /// No description provided for @mapPageDroppedPin.
  ///
  /// In en, this message translates to:
  /// **'New Fishing Spot'**
  String get mapPageDroppedPin;

  /// No description provided for @mapPageMapTypeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mapPageMapTypeLight;

  /// No description provided for @mapPageMapTypeSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapPageMapTypeSatellite;

  /// No description provided for @mapPageMapTypeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get mapPageMapTypeDark;

  /// No description provided for @mapPageErrorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve current location. Ensure your device\'\'s location services are turned on and try again later.'**
  String get mapPageErrorGettingLocation;

  /// No description provided for @mapPageErrorOpeningDirections.
  ///
  /// In en, this message translates to:
  /// **'There are no navigation apps available on this device.'**
  String get mapPageErrorOpeningDirections;

  /// No description provided for @mapPageAppleMaps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps™'**
  String get mapPageAppleMaps;

  /// No description provided for @mapPageGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps™'**
  String get mapPageGoogleMaps;

  /// No description provided for @mapPageWaze.
  ///
  /// In en, this message translates to:
  /// **'Waze™'**
  String get mapPageWaze;

  /// No description provided for @mapPageMapTypeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose Map Type'**
  String get mapPageMapTypeTooltip;

  /// No description provided for @mapPageMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show My Location'**
  String get mapPageMyLocationTooltip;

  /// No description provided for @mapPageShowAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show All Fishing Spots'**
  String get mapPageShowAllTooltip;

  /// No description provided for @mapPageStartTrackingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start GPS Trail'**
  String get mapPageStartTrackingTooltip;

  /// No description provided for @mapPageStopTrackingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop GPS Trail'**
  String get mapPageStopTrackingTooltip;

  /// No description provided for @mapPageAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Fishing Spot'**
  String get mapPageAddTooltip;

  /// No description provided for @saveFishingSpotPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Fishing Spot'**
  String get saveFishingSpotPageNewTitle;

  /// No description provided for @saveFishingSpotPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Fishing Spot'**
  String get saveFishingSpotPageEditTitle;

  /// No description provided for @saveFishingSpotPageBodyOfWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Body of Water'**
  String get saveFishingSpotPageBodyOfWaterLabel;

  /// No description provided for @saveFishingSpotPageCoordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get saveFishingSpotPageCoordinatesLabel;

  /// No description provided for @formPageManageFieldText.
  ///
  /// In en, this message translates to:
  /// **'Manage Fields'**
  String get formPageManageFieldText;

  /// No description provided for @formPageAddCustomFieldNote.
  ///
  /// In en, this message translates to:
  /// **'To add a custom field, tap the %s icon.'**
  String get formPageAddCustomFieldNote;

  /// No description provided for @formPageManageFieldsNote.
  ///
  /// In en, this message translates to:
  /// **'To manage fields, tap the %s icon.'**
  String get formPageManageFieldsNote;

  /// No description provided for @formPageManageFieldsProDescription.
  ///
  /// In en, this message translates to:
  /// **'You must be an Anglers\'\' Log Pro subscriber to use custom fields.'**
  String get formPageManageFieldsProDescription;

  /// No description provided for @formPageManageUnits.
  ///
  /// In en, this message translates to:
  /// **'Manage Units'**
  String get formPageManageUnits;

  /// No description provided for @formPageConfirmBackDesc.
  ///
  /// In en, this message translates to:
  /// **'Any unsaved changes will be lost. Are you sure you want to discard changes and go back?'**
  String get formPageConfirmBackDesc;

  /// No description provided for @formPageConfirmBackAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get formPageConfirmBackAction;

  /// No description provided for @saveCustomEntityPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Field'**
  String get saveCustomEntityPageNewTitle;

  /// No description provided for @saveCustomEntityPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Field'**
  String get saveCustomEntityPageEditTitle;

  /// No description provided for @saveCustomEntityPageNameExists.
  ///
  /// In en, this message translates to:
  /// **'Field name already exists'**
  String get saveCustomEntityPageNameExists;

  /// No description provided for @customEntityListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields ({numOfFields})'**
  String customEntityListPageTitle(int numOfFields);

  /// No description provided for @customEntityListPageDelete.
  ///
  /// In en, this message translates to:
  /// **'The custom field {field} will no longer be associated with catches ({numOfCatches}) or baits ({numOfBaits}), are you sure you want to delete it? This cannot be undone.'**
  String customEntityListPageDelete(
    String field,
    int numOfCatches,
    int numOfBaits,
  );

  /// No description provided for @customEntityListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fields'**
  String get customEntityListPageSearchHint;

  /// No description provided for @customEntityListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Custom Fields'**
  String get customEntityListPageEmptyListTitle;

  /// No description provided for @customEntityListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any custom fields. Tap the %s button to begin.'**
  String get customEntityListPageEmptyListDescription;

  /// No description provided for @imagePickerConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get imagePickerConfirmDelete;

  /// No description provided for @imagePickerPageNoPhotosFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get imagePickerPageNoPhotosFoundTitle;

  /// No description provided for @imagePickerPageNoPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'Try changing the photo source from the dropdown above.'**
  String get imagePickerPageNoPhotosFound;

  /// No description provided for @imagePickerPageOpenCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get imagePickerPageOpenCameraLabel;

  /// No description provided for @imagePickerPageCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePickerPageCameraLabel;

  /// No description provided for @imagePickerPageGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get imagePickerPageGalleryLabel;

  /// No description provided for @imagePickerPageBrowseLabel.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get imagePickerPageBrowseLabel;

  /// No description provided for @imagePickerPageSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'{numSelected} / {numTotal} Selected'**
  String imagePickerPageSelectedLabel(int numSelected, int numTotal);

  /// No description provided for @imagePickerPageInvalidSelectionSingle.
  ///
  /// In en, this message translates to:
  /// **'Must select an image file.'**
  String get imagePickerPageInvalidSelectionSingle;

  /// No description provided for @imagePickerPageInvalidSelectionPlural.
  ///
  /// In en, this message translates to:
  /// **'Must select image files.'**
  String get imagePickerPageInvalidSelectionPlural;

  /// No description provided for @imagePickerPageNoPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get imagePickerPageNoPermissionTitle;

  /// No description provided for @imagePickerPageNoPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To add photos, you must grant Anglers\'\' Log permission to access your photo library. To do so, open your device settings.\n\nAlternatively, you can change the photos source from the dropdown menu above.'**
  String get imagePickerPageNoPermissionMessage;

  /// No description provided for @imagePickerPageOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get imagePickerPageOpenSettings;

  /// No description provided for @imagePickerPageImageDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to attach photo. Please ensure you are connected to the internet and try again.'**
  String get imagePickerPageImageDownloadError;

  /// No description provided for @imagePickerPageImagesDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to attach one or more photos. Please ensure you are connected to the internet and try again.'**
  String get imagePickerPageImagesDownloadError;

  /// No description provided for @reportListPageConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete report {report}? This cannot be undone.'**
  String reportListPageConfirmDelete(String report);

  /// No description provided for @reportListPageReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Reports'**
  String get reportListPageReportTitle;

  /// No description provided for @reportListPageReportAddNote.
  ///
  /// In en, this message translates to:
  /// **'To add a custom report, tap the %s icon.'**
  String get reportListPageReportAddNote;

  /// No description provided for @reportListPageReportsProDescription.
  ///
  /// In en, this message translates to:
  /// **'You must be an Anglers\'\' Log Pro subscriber to view custom reports.'**
  String get reportListPageReportsProDescription;

  /// No description provided for @saveSpeciesPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Species'**
  String get saveSpeciesPageNewTitle;

  /// No description provided for @saveSpeciesPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Species'**
  String get saveSpeciesPageEditTitle;

  /// No description provided for @saveSpeciesPageExistsError.
  ///
  /// In en, this message translates to:
  /// **'Species already exists'**
  String get saveSpeciesPageExistsError;

  /// No description provided for @speciesListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Species ({numOfSpecies})'**
  String speciesListPageTitle(int numOfSpecies);

  /// No description provided for @speciesListPageConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'{species} is associated with 0 catches; are you sure you want to delete it? This cannot be undone.'**
  String speciesListPageConfirmDelete(String species);

  /// No description provided for @speciesListPageCatchDeleteErrorSingular.
  ///
  /// In en, this message translates to:
  /// **'{species} is associated with 1 catch and cannot be deleted.'**
  String speciesListPageCatchDeleteErrorSingular(String species);

  /// No description provided for @speciesListPageCatchDeleteErrorPlural.
  ///
  /// In en, this message translates to:
  /// **'{species} is associated with {numOfCatches} catches and cannot be deleted.'**
  String speciesListPageCatchDeleteErrorPlural(
    String species,
    int numOfCatches,
  );

  /// No description provided for @speciesListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search species'**
  String get speciesListPageSearchHint;

  /// No description provided for @speciesListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Species'**
  String get speciesListPageEmptyListTitle;

  /// No description provided for @speciesListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any species. Tap the %s button to begin.'**
  String get speciesListPageEmptyListDescription;

  /// No description provided for @fishingSpotPickerPageHint.
  ///
  /// In en, this message translates to:
  /// **'Long press the map to pick exact coordinates, or select an existing fishing spot.'**
  String get fishingSpotPickerPageHint;

  /// No description provided for @fishingSpotListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Fishing Spots ({numOfSpots})'**
  String fishingSpotListPageTitle(int numOfSpots);

  /// No description provided for @fishingSpotListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fishing spots'**
  String get fishingSpotListPageSearchHint;

  /// No description provided for @fishingSpotListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Fishing Spots'**
  String get fishingSpotListPageEmptyListTitle;

  /// No description provided for @fishingSpotListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'To add a fishing spot, tap the %s button on the map and save the dropped pin.'**
  String get fishingSpotListPageEmptyListDescription;

  /// No description provided for @fishingSpotsSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When fishing spots are added to your log, a summary of their catches will be shown here.'**
  String get fishingSpotsSummaryEmpty;

  /// No description provided for @fishingSpotListPageNoBodyOfWater.
  ///
  /// In en, this message translates to:
  /// **'No Body of Water'**
  String get fishingSpotListPageNoBodyOfWater;

  /// No description provided for @fishingSpotMapAddSpotHelp.
  ///
  /// In en, this message translates to:
  /// **'Long press anywhere on the map to drop a pin and add a fishing spot.'**
  String get fishingSpotMapAddSpotHelp;

  /// No description provided for @editCoordinatesHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to update the fishing spot\'\'s coordinates.'**
  String get editCoordinatesHint;

  /// No description provided for @feedbackPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackPageTitle;

  /// No description provided for @feedbackPageSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackPageSend;

  /// No description provided for @feedbackPageMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackPageMessage;

  /// No description provided for @feedbackPageBugType.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get feedbackPageBugType;

  /// No description provided for @feedbackPageSuggestionType.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackPageSuggestionType;

  /// No description provided for @feedbackPageFeedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackPageFeedbackType;

  /// No description provided for @feedbackPageErrorSending.
  ///
  /// In en, this message translates to:
  /// **'Error sending feedback. Please try again later, or email support@anglerslog.ca directly.'**
  String get feedbackPageErrorSending;

  /// No description provided for @feedbackPageConnectionError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your connection and try again.'**
  String get feedbackPageConnectionError;

  /// No description provided for @feedbackPageSending.
  ///
  /// In en, this message translates to:
  /// **'Sending feedback...'**
  String get feedbackPageSending;

  /// No description provided for @backupPageMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and Restore'**
  String get backupPageMoreTitle;

  /// No description provided for @importPageMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Import'**
  String get importPageMoreTitle;

  /// No description provided for @importPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Import'**
  String get importPageTitle;

  /// No description provided for @importPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Legacy import requires you to choose a backup file (.zip) that you created with an older version of Anglers\'\' Log. Imported legacy data is added to your existing log.\n\nThe import process may take several minutes.'**
  String get importPageDescription;

  /// No description provided for @importPageImportingImages.
  ///
  /// In en, this message translates to:
  /// **'Copying images...'**
  String get importPageImportingImages;

  /// No description provided for @importPageImportingData.
  ///
  /// In en, this message translates to:
  /// **'Copying fishing data...'**
  String get importPageImportingData;

  /// No description provided for @importPageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported data!'**
  String get importPageSuccess;

  /// No description provided for @importPageError.
  ///
  /// In en, this message translates to:
  /// **'There was an error importing your data. If the backup file you chose was created using Anglers\'\' Log, please send it to us for investigation.'**
  String get importPageError;

  /// No description provided for @importPageErrorWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Pressing send will send Anglers\'\' Log all your fishing data (excluding photos). Your data will not be shared outside the Anglers\'\' Log organization.'**
  String get importPageErrorWarningMessage;

  /// No description provided for @importPageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Error'**
  String get importPageErrorTitle;

  /// No description provided for @dataImporterChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get dataImporterChooseFile;

  /// No description provided for @dataImporterStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dataImporterStart;

  /// No description provided for @migrationPageMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Migration'**
  String get migrationPageMoreTitle;

  /// No description provided for @migrationPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Migration'**
  String get migrationPageTitle;

  /// No description provided for @onboardingMigrationPageDescription.
  ///
  /// In en, this message translates to:
  /// **'This is your first time opening Anglers\'\' Log since updating to 2.0. Click the button below to start the data migration process.'**
  String get onboardingMigrationPageDescription;

  /// No description provided for @migrationPageDescription.
  ///
  /// In en, this message translates to:
  /// **'You have legacy data that needs to be migrated to Anglers\'\' Log 2.0. Click the button below to begin.'**
  String get migrationPageDescription;

  /// No description provided for @onboardingMigrationPageError.
  ///
  /// In en, this message translates to:
  /// **'There was an unexpected error while migrating your data to Anglers\'\' Log 2.0. Please send us the error report and we will investigate as soon as possible. Note that none of your data has been lost. Please visit the Settings page to retry data migration after the issue has been resolved.'**
  String get onboardingMigrationPageError;

  /// No description provided for @migrationPageError.
  ///
  /// In en, this message translates to:
  /// **'There was an unexpected error while migrating your data to Anglers\'\' Log 2.0. Please send us the error report and we will investigate as soon as possible. Note that none of your old data has been lost. Please revisit this page to retry data migration after the issue has been resolved.'**
  String get migrationPageError;

  /// No description provided for @migrationPageLoading.
  ///
  /// In en, this message translates to:
  /// **'Migrating data to Anglers\'\' Log 2.0...'**
  String get migrationPageLoading;

  /// No description provided for @migrationPageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully migrated data!'**
  String get migrationPageSuccess;

  /// No description provided for @migrationPageNothingToDoDescription.
  ///
  /// In en, this message translates to:
  /// **'Data migration is the process of converting legacy data from old versions of Anglers\'\' Log into the data format used by new versions.'**
  String get migrationPageNothingToDoDescription;

  /// No description provided for @migrationPageNothingToDoSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have no legacy data to migrate!'**
  String get migrationPageNothingToDoSuccess;

  /// No description provided for @migrationPageFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration Error'**
  String get migrationPageFeedbackTitle;

  /// No description provided for @anglerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Angler'**
  String get anglerNameLabel;

  /// No description provided for @onboardingJourneyWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingJourneyWelcomeTitle;

  /// No description provided for @onboardingJourneyStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Anglers\'\' Log! Let\'\'s start by figuring out what kind of data you want to track.'**
  String get onboardingJourneyStartDescription;

  /// No description provided for @onboardingJourneyStartButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingJourneyStartButton;

  /// No description provided for @onboardingJourneySkip.
  ///
  /// In en, this message translates to:
  /// **'No thanks, I\'\'ll learn as I go.'**
  String get onboardingJourneySkip;

  /// No description provided for @onboardingJourneyCatchFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'When you log a catch, what do you want to know?'**
  String get onboardingJourneyCatchFieldDescription;

  /// No description provided for @onboardingJourneyManageFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Fields'**
  String get onboardingJourneyManageFieldsTitle;

  /// No description provided for @onboardingJourneyManageFieldsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage default fields, or add custom fields at any time when adding or editing gear, a catch, bait, trip, or weather.'**
  String get onboardingJourneyManageFieldsDescription;

  /// No description provided for @onboardingJourneyManageFieldsSpecies.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Trout'**
  String get onboardingJourneyManageFieldsSpecies;

  /// No description provided for @onboardingJourneyLocationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get onboardingJourneyLocationAccessTitle;

  /// No description provided for @onboardingJourneyLocationAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Anglers\'\' Log uses location services to show your current location on the in-app map, to automatically create fishing spots when adding catches, and to create GPS trails while fishing.'**
  String get onboardingJourneyLocationAccessDescription;

  /// No description provided for @onboardingJourneyHowToFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get onboardingJourneyHowToFeedbackTitle;

  /// No description provided for @onboardingJourneyHowToFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Report a problem, suggest a feature, or send us feedback anytime. We\'\'d love to hear from you!'**
  String get onboardingJourneyHowToFeedbackDescription;

  /// No description provided for @onboardingJourneyNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get onboardingJourneyNotNow;

  /// No description provided for @emptyListPlaceholderNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyListPlaceholderNoResultsTitle;

  /// No description provided for @emptyListPlaceholderNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Please adjust your search filter to find what you\'\'re looking for.'**
  String get emptyListPlaceholderNoResultsDescription;

  /// No description provided for @proPageBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup with Google Drive™'**
  String get proPageBackup;

  /// No description provided for @proPageCsv.
  ///
  /// In en, this message translates to:
  /// **'Export log to spreadsheet (CSV)'**
  String get proPageCsv;

  /// No description provided for @proPageAtmosphere.
  ///
  /// In en, this message translates to:
  /// **'Fetch atmosphere, weather, and tide data'**
  String get proPageAtmosphere;

  /// No description provided for @proPageReports.
  ///
  /// In en, this message translates to:
  /// **'Create custom reports and filters'**
  String get proPageReports;

  /// No description provided for @proPageCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Create custom input fields'**
  String get proPageCustomFields;

  /// No description provided for @proPageGpsTrails.
  ///
  /// In en, this message translates to:
  /// **'Create and track realtime GPS trails'**
  String get proPageGpsTrails;

  /// No description provided for @proPageCopyCatch.
  ///
  /// In en, this message translates to:
  /// **'Copy catches'**
  String get proPageCopyCatch;

  /// No description provided for @proPageSpeciesCounter.
  ///
  /// In en, this message translates to:
  /// **'Realtime species caught counter'**
  String get proPageSpeciesCounter;

  /// No description provided for @periodDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get periodDawn;

  /// No description provided for @periodMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get periodMorning;

  /// No description provided for @periodMidday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get periodMidday;

  /// No description provided for @periodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get periodAfternoon;

  /// No description provided for @periodEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get periodEvening;

  /// No description provided for @periodDusk.
  ///
  /// In en, this message translates to:
  /// **'Dusk'**
  String get periodDusk;

  /// No description provided for @periodNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get periodNight;

  /// No description provided for @periodPickerAll.
  ///
  /// In en, this message translates to:
  /// **'All times of day'**
  String get periodPickerAll;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonPickerAll.
  ///
  /// In en, this message translates to:
  /// **'All seasons'**
  String get seasonPickerAll;

  /// No description provided for @measurementSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get measurementSystemImperial;

  /// No description provided for @measurementSystemImperialDecimal.
  ///
  /// In en, this message translates to:
  /// **'Imperial Decimal'**
  String get measurementSystemImperialDecimal;

  /// No description provided for @measurementSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get measurementSystemMetric;

  /// No description provided for @numberBoundaryAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get numberBoundaryAny;

  /// No description provided for @numberBoundaryLessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than (<)'**
  String get numberBoundaryLessThan;

  /// No description provided for @numberBoundaryLessThanOrEqualTo.
  ///
  /// In en, this message translates to:
  /// **'Less than or equal to (≤)'**
  String get numberBoundaryLessThanOrEqualTo;

  /// No description provided for @numberBoundaryEqualTo.
  ///
  /// In en, this message translates to:
  /// **'Equal to (=)'**
  String get numberBoundaryEqualTo;

  /// No description provided for @numberBoundaryGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Greater than (>)'**
  String get numberBoundaryGreaterThan;

  /// No description provided for @numberBoundaryGreaterThanOrEqualTo.
  ///
  /// In en, this message translates to:
  /// **'Greater than or equal to (≥)'**
  String get numberBoundaryGreaterThanOrEqualTo;

  /// No description provided for @numberBoundaryRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get numberBoundaryRange;

  /// No description provided for @numberBoundaryLessThanValue.
  ///
  /// In en, this message translates to:
  /// **'< {value}'**
  String numberBoundaryLessThanValue(String value);

  /// No description provided for @numberBoundaryLessThanOrEqualToValue.
  ///
  /// In en, this message translates to:
  /// **'≤ {value}'**
  String numberBoundaryLessThanOrEqualToValue(String value);

  /// No description provided for @numberBoundaryEqualToValue.
  ///
  /// In en, this message translates to:
  /// **'= {value}'**
  String numberBoundaryEqualToValue(String value);

  /// No description provided for @numberBoundaryGreaterThanValue.
  ///
  /// In en, this message translates to:
  /// **'> {value}'**
  String numberBoundaryGreaterThanValue(String value);

  /// No description provided for @numberBoundaryGreaterThanOrEqualToValue.
  ///
  /// In en, this message translates to:
  /// **'≥ {value}'**
  String numberBoundaryGreaterThanOrEqualToValue(String value);

  /// No description provided for @numberBoundaryRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{from} - {to}'**
  String numberBoundaryRangeValue(String from, String to);

  /// No description provided for @unitFeet.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get unitFeet;

  /// No description provided for @unitInches.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitInches;

  /// No description provided for @unitPounds.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get unitPounds;

  /// No description provided for @unitOunces.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOunces;

  /// No description provided for @unitFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get unitFahrenheit;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeters;

  /// No description provided for @unitCentimeters.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCentimeters;

  /// No description provided for @unitKilograms.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilograms;

  /// No description provided for @unitCelsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get unitCelsius;

  /// No description provided for @unitMilesPerHour.
  ///
  /// In en, this message translates to:
  /// **'mph'**
  String get unitMilesPerHour;

  /// No description provided for @unitKilometersPerHour.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get unitKilometersPerHour;

  /// No description provided for @unitMillibars.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get unitMillibars;

  /// No description provided for @unitPoundsPerSquareInch.
  ///
  /// In en, this message translates to:
  /// **'psi'**
  String get unitPoundsPerSquareInch;

  /// No description provided for @unitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get unitPercent;

  /// No description provided for @unitInchOfMercury.
  ///
  /// In en, this message translates to:
  /// **'inHg'**
  String get unitInchOfMercury;

  /// No description provided for @unitMiles.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get unitMiles;

  /// No description provided for @unitKilometers.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKilometers;

  /// No description provided for @unitX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get unitX;

  /// No description provided for @unitAught.
  ///
  /// In en, this message translates to:
  /// **'O'**
  String get unitAught;

  /// No description provided for @unitPoundTest.
  ///
  /// In en, this message translates to:
  /// **'lb test'**
  String get unitPoundTest;

  /// No description provided for @unitHashtag.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get unitHashtag;

  /// No description provided for @unitMetersPerSecond.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get unitMetersPerSecond;

  /// No description provided for @unitConvertToValue.
  ///
  /// In en, this message translates to:
  /// **'Convert to {unit}'**
  String unitConvertToValue(String unit);

  /// No description provided for @numberFilterInputFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get numberFilterInputFrom;

  /// No description provided for @numberFilterInputTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get numberFilterInputTo;

  /// No description provided for @numberFilterInputValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get numberFilterInputValue;

  /// No description provided for @filterTitleWaterTemperature.
  ///
  /// In en, this message translates to:
  /// **'Water Temperature Filter'**
  String get filterTitleWaterTemperature;

  /// No description provided for @filterTitleWaterDepth.
  ///
  /// In en, this message translates to:
  /// **'Water Depth Filter'**
  String get filterTitleWaterDepth;

  /// No description provided for @filterTitleLength.
  ///
  /// In en, this message translates to:
  /// **'Length Filter'**
  String get filterTitleLength;

  /// No description provided for @filterTitleWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight Filter'**
  String get filterTitleWeight;

  /// No description provided for @filterTitleQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity Filter'**
  String get filterTitleQuantity;

  /// No description provided for @filterTitleAirTemperature.
  ///
  /// In en, this message translates to:
  /// **'Air Temperature Filter'**
  String get filterTitleAirTemperature;

  /// No description provided for @filterTitleAirPressure.
  ///
  /// In en, this message translates to:
  /// **'Atmospheric Pressure Filter'**
  String get filterTitleAirPressure;

  /// No description provided for @filterTitleAirHumidity.
  ///
  /// In en, this message translates to:
  /// **'Air Humidity Filter'**
  String get filterTitleAirHumidity;

  /// No description provided for @filterTitleAirVisibility.
  ///
  /// In en, this message translates to:
  /// **'Air Visibility Filter'**
  String get filterTitleAirVisibility;

  /// No description provided for @filterTitleWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed Filter'**
  String get filterTitleWindSpeed;

  /// No description provided for @filterValueWaterTemperature.
  ///
  /// In en, this message translates to:
  /// **'Water Temperature: {value}'**
  String filterValueWaterTemperature(String value);

  /// No description provided for @filterValueWaterDepth.
  ///
  /// In en, this message translates to:
  /// **'Water Depth: {value}'**
  String filterValueWaterDepth(String value);

  /// No description provided for @filterValueLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {value}'**
  String filterValueLength(String value);

  /// No description provided for @filterValueWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value}'**
  String filterValueWeight(String value);

  /// No description provided for @filterValueQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {value}'**
  String filterValueQuantity(String value);

  /// No description provided for @filterValueAirTemperature.
  ///
  /// In en, this message translates to:
  /// **'Air Temperature: {value}'**
  String filterValueAirTemperature(String value);

  /// No description provided for @filterValueAirPressure.
  ///
  /// In en, this message translates to:
  /// **'Atmospheric Pressure: {value}'**
  String filterValueAirPressure(String value);

  /// No description provided for @filterValueAirHumidity.
  ///
  /// In en, this message translates to:
  /// **'Air Humidity: {value}%'**
  String filterValueAirHumidity(String value);

  /// No description provided for @filterValueAirVisibility.
  ///
  /// In en, this message translates to:
  /// **'Air Visibility: {value}'**
  String filterValueAirVisibility(String value);

  /// No description provided for @filterValueWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed: {value}'**
  String filterValueWindSpeed(String value);

  /// No description provided for @filterPageInvalidEndValue.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than {value}'**
  String filterPageInvalidEndValue(String value);

  /// No description provided for @moonPhaseNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get moonPhaseNew;

  /// No description provided for @moonPhaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get moonPhaseWaxingCrescent;

  /// No description provided for @moonPhaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'1st Quarter'**
  String get moonPhaseFirstQuarter;

  /// No description provided for @moonPhaseWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing Gibbous'**
  String get moonPhaseWaxingGibbous;

  /// No description provided for @moonPhaseFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get moonPhaseFull;

  /// No description provided for @moonPhaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get moonPhaseWaningGibbous;

  /// No description provided for @moonPhaseLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last Quarter'**
  String get moonPhaseLastQuarter;

  /// No description provided for @moonPhaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get moonPhaseWaningCrescent;

  /// No description provided for @moonPhaseChip.
  ///
  /// In en, this message translates to:
  /// **'{value} Moon'**
  String moonPhaseChip(String value);

  /// No description provided for @atmosphereInputTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get atmosphereInputTemperature;

  /// No description provided for @atmosphereInputAirTemperature.
  ///
  /// In en, this message translates to:
  /// **'Air Temperature'**
  String get atmosphereInputAirTemperature;

  /// No description provided for @atmosphereInputSkyConditions.
  ///
  /// In en, this message translates to:
  /// **'Sky Conditions'**
  String get atmosphereInputSkyConditions;

  /// No description provided for @atmosphereInputNoSkyConditions.
  ///
  /// In en, this message translates to:
  /// **'No sky conditions'**
  String get atmosphereInputNoSkyConditions;

  /// No description provided for @atmosphereInputWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get atmosphereInputWindSpeed;

  /// No description provided for @atmosphereInputWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get atmosphereInputWind;

  /// No description provided for @atmosphereInputWindDirection.
  ///
  /// In en, this message translates to:
  /// **'Wind Direction'**
  String get atmosphereInputWindDirection;

  /// No description provided for @atmosphereInputPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get atmosphereInputPressure;

  /// No description provided for @atmosphereInputAtmosphericPressure.
  ///
  /// In en, this message translates to:
  /// **'Atmospheric Pressure'**
  String get atmosphereInputAtmosphericPressure;

  /// No description provided for @atmosphereInputHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get atmosphereInputHumidity;

  /// No description provided for @atmosphereInputAirHumidity.
  ///
  /// In en, this message translates to:
  /// **'Air Humidity'**
  String get atmosphereInputAirHumidity;

  /// No description provided for @atmosphereInputVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get atmosphereInputVisibility;

  /// No description provided for @atmosphereInputAirVisibility.
  ///
  /// In en, this message translates to:
  /// **'Air Visibility'**
  String get atmosphereInputAirVisibility;

  /// No description provided for @atmosphereInputMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get atmosphereInputMoon;

  /// No description provided for @atmosphereInputMoonPhase.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get atmosphereInputMoonPhase;

  /// No description provided for @atmosphereInputSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get atmosphereInputSunrise;

  /// No description provided for @atmosphereInputTimeOfSunrise.
  ///
  /// In en, this message translates to:
  /// **'Time of Sunrise'**
  String get atmosphereInputTimeOfSunrise;

  /// No description provided for @atmosphereInputSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get atmosphereInputSunset;

  /// No description provided for @atmosphereInputTimeOfSunset.
  ///
  /// In en, this message translates to:
  /// **'Time of Sunset'**
  String get atmosphereInputTimeOfSunset;

  /// No description provided for @directionNorth.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get directionNorth;

  /// No description provided for @directionNorthEast.
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get directionNorthEast;

  /// No description provided for @directionEast.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get directionEast;

  /// No description provided for @directionSouthEast.
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get directionSouthEast;

  /// No description provided for @directionSouth.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get directionSouth;

  /// No description provided for @directionSouthWest.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get directionSouthWest;

  /// No description provided for @directionWest.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get directionWest;

  /// No description provided for @directionNorthWest.
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get directionNorthWest;

  /// No description provided for @directionWindChip.
  ///
  /// In en, this message translates to:
  /// **'Wind: {value}'**
  String directionWindChip(String value);

  /// No description provided for @skyConditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get skyConditionSnow;

  /// No description provided for @skyConditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get skyConditionDrizzle;

  /// No description provided for @skyConditionDust.
  ///
  /// In en, this message translates to:
  /// **'Dust'**
  String get skyConditionDust;

  /// No description provided for @skyConditionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get skyConditionFog;

  /// No description provided for @skyConditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get skyConditionRain;

  /// No description provided for @skyConditionTornado.
  ///
  /// In en, this message translates to:
  /// **'Tornado'**
  String get skyConditionTornado;

  /// No description provided for @skyConditionHail.
  ///
  /// In en, this message translates to:
  /// **'Hail'**
  String get skyConditionHail;

  /// No description provided for @skyConditionIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get skyConditionIce;

  /// No description provided for @skyConditionStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get skyConditionStorm;

  /// No description provided for @skyConditionMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get skyConditionMist;

  /// No description provided for @skyConditionSmoke.
  ///
  /// In en, this message translates to:
  /// **'Smoke'**
  String get skyConditionSmoke;

  /// No description provided for @skyConditionOvercast.
  ///
  /// In en, this message translates to:
  /// **'Overcast'**
  String get skyConditionOvercast;

  /// No description provided for @skyConditionCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get skyConditionCloudy;

  /// No description provided for @skyConditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get skyConditionClear;

  /// No description provided for @skyConditionSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get skyConditionSunny;

  /// No description provided for @pickerTitleBait.
  ///
  /// In en, this message translates to:
  /// **'Select Bait'**
  String get pickerTitleBait;

  /// No description provided for @pickerTitleBaits.
  ///
  /// In en, this message translates to:
  /// **'Select Baits'**
  String get pickerTitleBaits;

  /// No description provided for @pickerTitleBaitCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Bait Category'**
  String get pickerTitleBaitCategory;

  /// No description provided for @pickerTitleAngler.
  ///
  /// In en, this message translates to:
  /// **'Select Angler'**
  String get pickerTitleAngler;

  /// No description provided for @pickerTitleAnglers.
  ///
  /// In en, this message translates to:
  /// **'Select Anglers'**
  String get pickerTitleAnglers;

  /// No description provided for @pickerTitleFishingMethods.
  ///
  /// In en, this message translates to:
  /// **'Select Fishing Methods'**
  String get pickerTitleFishingMethods;

  /// No description provided for @pickerTitleWaterClarity.
  ///
  /// In en, this message translates to:
  /// **'Select Water Clarity'**
  String get pickerTitleWaterClarity;

  /// No description provided for @pickerTitleWaterClarities.
  ///
  /// In en, this message translates to:
  /// **'Select Water Clarities'**
  String get pickerTitleWaterClarities;

  /// No description provided for @pickerTitleDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get pickerTitleDateRange;

  /// No description provided for @pickerTitleFields.
  ///
  /// In en, this message translates to:
  /// **'Select Fields'**
  String get pickerTitleFields;

  /// No description provided for @pickerTitleReport.
  ///
  /// In en, this message translates to:
  /// **'Select Report'**
  String get pickerTitleReport;

  /// No description provided for @pickerTitleSpecies.
  ///
  /// In en, this message translates to:
  /// **'Select Species'**
  String get pickerTitleSpecies;

  /// No description provided for @pickerTitleFishingSpot.
  ///
  /// In en, this message translates to:
  /// **'Select Fishing Spot'**
  String get pickerTitleFishingSpot;

  /// No description provided for @pickerTitleFishingSpots.
  ///
  /// In en, this message translates to:
  /// **'Select Fishing Spots'**
  String get pickerTitleFishingSpots;

  /// No description provided for @pickerTitleTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Select Time of Day'**
  String get pickerTitleTimeOfDay;

  /// No description provided for @pickerTitleTimesOfDay.
  ///
  /// In en, this message translates to:
  /// **'Select Times of Day'**
  String get pickerTitleTimesOfDay;

  /// No description provided for @pickerTitleSeason.
  ///
  /// In en, this message translates to:
  /// **'Select Season'**
  String get pickerTitleSeason;

  /// No description provided for @pickerTitleSeasons.
  ///
  /// In en, this message translates to:
  /// **'Select Seasons'**
  String get pickerTitleSeasons;

  /// No description provided for @pickerTitleMoonPhase.
  ///
  /// In en, this message translates to:
  /// **'Select Moon Phase'**
  String get pickerTitleMoonPhase;

  /// No description provided for @pickerTitleMoonPhases.
  ///
  /// In en, this message translates to:
  /// **'Select Moon Phases'**
  String get pickerTitleMoonPhases;

  /// No description provided for @pickerTitleSkyCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Sky Condition'**
  String get pickerTitleSkyCondition;

  /// No description provided for @pickerTitleSkyConditions.
  ///
  /// In en, this message translates to:
  /// **'Select Sky Conditions'**
  String get pickerTitleSkyConditions;

  /// No description provided for @pickerTitleWindDirection.
  ///
  /// In en, this message translates to:
  /// **'Select Wind Direction'**
  String get pickerTitleWindDirection;

  /// No description provided for @pickerTitleWindDirections.
  ///
  /// In en, this message translates to:
  /// **'Select Wind Directions'**
  String get pickerTitleWindDirections;

  /// No description provided for @pickerTitleTide.
  ///
  /// In en, this message translates to:
  /// **'Select Tide'**
  String get pickerTitleTide;

  /// No description provided for @pickerTitleTides.
  ///
  /// In en, this message translates to:
  /// **'Select Tides'**
  String get pickerTitleTides;

  /// No description provided for @pickerTitleBodyOfWater.
  ///
  /// In en, this message translates to:
  /// **'Select Body of Water'**
  String get pickerTitleBodyOfWater;

  /// No description provided for @pickerTitleBodiesOfWater.
  ///
  /// In en, this message translates to:
  /// **'Select Bodies of Water'**
  String get pickerTitleBodiesOfWater;

  /// No description provided for @pickerTitleCatches.
  ///
  /// In en, this message translates to:
  /// **'Select Catches'**
  String get pickerTitleCatches;

  /// No description provided for @pickerTitleTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Select Time Zone'**
  String get pickerTitleTimeZone;

  /// No description provided for @pickerTitleGpsTrails.
  ///
  /// In en, this message translates to:
  /// **'Select GPS Trails'**
  String get pickerTitleGpsTrails;

  /// No description provided for @pickerTitleGear.
  ///
  /// In en, this message translates to:
  /// **'Select Gear'**
  String get pickerTitleGear;

  /// No description provided for @pickerTitleRodAction.
  ///
  /// In en, this message translates to:
  /// **'Select Action'**
  String get pickerTitleRodAction;

  /// No description provided for @pickerTitleRodPower.
  ///
  /// In en, this message translates to:
  /// **'Select Power'**
  String get pickerTitleRodPower;

  /// No description provided for @pickerTitleTrip.
  ///
  /// In en, this message translates to:
  /// **'Select Trip'**
  String get pickerTitleTrip;

  /// No description provided for @keywordsTemperatureMetric.
  ///
  /// In en, this message translates to:
  /// **'celsius temperature degrees c'**
  String get keywordsTemperatureMetric;

  /// No description provided for @keywordsTemperatureImperial.
  ///
  /// In en, this message translates to:
  /// **'fahrenheit temperature degrees f'**
  String get keywordsTemperatureImperial;

  /// No description provided for @keywordsSpeedImperial.
  ///
  /// In en, this message translates to:
  /// **'miles per hour speed wind'**
  String get keywordsSpeedImperial;

  /// No description provided for @keywordsAirPressureMetric.
  ///
  /// In en, this message translates to:
  /// **'atmospheric air pressure millibars'**
  String get keywordsAirPressureMetric;

  /// No description provided for @keywordsAirPressureImperial.
  ///
  /// In en, this message translates to:
  /// **'atmospheric air pressure pounds per square inch'**
  String get keywordsAirPressureImperial;

  /// No description provided for @keywordsAirHumidity.
  ///
  /// In en, this message translates to:
  /// **'humidity percent moisture'**
  String get keywordsAirHumidity;

  /// No description provided for @keywordsAirVisibilityMetric.
  ///
  /// In en, this message translates to:
  /// **'kilometers kilometres visibility'**
  String get keywordsAirVisibilityMetric;

  /// No description provided for @keywordsAirVisibilityImperial.
  ///
  /// In en, this message translates to:
  /// **'miles visibility'**
  String get keywordsAirVisibilityImperial;

  /// No description provided for @keywordsPercent.
  ///
  /// In en, this message translates to:
  /// **'percent'**
  String get keywordsPercent;

  /// No description provided for @keywordsInchOfMercury.
  ///
  /// In en, this message translates to:
  /// **'inch of mercury barometric atmospheric pressure'**
  String get keywordsInchOfMercury;

  /// No description provided for @keywordsSunrise.
  ///
  /// In en, this message translates to:
  /// **'sunrise'**
  String get keywordsSunrise;

  /// No description provided for @keywordsSunset.
  ///
  /// In en, this message translates to:
  /// **'sunset'**
  String get keywordsSunset;

  /// No description provided for @keywordsCatchAndRelease.
  ///
  /// In en, this message translates to:
  /// **'kept keep released'**
  String get keywordsCatchAndRelease;

  /// No description provided for @keywordsFavorite.
  ///
  /// In en, this message translates to:
  /// **'favourite favorite star starred'**
  String get keywordsFavorite;

  /// No description provided for @keywordsDepthMetric.
  ///
  /// In en, this message translates to:
  /// **'depth meters metres'**
  String get keywordsDepthMetric;

  /// No description provided for @keywordsDepthImperial.
  ///
  /// In en, this message translates to:
  /// **'depth feet inches'**
  String get keywordsDepthImperial;

  /// No description provided for @keywordsLengthMetric.
  ///
  /// In en, this message translates to:
  /// **'length centimeters cm'**
  String get keywordsLengthMetric;

  /// No description provided for @keywordsLengthImperial.
  ///
  /// In en, this message translates to:
  /// **'length inches in \"'**
  String get keywordsLengthImperial;

  /// No description provided for @keywordsWeightMetric.
  ///
  /// In en, this message translates to:
  /// **'weight kilos kilograms kg'**
  String get keywordsWeightMetric;

  /// No description provided for @keywordsWeightImperial.
  ///
  /// In en, this message translates to:
  /// **'weight pounds ounces lbs oz'**
  String get keywordsWeightImperial;

  /// No description provided for @keywordsX.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get keywordsX;

  /// No description provided for @keywordsAught.
  ///
  /// In en, this message translates to:
  /// **'aught ought'**
  String get keywordsAught;

  /// No description provided for @keywordsPoundTest.
  ///
  /// In en, this message translates to:
  /// **'pound test'**
  String get keywordsPoundTest;

  /// No description provided for @keywordsHashtag.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get keywordsHashtag;

  /// No description provided for @keywordsMetersPerSecond.
  ///
  /// In en, this message translates to:
  /// **'meters metres per second m/s'**
  String get keywordsMetersPerSecond;

  /// No description provided for @keywordsNorth.
  ///
  /// In en, this message translates to:
  /// **'n north'**
  String get keywordsNorth;

  /// No description provided for @keywordsNorthEast.
  ///
  /// In en, this message translates to:
  /// **'ne northeast'**
  String get keywordsNorthEast;

  /// No description provided for @keywordsEast.
  ///
  /// In en, this message translates to:
  /// **'e east'**
  String get keywordsEast;

  /// No description provided for @keywordsSouthEast.
  ///
  /// In en, this message translates to:
  /// **'se southeast'**
  String get keywordsSouthEast;

  /// No description provided for @keywordsSouth.
  ///
  /// In en, this message translates to:
  /// **'s south'**
  String get keywordsSouth;

  /// No description provided for @keywordsSouthWest.
  ///
  /// In en, this message translates to:
  /// **'sw southwest'**
  String get keywordsSouthWest;

  /// No description provided for @keywordsWest.
  ///
  /// In en, this message translates to:
  /// **'w west'**
  String get keywordsWest;

  /// No description provided for @keywordsNorthWest.
  ///
  /// In en, this message translates to:
  /// **'nw northwest'**
  String get keywordsNorthWest;

  /// No description provided for @keywordsWindDirection.
  ///
  /// In en, this message translates to:
  /// **'wind direction'**
  String get keywordsWindDirection;

  /// No description provided for @keywordsMoon.
  ///
  /// In en, this message translates to:
  /// **'moon phase'**
  String get keywordsMoon;

  /// No description provided for @tideInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Tide'**
  String get tideInputTitle;

  /// No description provided for @tideInputLowTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Low: {value}'**
  String tideInputLowTimeValue(String value);

  /// No description provided for @tideInputHighTimeValue.
  ///
  /// In en, this message translates to:
  /// **'High: {value}'**
  String tideInputHighTimeValue(String value);

  /// No description provided for @tideInputDatumValue.
  ///
  /// In en, this message translates to:
  /// **'Datum: {value}'**
  String tideInputDatumValue(String value);

  /// No description provided for @tideInputFirstLowTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time of First Low Tide'**
  String get tideInputFirstLowTimeLabel;

  /// No description provided for @tideInputFirstHighTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time of First High Tide'**
  String get tideInputFirstHighTimeLabel;

  /// No description provided for @tideInputSecondLowTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time of Second Low Tide'**
  String get tideInputSecondLowTimeLabel;

  /// No description provided for @tideInputSecondHighTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time of Second High Tide'**
  String get tideInputSecondHighTimeLabel;

  /// No description provided for @tideTypeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tideTypeLow;

  /// No description provided for @tideTypeOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get tideTypeOutgoing;

  /// No description provided for @tideTypeHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tideTypeHigh;

  /// No description provided for @tideTypeSlack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get tideTypeSlack;

  /// No description provided for @tideTypeIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get tideTypeIncoming;

  /// No description provided for @tideLow.
  ///
  /// In en, this message translates to:
  /// **'Low Tide'**
  String get tideLow;

  /// No description provided for @tideOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing Tide'**
  String get tideOutgoing;

  /// No description provided for @tideHigh.
  ///
  /// In en, this message translates to:
  /// **'High Tide'**
  String get tideHigh;

  /// No description provided for @tideSlack.
  ///
  /// In en, this message translates to:
  /// **'Slack Tide'**
  String get tideSlack;

  /// No description provided for @tideIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming Tide'**
  String get tideIncoming;

  /// No description provided for @tideTimeAndHeight.
  ///
  /// In en, this message translates to:
  /// **'{height} at {time}'**
  String tideTimeAndHeight(String height, String time);

  /// No description provided for @saveBaitVariantPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bait Variant'**
  String get saveBaitVariantPageTitle;

  /// No description provided for @saveBaitVariantPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'New Bait Variant'**
  String get saveBaitVariantPageEditTitle;

  /// No description provided for @saveBaitVariantPageModelNumber.
  ///
  /// In en, this message translates to:
  /// **'Model Number'**
  String get saveBaitVariantPageModelNumber;

  /// No description provided for @saveBaitVariantPageSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get saveBaitVariantPageSize;

  /// No description provided for @saveBaitVariantPageMinDiveDepth.
  ///
  /// In en, this message translates to:
  /// **'Minimum Dive Depth'**
  String get saveBaitVariantPageMinDiveDepth;

  /// No description provided for @saveBaitVariantPageMaxDiveDepth.
  ///
  /// In en, this message translates to:
  /// **'Maximum Dive Depth'**
  String get saveBaitVariantPageMaxDiveDepth;

  /// No description provided for @saveBaitVariantPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get saveBaitVariantPageDescription;

  /// No description provided for @baitVariantPageVariantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant of'**
  String get baitVariantPageVariantLabel;

  /// No description provided for @baitVariantPageModel.
  ///
  /// In en, this message translates to:
  /// **'Model Number'**
  String get baitVariantPageModel;

  /// No description provided for @baitVariantPageSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get baitVariantPageSize;

  /// No description provided for @baitVariantPageDiveDepth.
  ///
  /// In en, this message translates to:
  /// **'Dive Depth'**
  String get baitVariantPageDiveDepth;

  /// No description provided for @baitTypeArtificial.
  ///
  /// In en, this message translates to:
  /// **'Artificial'**
  String get baitTypeArtificial;

  /// No description provided for @baitTypeReal.
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get baitTypeReal;

  /// No description provided for @baitTypeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get baitTypeLive;

  /// No description provided for @bodyOfWaterListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{bodyOfWater} is associated with {numOfSpots} fishing spots; are you sure you want to delete it? This cannot be undone.'**
  String bodyOfWaterListPageDeleteMessage(String bodyOfWater, int numOfSpots);

  /// No description provided for @bodyOfWaterListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{bodyOfWater} is associated with 1 fishing spot; are you sure you want to delete it? This cannot be undone.'**
  String bodyOfWaterListPageDeleteMessageSingular(String bodyOfWater);

  /// No description provided for @bodyOfWaterListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodies of Water ({numOfBodiesOfWater})'**
  String bodyOfWaterListPageTitle(int numOfBodiesOfWater);

  /// No description provided for @bodyOfWaterListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search bodies of water'**
  String get bodyOfWaterListPageSearchHint;

  /// No description provided for @bodyOfWaterListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bodies of Water'**
  String get bodyOfWaterListPageEmptyListTitle;

  /// No description provided for @bodyOfWaterListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any bodies of water. Tap the %s button to begin.'**
  String get bodyOfWaterListPageEmptyListDescription;

  /// No description provided for @bodiesOfWaterSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When bodies of water are added to your log, a summary of their catches will be shown here.'**
  String get bodiesOfWaterSummaryEmpty;

  /// No description provided for @saveBodyOfWaterPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Body of Water'**
  String get saveBodyOfWaterPageNewTitle;

  /// No description provided for @saveBodyOfWaterPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Body of Water'**
  String get saveBodyOfWaterPageEditTitle;

  /// No description provided for @saveBodyOfWaterPageExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'Body of water already exists'**
  String get saveBodyOfWaterPageExistsMessage;

  /// No description provided for @mapAttributionTitleApple.
  ///
  /// In en, this message translates to:
  /// **'Mapbox Maps SDK for iOS'**
  String get mapAttributionTitleApple;

  /// No description provided for @mapAttributionTitleAndroid.
  ///
  /// In en, this message translates to:
  /// **'Mapbox Maps SDK for Android'**
  String get mapAttributionTitleAndroid;

  /// No description provided for @mapAttributionMapbox.
  ///
  /// In en, this message translates to:
  /// **'© Mapbox'**
  String get mapAttributionMapbox;

  /// No description provided for @mapAttributionOpenStreetMap.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap'**
  String get mapAttributionOpenStreetMap;

  /// No description provided for @mapAttributionImproveThisMap.
  ///
  /// In en, this message translates to:
  /// **'Improve This Map'**
  String get mapAttributionImproveThisMap;

  /// No description provided for @mapAttributionMaxar.
  ///
  /// In en, this message translates to:
  /// **'© Maxar'**
  String get mapAttributionMaxar;

  /// No description provided for @mapAttributionTelemetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapbox Telemetry'**
  String get mapAttributionTelemetryTitle;

  /// No description provided for @mapAttributionTelemetryDescription.
  ///
  /// In en, this message translates to:
  /// **'Help make OpenStreetMap and Mapbox maps better by contributing anonymous usage data.'**
  String get mapAttributionTelemetryDescription;

  /// No description provided for @entityNameAnglers.
  ///
  /// In en, this message translates to:
  /// **'Anglers'**
  String get entityNameAnglers;

  /// No description provided for @entityNameAngler.
  ///
  /// In en, this message translates to:
  /// **'Angler'**
  String get entityNameAngler;

  /// No description provided for @entityNameBaitCategories.
  ///
  /// In en, this message translates to:
  /// **'Bait Categories'**
  String get entityNameBaitCategories;

  /// No description provided for @entityNameBaitCategory.
  ///
  /// In en, this message translates to:
  /// **'Bait Category'**
  String get entityNameBaitCategory;

  /// No description provided for @entityNameBaits.
  ///
  /// In en, this message translates to:
  /// **'Baits'**
  String get entityNameBaits;

  /// No description provided for @entityNameBait.
  ///
  /// In en, this message translates to:
  /// **'Bait'**
  String get entityNameBait;

  /// No description provided for @entityNameBodiesOfWater.
  ///
  /// In en, this message translates to:
  /// **'Bodies of Water'**
  String get entityNameBodiesOfWater;

  /// No description provided for @entityNameBodyOfWater.
  ///
  /// In en, this message translates to:
  /// **'Body of Water'**
  String get entityNameBodyOfWater;

  /// No description provided for @entityNameCatch.
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get entityNameCatch;

  /// No description provided for @entityNameCatches.
  ///
  /// In en, this message translates to:
  /// **'Catches'**
  String get entityNameCatches;

  /// No description provided for @entityNameCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields'**
  String get entityNameCustomFields;

  /// No description provided for @entityNameCustomField.
  ///
  /// In en, this message translates to:
  /// **'Custom Field'**
  String get entityNameCustomField;

  /// No description provided for @entityNameFishingMethods.
  ///
  /// In en, this message translates to:
  /// **'Fishing Methods'**
  String get entityNameFishingMethods;

  /// No description provided for @entityNameFishingMethod.
  ///
  /// In en, this message translates to:
  /// **'Fishing Method'**
  String get entityNameFishingMethod;

  /// No description provided for @entityNameGear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get entityNameGear;

  /// No description provided for @entityNameGpsTrails.
  ///
  /// In en, this message translates to:
  /// **'GPS Trails'**
  String get entityNameGpsTrails;

  /// No description provided for @entityNameGpsTrail.
  ///
  /// In en, this message translates to:
  /// **'GPS Trail'**
  String get entityNameGpsTrail;

  /// No description provided for @entityNameSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get entityNameSpecies;

  /// No description provided for @entityNameTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get entityNameTrip;

  /// No description provided for @entityNameTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get entityNameTrips;

  /// No description provided for @entityNameWaterClarities.
  ///
  /// In en, this message translates to:
  /// **'Water Clarities'**
  String get entityNameWaterClarities;

  /// No description provided for @entityNameWaterClarity.
  ///
  /// In en, this message translates to:
  /// **'Water Clarity'**
  String get entityNameWaterClarity;

  /// No description provided for @tripSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Summary'**
  String get tripSummaryTitle;

  /// No description provided for @tripSummaryTotalTripTime.
  ///
  /// In en, this message translates to:
  /// **'Total Trip Time'**
  String get tripSummaryTotalTripTime;

  /// No description provided for @tripSummaryLongestTrip.
  ///
  /// In en, this message translates to:
  /// **'Longest Trip'**
  String get tripSummaryLongestTrip;

  /// No description provided for @tripSummarySinceLastTrip.
  ///
  /// In en, this message translates to:
  /// **'Since Last Trip'**
  String get tripSummarySinceLastTrip;

  /// No description provided for @tripSummaryAverageTripTime.
  ///
  /// In en, this message translates to:
  /// **'Average Trip Time'**
  String get tripSummaryAverageTripTime;

  /// No description provided for @tripSummaryAverageTimeBetweenTrips.
  ///
  /// In en, this message translates to:
  /// **'Between Trips'**
  String get tripSummaryAverageTimeBetweenTrips;

  /// No description provided for @tripSummaryAverageTimeBetweenCatches.
  ///
  /// In en, this message translates to:
  /// **'Between Catches'**
  String get tripSummaryAverageTimeBetweenCatches;

  /// No description provided for @tripSummaryCatchesPerTrip.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Trip'**
  String get tripSummaryCatchesPerTrip;

  /// No description provided for @tripSummaryCatchesPerHour.
  ///
  /// In en, this message translates to:
  /// **'Catches Per Hour'**
  String get tripSummaryCatchesPerHour;

  /// No description provided for @tripSummaryWeightPerTrip.
  ///
  /// In en, this message translates to:
  /// **'Weight Per Trip'**
  String get tripSummaryWeightPerTrip;

  /// No description provided for @tripSummaryBestWeight.
  ///
  /// In en, this message translates to:
  /// **'Best Weight'**
  String get tripSummaryBestWeight;

  /// No description provided for @tripSummaryLengthPerTrip.
  ///
  /// In en, this message translates to:
  /// **'Length Per Trip'**
  String get tripSummaryLengthPerTrip;

  /// No description provided for @tripSummaryBestLength.
  ///
  /// In en, this message translates to:
  /// **'Best Length'**
  String get tripSummaryBestLength;

  /// No description provided for @backupPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupPageTitle;

  /// No description provided for @backupPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data is copied to a private folder in your Google Drive™ and is not shared publicly.\n\nThe backup process may take several minutes.'**
  String get backupPageDescription;

  /// No description provided for @backupPageAction.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupPageAction;

  /// No description provided for @backupPageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Error'**
  String get backupPageErrorTitle;

  /// No description provided for @backupPageAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically Backup'**
  String get backupPageAutoTitle;

  /// No description provided for @backupPageLastBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get backupPageLastBackupLabel;

  /// No description provided for @backupPageLastBackupNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get backupPageLastBackupNever;

  /// No description provided for @restorePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restorePageTitle;

  /// No description provided for @restorePageDescription.
  ///
  /// In en, this message translates to:
  /// **'Restoring data completely replaces your existing log with the data stored in Google Drive™. If there is no data, your log remains unchanged.\n\nThe restore process may take several minutes.'**
  String get restorePageDescription;

  /// No description provided for @restorePageAction.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restorePageAction;

  /// No description provided for @restorePageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Error'**
  String get restorePageErrorTitle;

  /// No description provided for @backupRestoreAuthError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error, please try again later.'**
  String get backupRestoreAuthError;

  /// No description provided for @backupRestoreAutoSignedOutError.
  ///
  /// In en, this message translates to:
  /// **'Auto-backup failed due to an authentication timeout. Please sign in again.'**
  String get backupRestoreAutoSignedOutError;

  /// No description provided for @backupRestoreAutoNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Auto-backup failed due to a network connectivity issue. Please do a manual backup or wait for the next auto-backup attempt.'**
  String get backupRestoreAutoNetworkError;

  /// No description provided for @backupRestoreCreateFolderError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup folder, please try again later.'**
  String get backupRestoreCreateFolderError;

  /// No description provided for @backupRestoreFolderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup folder not found. You must backup your data before it can be restored.'**
  String get backupRestoreFolderNotFound;

  /// No description provided for @backupRestoreApiRequestError.
  ///
  /// In en, this message translates to:
  /// **'The network may have been interrupted. Verify your internet connection and try again. If the issue persists, please send Anglers\'\' Log a report for investigation.'**
  String get backupRestoreApiRequestError;

  /// No description provided for @backupRestoreDatabaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup data file not found. You must backup your data before it can be restored.'**
  String get backupRestoreDatabaseNotFound;

  /// No description provided for @backupRestoreAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Anglers\'\' Log doesn\'\'t have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.'**
  String get backupRestoreAccessDenied;

  /// No description provided for @backupRestoreStorageFull.
  ///
  /// In en, this message translates to:
  /// **'Your Google Drive™ storage is full. Please free some space and try again.'**
  String get backupRestoreStorageFull;

  /// No description provided for @backupRestoreAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get backupRestoreAuthenticating;

  /// No description provided for @backupRestoreFetchingFiles.
  ///
  /// In en, this message translates to:
  /// **'Fetching data...'**
  String get backupRestoreFetchingFiles;

  /// No description provided for @backupRestoreCreatingFolder.
  ///
  /// In en, this message translates to:
  /// **'Creating backup folder...'**
  String get backupRestoreCreatingFolder;

  /// No description provided for @backupRestoreBackingUpDatabase.
  ///
  /// In en, this message translates to:
  /// **'Backing up database...'**
  String get backupRestoreBackingUpDatabase;

  /// No description provided for @backupRestoreDownloadingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Downloading database...'**
  String get backupRestoreDownloadingDatabase;

  /// No description provided for @backupRestoreDownloadingImages.
  ///
  /// In en, this message translates to:
  /// **'Downloading images{percent}...'**
  String backupRestoreDownloadingImages(String percent);

  /// No description provided for @backupRestoreReloadingData.
  ///
  /// In en, this message translates to:
  /// **'Reloading data...'**
  String get backupRestoreReloadingData;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get backupRestoreSuccess;

  /// No description provided for @cloudAuthSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get cloudAuthSignOut;

  /// No description provided for @cloudAuthSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get cloudAuthSignedInAs;

  /// No description provided for @cloudAuthSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get cloudAuthSignInWithGoogle;

  /// No description provided for @cloudAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'To continue, you must sign in to your Google account. Data is saved to a private Google Drive™ folder and can only be accessed by Anglers\'\' Log.'**
  String get cloudAuthDescription;

  /// No description provided for @cloudAuthError.
  ///
  /// In en, this message translates to:
  /// **'Error signing in, please try again later.'**
  String get cloudAuthError;

  /// No description provided for @cloudAuthNetworkError.
  ///
  /// In en, this message translates to:
  /// **'There was a network error while signing in. Please ensure you are connected to the internet and try again.'**
  String get cloudAuthNetworkError;

  /// No description provided for @asyncFeedbackSendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get asyncFeedbackSendReport;

  /// No description provided for @addAnythingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addAnythingTitle;

  /// No description provided for @proBlurUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get proBlurUpgradeButton;

  /// No description provided for @aboutPageVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutPageVersion;

  /// No description provided for @aboutPageEula.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get aboutPageEula;

  /// No description provided for @aboutPagePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPagePrivacy;

  /// No description provided for @aboutPageWorldTides.
  ///
  /// In en, this message translates to:
  /// **'WorldTides™ Privacy Policy'**
  String get aboutPageWorldTides;

  /// No description provided for @aboutPageWorldTidePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Tidal data retrieved from www.worldtides.info. Copyright © 2014-2023 Brainware LLC.\n\nLicensed for use of individual spatial coordinates by an end-user.\n\nNO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS TIDAL DATA.\nYou may not use this data if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).\n\nTidal data is obtained from various sources and is covered in part or whole by various copyrights. For details see: http://www.worldtides.info/copyright'**
  String get aboutPageWorldTidePrivacy;

  /// No description provided for @fishingSpotDetailsAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Details'**
  String get fishingSpotDetailsAddDetails;

  /// No description provided for @fishingSpotDetailsCatches.
  ///
  /// In en, this message translates to:
  /// **'{numOfCatches} Catches'**
  String fishingSpotDetailsCatches(int numOfCatches);

  /// No description provided for @fishingSpotDetailsCatch.
  ///
  /// In en, this message translates to:
  /// **'1 Catch'**
  String get fishingSpotDetailsCatch;

  /// No description provided for @timeZoneInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZoneInputLabel;

  /// No description provided for @timeZoneInputDescription.
  ///
  /// In en, this message translates to:
  /// **'Defaults to your current time zone.'**
  String get timeZoneInputDescription;

  /// No description provided for @timeZoneInputSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get timeZoneInputSearchHint;

  /// No description provided for @pollsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature Polls'**
  String get pollsPageTitle;

  /// No description provided for @pollsPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Vote to determine which features will be added in the next version of Anglers\'\' Log.'**
  String get pollsPageDescription;

  /// No description provided for @pollsPageNoPollsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Polls'**
  String get pollsPageNoPollsTitle;

  /// No description provided for @pollsPageNoPollsDescription.
  ///
  /// In en, this message translates to:
  /// **'There currently aren\'\'t any feature polls. If you\'\'d like to request a feature, please send us feedback!'**
  String get pollsPageNoPollsDescription;

  /// No description provided for @pollsPageSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get pollsPageSendFeedback;

  /// No description provided for @pollsPageNextFreeFeature.
  ///
  /// In en, this message translates to:
  /// **'Next Free Feature'**
  String get pollsPageNextFreeFeature;

  /// No description provided for @pollsPageNextProFeature.
  ///
  /// In en, this message translates to:
  /// **'Next Pro Feature'**
  String get pollsPageNextProFeature;

  /// No description provided for @pollsPageThankYouFree.
  ///
  /// In en, this message translates to:
  /// **'Thank you for voting in the free feature poll!'**
  String get pollsPageThankYouFree;

  /// No description provided for @pollsPageThankYouPro.
  ///
  /// In en, this message translates to:
  /// **'Thank you for voting in the pro feature poll!'**
  String get pollsPageThankYouPro;

  /// No description provided for @pollsPageError.
  ///
  /// In en, this message translates to:
  /// **'There was an error casting your vote. Please try again later.'**
  String get pollsPageError;

  /// No description provided for @pollsPageComingSoonFree.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon To Free Users (As Voted)'**
  String get pollsPageComingSoonFree;

  /// No description provided for @pollsPageComingSoonPro.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon To Pro Users (As Voted)'**
  String get pollsPageComingSoonPro;

  /// No description provided for @permissionLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get permissionLocationTitle;

  /// No description provided for @permissionCurrentLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'To show your current location, you must grant Anglers\'\' Log access to read your device\'\'s location. To do so, open your device settings.'**
  String get permissionCurrentLocationDescription;

  /// No description provided for @permissionGpsTrailDescription.
  ///
  /// In en, this message translates to:
  /// **'To create an accurate GPS trail, Anglers\'\' Log must be able to access your device\'\'s location at all times while tracking is active. To grant the required permission, open your device\'\'s settings.'**
  String get permissionGpsTrailDescription;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permissionOpenSettings;

  /// No description provided for @permissionLocationNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'GPS trail is active'**
  String get permissionLocationNotificationDescription;

  /// No description provided for @calendarPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarPageTitle;

  /// No description provided for @calendarPageTripLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get calendarPageTripLabel;

  /// No description provided for @gpsTrailListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Trails ({numOfTrails})'**
  String gpsTrailListPageTitle(int numOfTrails);

  /// No description provided for @gpsTrailListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search GPS trails'**
  String get gpsTrailListPageSearchHint;

  /// No description provided for @gpsTrailListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No GPS Trails'**
  String get gpsTrailListPageEmptyListTitle;

  /// No description provided for @gpsTrailListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'To start a GPS trail, tap the %s button on the map.'**
  String get gpsTrailListPageEmptyListDescription;

  /// No description provided for @gpsTrailListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'This GPS trail is associated with 1 trip; are you sure you want to delete it? This cannot be undone.'**
  String get gpsTrailListPageDeleteMessageSingular;

  /// No description provided for @gpsTrailListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This GPS trail is associated with {numOfTrips} trips; are you sure you want to delete it? This cannot be undone.'**
  String gpsTrailListPageDeleteMessage(int numOfTrips);

  /// No description provided for @gpsTrailListPageNumberOfPoints.
  ///
  /// In en, this message translates to:
  /// **'{numOfPoints} Points'**
  String gpsTrailListPageNumberOfPoints(int numOfPoints);

  /// No description provided for @gpsTrailListPageInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get gpsTrailListPageInProgress;

  /// No description provided for @saveGpsTrailPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit GPS Trail'**
  String get saveGpsTrailPageEditTitle;

  /// No description provided for @tideFetcherErrorNoLocationFound.
  ///
  /// In en, this message translates to:
  /// **'Fetch location is too far inland to determine tidal information.'**
  String get tideFetcherErrorNoLocationFound;

  /// No description provided for @csvPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get csvPageTitle;

  /// No description provided for @csvPageAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get csvPageAction;

  /// No description provided for @csvPageDescription.
  ///
  /// In en, this message translates to:
  /// **'A separate CSV file will be created for each selection below.'**
  String get csvPageDescription;

  /// No description provided for @csvPageImportWarning.
  ///
  /// In en, this message translates to:
  /// **'When importing into spreadsheet software, the file origin of the exported CSV file(s) is Unicode (UTF-8) and the delimiter is a comma.'**
  String get csvPageImportWarning;

  /// No description provided for @csvPageBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'CSV files are not backups, and cannot be imported into Anglers\'\' Log. Instead, use the Backup and Restore buttons on the More page.'**
  String get csvPageBackupWarning;

  /// No description provided for @csvPageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get csvPageSuccess;

  /// No description provided for @csvPageMustSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one export option above.'**
  String get csvPageMustSelect;

  /// No description provided for @tripFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get tripFieldStartDate;

  /// No description provided for @tripFieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get tripFieldEndDate;

  /// No description provided for @tripFieldStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get tripFieldStartTime;

  /// No description provided for @tripFieldEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get tripFieldEndTime;

  /// No description provided for @tripFieldPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get tripFieldPhotos;

  /// No description provided for @gearListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Gear ({numOfGear})'**
  String gearListPageTitle(int numOfGear);

  /// No description provided for @gearListPageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{gear} is associated with {numOfCatches} catches; are you sure you want to delete it? This cannot be undone.'**
  String gearListPageDeleteMessage(String gear, int numOfCatches);

  /// No description provided for @gearListPageDeleteMessageSingular.
  ///
  /// In en, this message translates to:
  /// **'{gear} is associated with 1 catch; are you sure you want to delete it? This cannot be undone.'**
  String gearListPageDeleteMessageSingular(String gear);

  /// No description provided for @gearListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search gear'**
  String get gearListPageSearchHint;

  /// No description provided for @gearListPageEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No Gear'**
  String get gearListPageEmptyListTitle;

  /// No description provided for @gearListPageEmptyListDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t yet added any gear. Tap the %s button to begin.'**
  String get gearListPageEmptyListDescription;

  /// No description provided for @gearSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'When gear is added to your log, a summary of their catches will be shown here.'**
  String get gearSummaryEmpty;

  /// No description provided for @gearActionXFast.
  ///
  /// In en, this message translates to:
  /// **'X-Fast'**
  String get gearActionXFast;

  /// No description provided for @gearActionFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get gearActionFast;

  /// No description provided for @gearActionModerateFast.
  ///
  /// In en, this message translates to:
  /// **'Moderate Fast'**
  String get gearActionModerateFast;

  /// No description provided for @gearActionModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get gearActionModerate;

  /// No description provided for @gearActionSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get gearActionSlow;

  /// No description provided for @gearPowerUltralight.
  ///
  /// In en, this message translates to:
  /// **'Ultralight'**
  String get gearPowerUltralight;

  /// No description provided for @gearPowerLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get gearPowerLight;

  /// No description provided for @gearPowerMediumLight.
  ///
  /// In en, this message translates to:
  /// **'Medium Light'**
  String get gearPowerMediumLight;

  /// No description provided for @gearPowerMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get gearPowerMedium;

  /// No description provided for @gearPowerMediumHeavy.
  ///
  /// In en, this message translates to:
  /// **'Medium Heavy'**
  String get gearPowerMediumHeavy;

  /// No description provided for @gearPowerHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get gearPowerHeavy;

  /// No description provided for @gearPowerXHeavy.
  ///
  /// In en, this message translates to:
  /// **'X-Heavy'**
  String get gearPowerXHeavy;

  /// No description provided for @gearPowerXxHeavy.
  ///
  /// In en, this message translates to:
  /// **'XX-Heavy'**
  String get gearPowerXxHeavy;

  /// No description provided for @gearPowerXxxHeavy.
  ///
  /// In en, this message translates to:
  /// **'XXX-Heavy'**
  String get gearPowerXxxHeavy;

  /// No description provided for @gearFieldImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get gearFieldImage;

  /// No description provided for @gearFieldRodMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Rod Made and Model'**
  String get gearFieldRodMakeModel;

  /// No description provided for @gearFieldRodSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Rod Serial Number'**
  String get gearFieldRodSerialNumber;

  /// No description provided for @gearFieldRodLength.
  ///
  /// In en, this message translates to:
  /// **'Rod Length'**
  String get gearFieldRodLength;

  /// No description provided for @gearFieldRodAction.
  ///
  /// In en, this message translates to:
  /// **'Rod Action'**
  String get gearFieldRodAction;

  /// No description provided for @gearFieldRodPower.
  ///
  /// In en, this message translates to:
  /// **'Rod Power'**
  String get gearFieldRodPower;

  /// No description provided for @gearFieldReelMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Reel Make and Model'**
  String get gearFieldReelMakeModel;

  /// No description provided for @gearFieldReelSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Reel Serial Number'**
  String get gearFieldReelSerialNumber;

  /// No description provided for @gearFieldReelSize.
  ///
  /// In en, this message translates to:
  /// **'Reel Size'**
  String get gearFieldReelSize;

  /// No description provided for @gearFieldLineMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Line Make and Model'**
  String get gearFieldLineMakeModel;

  /// No description provided for @gearFieldLineRating.
  ///
  /// In en, this message translates to:
  /// **'Line Rating'**
  String get gearFieldLineRating;

  /// No description provided for @gearFieldLineColor.
  ///
  /// In en, this message translates to:
  /// **'Line Color'**
  String get gearFieldLineColor;

  /// No description provided for @gearFieldLeaderLength.
  ///
  /// In en, this message translates to:
  /// **'Leader Length'**
  String get gearFieldLeaderLength;

  /// No description provided for @gearFieldLeaderRating.
  ///
  /// In en, this message translates to:
  /// **'Leader Rating'**
  String get gearFieldLeaderRating;

  /// No description provided for @gearFieldTippetLength.
  ///
  /// In en, this message translates to:
  /// **'Tippet Length'**
  String get gearFieldTippetLength;

  /// No description provided for @gearFieldTippetRating.
  ///
  /// In en, this message translates to:
  /// **'Tippet Rating'**
  String get gearFieldTippetRating;

  /// No description provided for @gearFieldHookMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Hook Make and Model'**
  String get gearFieldHookMakeModel;

  /// No description provided for @gearFieldHookSize.
  ///
  /// In en, this message translates to:
  /// **'Hook Size'**
  String get gearFieldHookSize;

  /// No description provided for @saveGearPageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Gear'**
  String get saveGearPageEditTitle;

  /// No description provided for @saveGearPageNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Gear'**
  String get saveGearPageNewTitle;

  /// No description provided for @saveGearPageNameExists.
  ///
  /// In en, this message translates to:
  /// **'Gear name already exists'**
  String get saveGearPageNameExists;

  /// No description provided for @gearPageSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number: {serialNo}'**
  String gearPageSerialNumber(String serialNo);

  /// No description provided for @gearPageSize.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String gearPageSize(String size);

  /// No description provided for @gearPageLeader.
  ///
  /// In en, this message translates to:
  /// **'Leader: {leader}'**
  String gearPageLeader(String leader);

  /// No description provided for @gearPageTippet.
  ///
  /// In en, this message translates to:
  /// **'Tippet: {tippet}'**
  String gearPageTippet(String tippet);

  /// No description provided for @notificationPermissionPageDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow Anglers\'\' Log to notify you if a data backup fails for any reason, including requiring re-authentication.'**
  String get notificationPermissionPageDesc;

  /// No description provided for @notificationErrorBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Error'**
  String get notificationErrorBackupTitle;

  /// No description provided for @notificationErrorBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Uh oh! Something went wrong while backing up your data. Tap here for details.'**
  String get notificationErrorBackupBody;

  /// No description provided for @notificationChannelNameBackup.
  ///
  /// In en, this message translates to:
  /// **'Data Backup'**
  String get notificationChannelNameBackup;

  /// No description provided for @speciesCounterPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Species Counter'**
  String get speciesCounterPageTitle;

  /// No description provided for @speciesCounterPageReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get speciesCounterPageReset;

  /// No description provided for @speciesCounterPageCreateTrip.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get speciesCounterPageCreateTrip;

  /// No description provided for @speciesCounterPageAddToTrip.
  ///
  /// In en, this message translates to:
  /// **'Append Trip'**
  String get speciesCounterPageAddToTrip;

  /// No description provided for @speciesCounterPageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Species'**
  String get speciesCounterPageSelect;

  /// No description provided for @speciesCounterPageTripUpdated.
  ///
  /// In en, this message translates to:
  /// **'Species counts added to {trip}.'**
  String speciesCounterPageTripUpdated(String trip);

  /// No description provided for @speciesCounterPageGeneralTripName.
  ///
  /// In en, this message translates to:
  /// **'trip'**
  String get speciesCounterPageGeneralTripName;

  /// No description provided for @locationDataFetcherErrorNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission is required to fetch data. Please grant Anglers\'\' Log the location permission and try again.'**
  String get locationDataFetcherErrorNoPermission;

  /// No description provided for @locationDataFetcherPermissionError.
  ///
  /// In en, this message translates to:
  /// **'There was an error requesting location permission. The Anglers\'\' Log team has been notified, and we apologize for the inconvenience.'**
  String get locationDataFetcherPermissionError;

  /// No description provided for @changeLogPageTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'\'s New'**
  String get changeLogPageTitle;

  /// No description provided for @changeLogPagePreviousVersion.
  ///
  /// In en, this message translates to:
  /// **'Your Previous Version'**
  String get changeLogPagePreviousVersion;

  /// No description provided for @changeLog_2022_1.
  ///
  /// In en, this message translates to:
  /// **'A complete rewrite of Anglers\'\' Log'**
  String get changeLog_2022_1;

  /// No description provided for @changeLog_2022_2.
  ///
  /// In en, this message translates to:
  /// **'A fresh and modern look and feel'**
  String get changeLog_2022_2;

  /// No description provided for @changeLog_2022_3.
  ///
  /// In en, this message translates to:
  /// **'A completely new, extensive and detailed statistics feature'**
  String get changeLog_2022_3;

  /// No description provided for @changeLog_2022_4.
  ///
  /// In en, this message translates to:
  /// **'Detailed atmosphere and weather data, including moon phases and tide'**
  String get changeLog_2022_4;

  /// No description provided for @changeLog_2022_5.
  ///
  /// In en, this message translates to:
  /// **'Get more out of Anglers\'\' Log by subscribing to Anglers\'\' Log Pro'**
  String get changeLog_2022_5;

  /// No description provided for @changeLog_2022_6.
  ///
  /// In en, this message translates to:
  /// **'Plus many more user-requested features'**
  String get changeLog_2022_6;

  /// No description provided for @changeLog_210_1.
  ///
  /// In en, this message translates to:
  /// **'In More > Feature Polls, you can now vote on what features you want to see next'**
  String get changeLog_210_1;

  /// No description provided for @changeLog_210_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where personal best photos\'\' corners weren\'\'t rounded'**
  String get changeLog_210_2;

  /// No description provided for @changeLog_210_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where catch quantity values weren\'\'t being counted on the Stats page'**
  String get changeLog_210_3;

  /// No description provided for @changeLog_210_4.
  ///
  /// In en, this message translates to:
  /// **'Automatic fishing spot picking distance is now configurable in Settings'**
  String get changeLog_210_4;

  /// No description provided for @changeLog_212_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash while importing legacy data'**
  String get changeLog_212_1;

  /// No description provided for @changeLog_212_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash while editing comparison reports'**
  String get changeLog_212_2;

  /// No description provided for @changeLog_212_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed map appearing for some users after returning to the foreground'**
  String get changeLog_212_3;

  /// No description provided for @changeLog_212_4.
  ///
  /// In en, this message translates to:
  /// **'Removed notes input field character limit'**
  String get changeLog_212_4;

  /// No description provided for @changeLog_213_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where data restoring would sometimes fail'**
  String get changeLog_213_1;

  /// No description provided for @changeLog_213_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash during legacy data migration'**
  String get changeLog_213_2;

  /// No description provided for @changeLog_213_3.
  ///
  /// In en, this message translates to:
  /// **'Performance improvements'**
  String get changeLog_213_3;

  /// No description provided for @changeLog_213_4.
  ///
  /// In en, this message translates to:
  /// **'Free users will no longer see ads'**
  String get changeLog_213_4;

  /// No description provided for @changeLog_215_1.
  ///
  /// In en, this message translates to:
  /// **'Improved efficiency of report calculations, which results in a smoother user experience'**
  String get changeLog_215_1;

  /// No description provided for @changeLog_216_1.
  ///
  /// In en, this message translates to:
  /// **'Fishing spot coordinates are now editable'**
  String get changeLog_216_1;

  /// No description provided for @changeLog_216_2.
  ///
  /// In en, this message translates to:
  /// **'Improved backup and restore error messages'**
  String get changeLog_216_2;

  /// No description provided for @changeLog_216_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where sometimes fishing spot \"Directions\" button didn\'\'t work'**
  String get changeLog_216_3;

  /// No description provided for @changeLog_216_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where the photo gallery would sometimes appear empty'**
  String get changeLog_216_4;

  /// No description provided for @changeLog_216_5.
  ///
  /// In en, this message translates to:
  /// **'Fixed several crashes'**
  String get changeLog_216_5;

  /// No description provided for @changeLog_220_1.
  ///
  /// In en, this message translates to:
  /// **'Added a calendar view of trips and catches to the \"More\" page'**
  String get changeLog_220_1;

  /// No description provided for @changeLog_220_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed multiple issues with displaying baits on the \"Stats\" page'**
  String get changeLog_220_2;

  /// No description provided for @changeLog_220_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash when photo data became unreadable'**
  String get changeLog_220_3;

  /// No description provided for @changeLog_230_1.
  ///
  /// In en, this message translates to:
  /// **'Add live GPS tracking that can be enabled by tapping the %s button on the map'**
  String get changeLog_230_1;

  /// No description provided for @changeLog_230_2.
  ///
  /// In en, this message translates to:
  /// **'Countries whose locale allows it, can now use commas as decimal points'**
  String get changeLog_230_2;

  /// No description provided for @changeLog_230_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where a photo\'\'s time and location weren\'\'t always used when adding a catch'**
  String get changeLog_230_3;

  /// No description provided for @changeLog_230_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed a bug where the wrong catches were being shown on the stats page'**
  String get changeLog_230_4;

  /// No description provided for @changeLog_230_5.
  ///
  /// In en, this message translates to:
  /// **'Minor UI bug fixes'**
  String get changeLog_230_5;

  /// No description provided for @changeLog_232_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where trip start and end times could not be set'**
  String get changeLog_232_1;

  /// No description provided for @changeLog_233_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where trip start and end dates weren\'\'t selectable from the \"Manage Fields\" menu'**
  String get changeLog_233_1;

  /// No description provided for @changeLog_233_2.
  ///
  /// In en, this message translates to:
  /// **'Some general stability improvements'**
  String get changeLog_233_2;

  /// No description provided for @changeLog_234_1.
  ///
  /// In en, this message translates to:
  /// **'You will now be warned when leaving a page without first pressing the \"SAVE\" button'**
  String get changeLog_234_1;

  /// No description provided for @changeLog_234_2.
  ///
  /// In en, this message translates to:
  /// **'A trip\'\'s manually set start time is now used when fetching atmosphere and weather data'**
  String get changeLog_234_2;

  /// No description provided for @changeLog_234_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where photos didn\'\'t show in the gallery when adding a catch'**
  String get changeLog_234_3;

  /// No description provided for @changeLog_234_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where the map wasn\'\'t always able to fetch your current location'**
  String get changeLog_234_4;

  /// No description provided for @changeLog_240_1.
  ///
  /// In en, this message translates to:
  /// **'Added support for Dark Mode'**
  String get changeLog_240_1;

  /// No description provided for @changeLog_240_2.
  ///
  /// In en, this message translates to:
  /// **'Removed decimal digits on a trip\'\'s length stats tiles'**
  String get changeLog_240_2;

  /// No description provided for @changeLog_240_3.
  ///
  /// In en, this message translates to:
  /// **'Stats time period selection is now saved across app launches'**
  String get changeLog_240_3;

  /// No description provided for @changeLog_240_4.
  ///
  /// In en, this message translates to:
  /// **'Added \"Sunny\" as a sky condition'**
  String get changeLog_240_4;

  /// No description provided for @changeLog_240_5.
  ///
  /// In en, this message translates to:
  /// **'Note fields can now include blank lines'**
  String get changeLog_240_5;

  /// No description provided for @changeLog_240_6.
  ///
  /// In en, this message translates to:
  /// **'Note fields are no longer truncated to 4 lines'**
  String get changeLog_240_6;

  /// No description provided for @changeLog_241_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed a crash while fetching atmosphere and weather data'**
  String get changeLog_241_1;

  /// No description provided for @changeLog_241_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed a rare crash while adding a catch'**
  String get changeLog_241_2;

  /// No description provided for @changeLog_241_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where the fishing spot was reset while adding a catch'**
  String get changeLog_241_3;

  /// No description provided for @changeLog_241_4.
  ///
  /// In en, this message translates to:
  /// **'When adding trips, you are now given the option to automatically set existing fields based on the selected catches'**
  String get changeLog_241_4;

  /// No description provided for @changeLog_241_5.
  ///
  /// In en, this message translates to:
  /// **'Several general stability improvements and crash fixes'**
  String get changeLog_241_5;

  /// No description provided for @changeLog_243_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed inaccurate fetched atmosphere and weather data'**
  String get changeLog_243_1;

  /// No description provided for @changeLog_250_1.
  ///
  /// In en, this message translates to:
  /// **'Tide data can now be fetched from WorldTides™'**
  String get changeLog_250_1;

  /// No description provided for @changeLog_250_2.
  ///
  /// In en, this message translates to:
  /// **'Added \"Evening\" time of day'**
  String get changeLog_250_2;

  /// No description provided for @changeLog_250_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where a fishing spot couldn\'\'t be added if it was too close to another spot'**
  String get changeLog_250_3;

  /// No description provided for @changeLog_250_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue inputting decimal values for languages that use commas as separators'**
  String get changeLog_250_4;

  /// No description provided for @changeLog_250_5.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where location couldn\'\'t be read from photos'**
  String get changeLog_250_5;

  /// No description provided for @changeLog_251_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where non-US locales couldn\'\'t change their measurement units'**
  String get changeLog_251_1;

  /// No description provided for @changeLog_252_1.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are now triggered on catch, trip, and bait changes'**
  String get changeLog_252_1;

  /// No description provided for @changeLog_252_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed duplicate negative sign on tide heights'**
  String get changeLog_252_2;

  /// No description provided for @changeLog_252_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where custom reports weren\'\'t tappable after upgrading to Pro'**
  String get changeLog_252_3;

  /// No description provided for @changeLog_252_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed empty catch length/weight values showing on stats catch lists'**
  String get changeLog_252_4;

  /// No description provided for @changeLog_260_1.
  ///
  /// In en, this message translates to:
  /// **'Pro users can now export their data to a spreadsheet via More > Export CSV.'**
  String get changeLog_260_1;

  /// No description provided for @changeLog_260_2.
  ///
  /// In en, this message translates to:
  /// **'All users can now add gear and attach them to catches.'**
  String get changeLog_260_2;

  /// No description provided for @changeLog_260_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where a bait\'\'s name would get cut off by the variant text in the bait list.'**
  String get changeLog_260_3;

  /// No description provided for @changeLog_260_4.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetched data is now updated when a catch\'\'s fishing spot changes.'**
  String get changeLog_260_4;

  /// No description provided for @changeLog_260_5.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere and weather data is now auto-fetched for trips.'**
  String get changeLog_260_5;

  /// No description provided for @changeLog_270_1.
  ///
  /// In en, this message translates to:
  /// **'Added a realtime species caught counter (Pro feature) to the More page.'**
  String get changeLog_270_1;

  /// No description provided for @changeLog_270_2.
  ///
  /// In en, this message translates to:
  /// **'Added a copy catch button (Pro feature) when viewing a catch.'**
  String get changeLog_270_2;

  /// No description provided for @changeLog_270_3.
  ///
  /// In en, this message translates to:
  /// **'Added a photo to bait variants.'**
  String get changeLog_270_3;

  /// No description provided for @changeLog_270_4.
  ///
  /// In en, this message translates to:
  /// **'Added water conditions to trips.'**
  String get changeLog_270_4;

  /// No description provided for @changeLog_270_5.
  ///
  /// In en, this message translates to:
  /// **'Added failed backup notifications.'**
  String get changeLog_270_5;

  /// No description provided for @changeLog_270_6.
  ///
  /// In en, this message translates to:
  /// **'Added low and high heights to tide charts.'**
  String get changeLog_270_6;

  /// No description provided for @changeLog_270_7.
  ///
  /// In en, this message translates to:
  /// **'Added meters per second as a wind speed unit option.'**
  String get changeLog_270_7;

  /// No description provided for @changeLog_270_8.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where reports would show the same data for different time periods.'**
  String get changeLog_270_8;

  /// No description provided for @changeLog_270_9.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where you couldn\'\'t choose the CSV save location on some devices.'**
  String get changeLog_270_9;

  /// No description provided for @changeLog_270_10.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where you couldn\'\'t share catches or trips on some devices.'**
  String get changeLog_270_10;

  /// No description provided for @changeLog_270_11.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where the Trip Summary report would show incorrect best length and weight values.'**
  String get changeLog_270_11;

  /// No description provided for @changeLog_270_12.
  ///
  /// In en, this message translates to:
  /// **'Fixed an erroneous network error when trying to send us feedback.'**
  String get changeLog_270_12;

  /// No description provided for @changeLog_270_13.
  ///
  /// In en, this message translates to:
  /// **'Fishing spot can now be skipped when adding a catch.'**
  String get changeLog_270_13;

  /// No description provided for @changeLog_270_14.
  ///
  /// In en, this message translates to:
  /// **'Fishing spot can now be removed from a catch.'**
  String get changeLog_270_14;

  /// No description provided for @changeLog_270_15.
  ///
  /// In en, this message translates to:
  /// **'Exported CSV files now include latitude, longitude, and custom fields columns.'**
  String get changeLog_270_15;

  /// No description provided for @changeLog_270_16.
  ///
  /// In en, this message translates to:
  /// **'The \"Skunked\" stamp now says \"Blanked\" for UK users.'**
  String get changeLog_270_16;

  /// No description provided for @changeLog_271_1.
  ///
  /// In en, this message translates to:
  /// **'Tide chart now shows y-axis labels in the correct unit.'**
  String get changeLog_271_1;

  /// No description provided for @changeLog_271_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue where some catch photos would be removed after an app update.'**
  String get changeLog_271_2;

  /// No description provided for @changeLog_272_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash when opening external links.'**
  String get changeLog_272_1;

  /// No description provided for @changeLog_273_1.
  ///
  /// In en, this message translates to:
  /// **'Added number of catches to fishing spot details.'**
  String get changeLog_273_1;

  /// No description provided for @changeLog_273_2.
  ///
  /// In en, this message translates to:
  /// **'Added tide datum value to tide details.'**
  String get changeLog_273_2;

  /// No description provided for @changeLog_273_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed unreliable zooming on photos.'**
  String get changeLog_273_3;

  /// No description provided for @changeLog_273_4.
  ///
  /// In en, this message translates to:
  /// **'Fixed error fetching weather data.'**
  String get changeLog_273_4;

  /// No description provided for @changeLog_273_5.
  ///
  /// In en, this message translates to:
  /// **'Fixed tide height values.'**
  String get changeLog_273_5;

  /// No description provided for @changeLog_273_6.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash starting GPS trails.'**
  String get changeLog_273_6;

  /// No description provided for @changeLog_273_7.
  ///
  /// In en, this message translates to:
  /// **'Fixed cut off text on stats bar charts.'**
  String get changeLog_273_7;

  /// No description provided for @changeLog_274_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed issue adding text to some text fields.'**
  String get changeLog_274_1;

  /// No description provided for @changeLog_275_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed the decimal being removed from a catch\'\'s weight.'**
  String get changeLog_275_1;

  /// No description provided for @changeLog_275_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed some incorrect rounding of water temperatures.'**
  String get changeLog_275_2;

  /// No description provided for @changeLog_275_3.
  ///
  /// In en, this message translates to:
  /// **'Added a \"not importable\" warning to CSV exporting.'**
  String get changeLog_275_3;

  /// No description provided for @changeLog_276_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed number formatting in some regions.'**
  String get changeLog_276_1;

  /// No description provided for @changeLog_277_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash when device\'\'s location was turned off.'**
  String get changeLog_277_1;

  /// No description provided for @changeLog_277_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed rare crash while onboarding.'**
  String get changeLog_277_2;

  /// No description provided for @changeLog_277_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed number formatting for users in Norway.'**
  String get changeLog_277_3;

  /// No description provided for @changeLog_278_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed a crash when requesting location permission.'**
  String get changeLog_278_1;

  /// No description provided for @changeLog_278_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed the app freezing on startup for users in certain regions.'**
  String get changeLog_278_2;

  /// No description provided for @translationWarningPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translationWarningPageTitle;

  /// No description provided for @translationWarningPageDescription.
  ///
  /// In en, this message translates to:
  /// **'The text in Anglers\'\' Log has been translated using AI. If you notice a mistake, or something doesn\'\'t make sense, please reach out by tapping More, then Send Feedback. Your help is always appreciated, thank you!'**
  String get translationWarningPageDescription;

  /// No description provided for @backupRestorePageOpenDoc.
  ///
  /// In en, this message translates to:
  /// **'Open Documentation'**
  String get backupRestorePageOpenDoc;

  /// No description provided for @backupRestorePageWarningApple.
  ///
  /// In en, this message translates to:
  /// **'The backup and restore feature has proven to be unreliable, and we are considering other options. In the meantime, it is highly recommended that you setup automatic backups for your entire device to ensure no data is lost. For more information, visit Apple\'\'s documentation.'**
  String get backupRestorePageWarningApple;

  /// No description provided for @backupRestorePageWarningGoogle.
  ///
  /// In en, this message translates to:
  /// **'The backup and restore feature has proven to be unreliable, and we are considering other options. In the meantime, it is highly recommended that you setup automatic backups for your entire device to ensure no data is lost. For more information, visit Google\'\'s documentation.'**
  String get backupRestorePageWarningGoogle;

  /// No description provided for @backupRestorePageWarningOwnRisk.
  ///
  /// In en, this message translates to:
  /// **'Use this feature at your own risk.'**
  String get backupRestorePageWarningOwnRisk;

  /// No description provided for @proPageBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'Auto-backup has proven to be unreliable. Use this feature at your own risk while we investigate. For more details, visit the Backup and Restore pages in the More menu.'**
  String get proPageBackupWarning;

  /// No description provided for @changeLog_279_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed some user interface bugs.'**
  String get changeLog_279_1;

  /// No description provided for @changeLog_279_2.
  ///
  /// In en, this message translates to:
  /// **'Added a warning to reflect the unreliability of cloud backup.'**
  String get changeLog_279_2;

  /// No description provided for @changeLog_279_3.
  ///
  /// In en, this message translates to:
  /// **'Add Spanish translations.'**
  String get changeLog_279_3;

  /// No description provided for @changeLog_2710_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed large number formatting for regions that use apostrophes.'**
  String get changeLog_2710_1;

  /// No description provided for @changeLog_2710_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed some text alignment issues on the Pro page.'**
  String get changeLog_2710_2;

  /// No description provided for @changeLog_2711_1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an error sending feedback without an email address.'**
  String get changeLog_2711_1;

  /// No description provided for @changeLog_2711_2.
  ///
  /// In en, this message translates to:
  /// **'Catches can now be added while adding Trips without closing the save Trip page.'**
  String get changeLog_2711_2;

  /// No description provided for @changeLog_2711_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed missing \"Since Last Catch\" and \"Since Last Trip\" stats tiles.'**
  String get changeLog_2711_3;

  /// No description provided for @feedbackPageSendData.
  ///
  /// In en, this message translates to:
  /// **'Send Data'**
  String get feedbackPageSendData;

  /// No description provided for @feedbackPageSendDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Your log data, excluding photos, will be sent to help our investigation.'**
  String get feedbackPageSendDataDescription;

  /// No description provided for @changeLog_2712_1.
  ///
  /// In en, this message translates to:
  /// **'Added option to include log data in bug reports.'**
  String get changeLog_2712_1;

  /// No description provided for @changeLog_2712_2.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash while voting in feature polls.'**
  String get changeLog_2712_2;

  /// No description provided for @changeLog_2712_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed crash while adding or updating catches.'**
  String get changeLog_2712_3;

  /// No description provided for @backupRestoreBackingUpData.
  ///
  /// In en, this message translates to:
  /// **'Backing up data{percent}...'**
  String backupRestoreBackingUpData(String percent);

  /// No description provided for @changeLog_2713_1.
  ///
  /// In en, this message translates to:
  /// **'Backing up and restoring is now much faster.'**
  String get changeLog_2713_1;
}

class _AnglersLogLocalizationsDelegate
    extends LocalizationsDelegate<AnglersLogLocalizations> {
  const _AnglersLogLocalizationsDelegate();

  @override
  Future<AnglersLogLocalizations> load(Locale locale) {
    return SynchronousFuture<AnglersLogLocalizations>(
      lookupAnglersLogLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AnglersLogLocalizationsDelegate old) => false;
}

AnglersLogLocalizations lookupAnglersLogLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AnglersLogLocalizationsEnGb();
          case 'US':
            return AnglersLogLocalizationsEnUs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AnglersLogLocalizationsEn();
    case 'es':
      return AnglersLogLocalizationsEs();
  }

  throw FlutterError(
    'AnglersLogLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
