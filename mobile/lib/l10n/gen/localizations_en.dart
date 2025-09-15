// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AnglersLogLocalizationsEn extends AnglersLogLocalizations {
  AnglersLogLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get catchFieldFavorite => 'Favourite';

  @override
  String get catchFieldFavoriteDescription =>
      'Whether a catch was one of your favourites.';

  @override
  String get saveReportPageFavorites => 'Favourites Only';

  @override
  String get saveReportPageFavoritesFilter => 'Favourites only';

  @override
  String unitsPageCentimeters(String value) {
    return 'Centimetres ($value)';
  }

  @override
  String unitsPageMeters(String value) {
    return 'Metres ($value)';
  }

  @override
  String unitsPageAirVisibilityKilometers(String value) {
    return 'Kilometres ($value)';
  }

  @override
  String unitsPageWindSpeedKilometers(String value) {
    return 'Kilometres per hour ($value)';
  }

  @override
  String unitsPageWindSpeedMeters(String value) {
    return 'Metres per second ($value)';
  }

  @override
  String get keywordsSpeedMetric => 'kilometers kilometres per hour speed wind';

  @override
  String get inputColorLabel => 'Colour';

  @override
  String get appName => 'Anglers\' Log';

  @override
  String get hashtag => '#AnglersLogApp';

  @override
  String get shareTextAndroid => 'Shared with #AnglersLogApp for Android.';

  @override
  String get shareTextApple => 'Shared with #AnglersLogApp for iOS.';

  @override
  String shareLength(String value) {
    return 'Length: $value';
  }

  @override
  String shareWeight(String value) {
    return 'Weight: $value';
  }

  @override
  String shareBait(String value) {
    return 'Bait: $value';
  }

  @override
  String shareBaits(String value) {
    return 'Baits: $value';
  }

  @override
  String shareCatches(int value) {
    return 'Catches: $value';
  }

  @override
  String get rateDialogTitle => 'Rate Anglers\' Log';

  @override
  String get rateDialogDescription =>
      'Please take a moment to write a review of Anglers\' Log. All feedback is greatly appreciated!';

  @override
  String get rateDialogRate => 'Rate';

  @override
  String get rateDialogLater => 'Later';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get none => 'None';

  @override
  String get all => 'All';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get clear => 'Clear';

  @override
  String get directions => 'Directions';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String latLng(String lat, String lng) {
    return 'Lat: $lat, Lng: $lng';
  }

  @override
  String latLngNoLabels(String lat, String lng) {
    return '$lat, $lng';
  }

  @override
  String get add => 'Add';

  @override
  String get more => 'More';

  @override
  String get na => 'N/A';

  @override
  String get finish => 'Finish';

  @override
  String get by => 'by';

  @override
  String get unknown => 'Unknown';

  @override
  String get devName => 'Cohen Adair';

  @override
  String numberOfCatches(int numOfCatches) {
    return '$numOfCatches Catches';
  }

  @override
  String get numberOfCatchesSingular => '1 Catch';

  @override
  String get unknownSpecies => 'Unknown Species';

  @override
  String get unknownBait => 'Unknown Bait';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewAll => 'View All';

  @override
  String get share => 'Share';

  @override
  String get fieldTypeNumber => 'Number';

  @override
  String get fieldTypeBoolean => 'Checkbox';

  @override
  String get fieldTypeText => 'Text';

  @override
  String inputRequiredMessage(String inputLabel) {
    return '$inputLabel is required';
  }

  @override
  String get inputNameLabel => 'Name';

  @override
  String get inputGenericRequired => 'Required';

  @override
  String get inputDescriptionLabel => 'Description';

  @override
  String get inputNotesLabel => 'Notes';

  @override
  String get inputInvalidNumber => 'Invalid number input';

  @override
  String get inputPhotoLabel => 'Photo';

  @override
  String get inputPhotosLabel => 'Add Photos';

  @override
  String get inputNotSelected => 'Not Selected';

  @override
  String get inputEmailLabel => 'Email';

  @override
  String get inputInvalidEmail => 'Invalid email format';

  @override
  String get inputAtmosphere => 'Atmosphere and Weather';

  @override
  String get inputFetch => 'Fetch';

  @override
  String get inputAutoFetch => 'Auto-fetch';

  @override
  String get inputCurrentLocation => 'Current Location';

  @override
  String get inputGenericFetchError =>
      'Unable to fetch data at this time. Please ensure your device is connected to the internet and try again.';

  @override
  String get fieldWaterClarityLabel => 'Water Clarity';

  @override
  String get fieldWaterDepthLabel => 'Water Depth';

  @override
  String get fieldWaterTemperatureLabel => 'Water Temperature';

  @override
  String catchListPageTitle(int numOfCatches) {
    return 'Catches ($numOfCatches)';
  }

  @override
  String get catchListPageSearchHint => 'Search catches';

  @override
  String get catchListPageEmptyListTitle => 'No Catches';

  @override
  String get catchListPageEmptyListDescription =>
      'You haven\'t yet added any catches. Tap the %s button to begin.';

  @override
  String catchListItemLength(String value) {
    return 'Length: $value';
  }

  @override
  String catchListItemWeight(String value) {
    return 'Weight: $value';
  }

  @override
  String get catchListItemNotSet => '-';

  @override
  String catchPageDeleteMessage(String value) {
    return 'Are you sure you want to delete catch $value? This cannot be undone.';
  }

  @override
  String catchPageDeleteWithTripMessage(String value) {
    return '$value is associated with a trip; Are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get catchPageReleased => 'Released';

  @override
  String get catchPageKept => 'Kept';

  @override
  String catchPageQuantityLabel(int value) {
    return 'Quantity: $value';
  }

  @override
  String get saveCatchPageNewTitle => 'New Catch';

  @override
  String get saveCatchPageEditTitle => 'Edit Catch';

  @override
  String get catchFieldTide => 'Tide';

  @override
  String get catchFieldDateTime => 'Date and Time';

  @override
  String get catchFieldDate => 'Date';

  @override
  String get catchFieldTime => 'Time';

  @override
  String get catchFieldPeriod => 'Time of Day';

  @override
  String get catchFieldPeriodDescription => 'Such as dawn, morning, dusk, etc.';

  @override
  String get catchFieldSeason => 'Season';

  @override
  String get catchFieldSeasonDescription =>
      'Winter, spring, summer, or autumn.';

  @override
  String get catchFieldImages => 'Photos';

  @override
  String get catchFieldFishingSpot => 'Fishing Spot';

  @override
  String get catchFieldFishingSpotDescription =>
      'Coordinates of where a catch was made.';

  @override
  String get catchFieldBait => 'Bait';

  @override
  String get catchFieldAngler => 'Angler';

  @override
  String get catchFieldGear => 'Gear';

  @override
  String get catchFieldMethodsDescription =>
      'The way in which a catch was made.';

  @override
  String get catchFieldNoMethods => 'No fishing methods';

  @override
  String get catchFieldNoBaits => 'No baits';

  @override
  String get catchFieldNoGear => 'No gear';

  @override
  String get catchFieldCatchAndRelease => 'Catch and Release';

  @override
  String get catchFieldCatchAndReleaseDescription =>
      'Whether or not this catch was released.';

  @override
  String get catchFieldTideHeightLabel => 'Tide Height';

  @override
  String get catchFieldLengthLabel => 'Length';

  @override
  String get catchFieldWeightLabel => 'Weight';

  @override
  String get catchFieldQuantityLabel => 'Quantity';

  @override
  String get catchFieldQuantityDescription =>
      'The number of the selected species caught.';

  @override
  String get catchFieldNotesLabel => 'Notes';

  @override
  String get saveReportPageNewTitle => 'New Report';

  @override
  String get saveReportPageEditTitle => 'Edit Report';

  @override
  String get saveReportPageNameExists => 'Report name already exists';

  @override
  String get saveReportPageTypeTitle => 'Type';

  @override
  String get saveReportPageComparison => 'Comparison';

  @override
  String get saveReportPageSummary => 'Summary';

  @override
  String get saveReportPageStartDateRangeLabel => 'Compare';

  @override
  String get saveReportPageEndDateRangeLabel => 'To';

  @override
  String get saveReportPageAllAnglers => 'All anglers';

  @override
  String get saveReportPageAllWaterClarities => 'All water clarities';

  @override
  String get saveReportPageAllSpecies => 'All species';

  @override
  String get saveReportPageAllBaits => 'All baits';

  @override
  String get saveReportPageAllGear => 'All gear';

  @override
  String get saveReportPageAllBodiesOfWater => 'All bodies of water';

  @override
  String get saveReportPageAllFishingSpots => 'All fishing spots';

  @override
  String get saveReportPageAllMethods => 'All fishing methods';

  @override
  String get saveReportPageCatchAndRelease => 'Catch and Release Only';

  @override
  String get saveReportPageCatchAndReleaseFilter => 'Catch and release only';

  @override
  String get saveReportPageAllWindDirections => 'All wind directions';

  @override
  String get saveReportPageAllSkyConditions => 'All sky conditions';

  @override
  String get saveReportPageAllMoonPhases => 'All moon phases';

  @override
  String get saveReportPageAllTideTypes => 'All tides';

  @override
  String get photosPageMenuLabel => 'Photos';

  @override
  String photosPageTitle(int numOfPhotos) {
    return 'Photos ($numOfPhotos)';
  }

  @override
  String get photosPageEmptyTitle => 'No Photos';

  @override
  String get photosPageEmptyDescription =>
      'All photos attached to catches will be displayed here. To add a catch, tap the %s icon.';

  @override
  String baitListPageTitle(int numOfBaits) {
    return 'Baits ($numOfBaits)';
  }

  @override
  String get baitListPageOtherCategory => 'No Category';

  @override
  String get baitListPageSearchHint => 'Search baits';

  @override
  String baitListPageDeleteMessage(String bait, int numOfCatches) {
    return '$bait is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String baitListPageDeleteMessageSingular(String bait) {
    return '$bait is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get baitListPageEmptyListTitle => 'No Baits';

  @override
  String get baitListPageEmptyListDescription =>
      'You haven\'t yet added any baits. Tap the %s button to begin.';

  @override
  String get baitsSummaryEmpty =>
      'When baits are added to your log, a summary of their catches will be shown here.';

  @override
  String baitListPageVariantsLabel(int numOfVariants) {
    return '$numOfVariants Variants';
  }

  @override
  String get baitListPageVariantLabel => '1 Variant';

  @override
  String get saveBaitPageNewTitle => 'New Bait';

  @override
  String get saveBaitPageEditTitle => 'Edit Bait';

  @override
  String get saveBaitPageCategoryLabel => 'Bait Category';

  @override
  String get saveBaitPageBaitExists =>
      'A bait with these properties already exists. Please change at least one field and try again.';

  @override
  String get saveBaitPageVariants => 'Variants';

  @override
  String get saveBaitPageDeleteVariantSingular =>
      'This variant is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';

  @override
  String saveBaitPageDeleteVariantPlural(int numOfCatches) {
    return 'This variant is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get saveBaitCategoryPageNewTitle => 'New Bait Category';

  @override
  String get saveBaitCategoryPageEditTitle => 'Edit Bait Category';

  @override
  String get saveBaitCategoryPageExistsMessage =>
      'Bait category already exists';

  @override
  String baitCategoryListPageTitle(int numOfCategories) {
    return 'Bait Categories ($numOfCategories)';
  }

  @override
  String baitCategoryListPageDeleteMessage(String bait, int numOfBaits) {
    return '$bait is associated with $numOfBaits baits; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String baitCategoryListPageDeleteMessageSingular(String category) {
    return '$category is associated with 1 bait; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get baitCategoryListPageSearchHint => 'Search bait categories';

  @override
  String get baitCategoryListPageEmptyListTitle => 'No Bait Categories';

  @override
  String get baitCategoryListPageEmptyListDescription =>
      'You haven\'t yet added any bait categories. Tap the %s button to begin.';

  @override
  String get saveAnglerPageNewTitle => 'New Angler';

  @override
  String get saveAnglerPageEditTitle => 'Edit Angler';

  @override
  String get saveAnglerPageExistsMessage => 'Angler already exists';

  @override
  String anglerListPageTitle(int numOfAnglers) {
    return 'Anglers ($numOfAnglers)';
  }

  @override
  String anglerListPageDeleteMessage(String angler, int numOfCatches) {
    return '$angler is associated with $numOfCatches catches; are you sure you want to delete them? This cannot be undone.';
  }

  @override
  String anglerListPageDeleteMessageSingular(String angler) {
    return '$angler is associated with 1 catch; are you sure you want to delete them? This cannot be undone.';
  }

  @override
  String get anglerListPageSearchHint => 'Search anglers';

  @override
  String get anglerListPageEmptyListTitle => 'No Anglers';

  @override
  String get anglerListPageEmptyListDescription =>
      'You haven\'t yet added any anglers. Tap the %s button to begin.';

  @override
  String get anglersSummaryEmpty =>
      'When anglers are added to your log, a summary of their catches will be shown here.';

  @override
  String get saveMethodPageNewTitle => 'New Fishing Method';

  @override
  String get saveMethodPageEditTitle => 'Edit Fishing Method';

  @override
  String get saveMethodPageExistsMessage => 'Fishing method already exists';

  @override
  String methodListPageTitle(int numOfMethods) {
    return 'Fishing Methods ($numOfMethods)';
  }

  @override
  String methodListPageDeleteMessage(String method, int numOfCatches) {
    return '$method is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String methodListPageDeleteMessageSingular(String method) {
    return '$method is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get methodListPageSearchHint => 'Search fishing methods';

  @override
  String get methodListPageEmptyListTitle => 'No Fishing Methods';

  @override
  String get methodListPageEmptyListDescription =>
      'You haven\'t yet added any fishing methods. Tap the %s button to begin.';

  @override
  String get methodSummaryEmpty =>
      'When fishing methods are added to your log, a summary of their catches will be shown here.';

  @override
  String get saveWaterClarityPageNewTitle => 'New Water Clarity';

  @override
  String get saveWaterClarityPageEditTitle => 'Edit Water Clarity';

  @override
  String get saveWaterClarityPageExistsMessage =>
      'Water Clarity already exists';

  @override
  String waterClarityListPageTitle(int numOfClarities) {
    return 'Water Clarities ($numOfClarities)';
  }

  @override
  String waterClarityListPageDeleteMessage(String clarity, int numOfCatches) {
    return '$clarity is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String waterClarityListPageDeleteMessageSingular(String clarity) {
    return '$clarity is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get waterClarityListPageSearchHint => 'Search water clarities';

  @override
  String get waterClarityListPageEmptyListTitle => 'No Water Clarities';

  @override
  String get waterClarityListPageEmptyListDescription =>
      'You haven\'t yet added any water clarities. Tap the %s button to begin.';

  @override
  String get waterClaritiesSummaryEmpty =>
      'When water clarities are added to your log, a summary of their catches will be shown here.';

  @override
  String get statsPageMenuTitle => 'Stats';

  @override
  String get statsPageTitle => 'Stats';

  @override
  String get statsPageNewReport => 'New Report';

  @override
  String get statsPageSpeciesSummary => 'Species Summary';

  @override
  String get statsPageCatchSummary => 'Catch Summary';

  @override
  String get statsPageAnglerSummary => 'Angler Summary';

  @override
  String get statsPageBaitSummary => 'Bait Summary';

  @override
  String statsPageBaitVariantAllLabel(String bait) {
    return '$bait (All Variants)';
  }

  @override
  String get statsPageBodyOfWaterSummary => 'Body of Water Summary';

  @override
  String get statsPageFishingSpotSummary => 'Fishing Spot Summary';

  @override
  String get statsPageMethodSummary => 'Fishing Method Summary';

  @override
  String get statsPageMoonPhaseSummary => 'Moon Phase Summary';

  @override
  String get statsPagePeriodSummary => 'Time of Day Summary';

  @override
  String get statsPageSeasonSummary => 'Season Summary';

  @override
  String get statsPageTideSummary => 'Tide Summary';

  @override
  String get statsPageWaterClaritySummary => 'Water Clarity Summary';

  @override
  String get statsPageGearSummary => 'Gear Summary';

  @override
  String get statsPagePersonalBests => 'Personal Bests';

  @override
  String get personalBestsTrip => 'Best Trip';

  @override
  String get personalBestsLongest => 'Longest';

  @override
  String get personalBestsHeaviest => 'Heaviest';

  @override
  String get personalBestsSpeciesByLength => 'Species By Length';

  @override
  String get personalBestsSpeciesByLengthLabel => 'Longest';

  @override
  String get personalBestsSpeciesByWeight => 'Species By Weight';

  @override
  String get personalBestsSpeciesByWeightLabel => 'Heaviest';

  @override
  String get personalBestsShowAllSpecies => 'View all species';

  @override
  String get personalBestsAverage => 'Average';

  @override
  String get personalBestsNoDataTitle => 'No Data';

  @override
  String get personalBestsNoDataDescription =>
      'Cannot determine your personal bests for the selected date range. Ensure you’ve added a trip, or added a catch with a length or weight value.';

  @override
  String get reportViewEmptyLog => 'Empty Log';

  @override
  String get reportViewEmptyLogDescription =>
      'You haven\'t yet added any catches. To add a catch, tap the %s icon.';

  @override
  String get reportViewNoCatches => 'No catches found';

  @override
  String get reportViewNoCatchesDescription =>
      'No catches found in the selected date range.';

  @override
  String get reportViewNoCatchesReportDescription =>
      'No catches found in the selected report\'s date range.';

  @override
  String get reportSummaryCatchTitle => 'Catch Summary';

  @override
  String get reportSummaryPerSpecies => 'Per Species';

  @override
  String get reportSummaryPerFishingSpot => 'Per Fishing Spot';

  @override
  String get reportSummaryPerBait => 'Per Bait';

  @override
  String get reportSummaryPerAngler => 'Per Angler';

  @override
  String get reportSummaryPerBodyOfWater => 'Per Body of Water';

  @override
  String get reportSummaryPerMethod => 'Per Fishing Method';

  @override
  String get reportSummaryPerMoonPhase => 'Per Moon Phase';

  @override
  String get reportSummaryPerPeriod => 'Per Time of Day';

  @override
  String get reportSummaryPerSeason => 'Per Season';

  @override
  String get reportSummaryPerTideType => 'Per Tide';

  @override
  String get reportSummaryPerWaterClarity => 'Per Water Clarity';

  @override
  String get reportSummarySinceLastCatch => 'Since Last Catch';

  @override
  String get reportSummaryNumberOfCatches => 'Number of catches';

  @override
  String get reportSummaryFilters => 'Filters';

  @override
  String get reportSummaryViewSpecies => 'View all species';

  @override
  String get reportSummaryPerSpeciesDescription =>
      'Viewing number of catches per species.';

  @override
  String get reportSummaryViewFishingSpots => 'View all fishing spots';

  @override
  String get reportSummaryPerFishingSpotDescription =>
      'Viewing number of catches per fishing spot.';

  @override
  String get reportSummaryViewBaits => 'View all baits';

  @override
  String get reportSummaryPerBaitDescription =>
      'Viewing number of catches per bait.';

  @override
  String get reportSummaryViewMoonPhases => 'View all moon phases';

  @override
  String get reportSummaryPerMoonPhaseDescription =>
      'Viewing number of catches per moon phase.';

  @override
  String get reportSummaryViewTides => 'View all tide types';

  @override
  String get reportSummaryPerTideDescription =>
      'Viewing number of catches per tide type.';

  @override
  String get reportSummaryViewAnglers => 'View all anglers';

  @override
  String get reportSummaryPerAnglerDescription =>
      'Viewing number of catches per angler.';

  @override
  String get reportSummaryViewBodiesOfWater => 'View all bodies of water';

  @override
  String get reportSummaryPerBodyOfWaterDescription =>
      'Viewing number of catches per body of water.';

  @override
  String get reportSummaryViewMethods => 'View all fishing methods';

  @override
  String get reportSummaryPerMethodDescription =>
      'Viewing number of catches per fishing method.';

  @override
  String get reportSummaryViewPeriods => 'View all times of day';

  @override
  String get reportSummaryPerPeriodDescription =>
      'Viewing number of catches per time of day.';

  @override
  String get reportSummaryViewSeasons => 'View all seasons';

  @override
  String get reportSummaryPerSeasonDescription =>
      'Viewing number of catches per season.';

  @override
  String get reportSummaryViewWaterClarities => 'View all water clarities';

  @override
  String get reportSummaryPerWaterClarityDescription =>
      'Viewing number of catches per water clarity.';

  @override
  String get reportSummaryPerHour => 'Per Hour';

  @override
  String get reportSummaryViewAllHours => 'View all hours';

  @override
  String get reportSummaryViewAllHoursDescription =>
      'Viewing number of catches for each hour in the day.';

  @override
  String get reportSummaryPerMonth => 'Per Month';

  @override
  String get reportSummaryViewAllMonths => 'View all months';

  @override
  String get reportSummaryViewAllMonthsDescription =>
      'Viewing number of catches for each month in the year.';

  @override
  String get reportSummaryPerGear => 'Per Gear';

  @override
  String get reportSummaryViewGear => 'View all gear';

  @override
  String get reportSummaryPerGearDescription =>
      'Viewing number of catches per gear.';

  @override
  String get morePageTitle => 'More';

  @override
  String get morePageRateApp => 'Rate Anglers\' Log';

  @override
  String get morePagePro => 'Anglers\' Log Pro';

  @override
  String get morePageRateErrorApple =>
      'Device does not have App Store installed.';

  @override
  String get morePageRateErrorAndroid =>
      'Device has no web browser app installed.';

  @override
  String tripListPageTitle(int numOfTrips) {
    return 'Trips ($numOfTrips)';
  }

  @override
  String get tripListPageSearchHint => 'Search trips';

  @override
  String get tripListPageEmptyListTitle => 'No Trips';

  @override
  String get tripListPageEmptyListDescription =>
      'You haven\'t yet added any trips. Tap the %s button to begin.';

  @override
  String tripListPageDeleteMessage(String trip) {
    return 'Are you sure you want to delete trip $trip? This cannot be undone.';
  }

  @override
  String get saveTripPageEditTitle => 'Edit Trip';

  @override
  String get saveTripPageNewTitle => 'New Trip';

  @override
  String get saveTripPageAutoSetTitle => 'Auto-set Fields';

  @override
  String get saveTripPageAutoSetDescription =>
      'Automatically set applicable fields when catches are selected.';

  @override
  String get saveTripPageStartDate => 'Start Date';

  @override
  String get saveTripPageStartTime => 'Start Time';

  @override
  String get saveTripPageStartDateTime => 'Start Date and Time';

  @override
  String get saveTripPageEndDate => 'End Date';

  @override
  String get saveTripPageEndTime => 'End Time';

  @override
  String get saveTripPageEndDateTime => 'End Date and Time';

  @override
  String get saveTripPageAllDay => 'All Day';

  @override
  String get saveTripPageCatchesDesc => 'Trophies logged on this trip.';

  @override
  String get saveTripPageNoCatches => 'No catches';

  @override
  String get saveTripPageNoBodiesOfWater => 'No bodies of water';

  @override
  String get saveTripPageNoGpsTrails => 'No GPS trails';

  @override
  String get tripCatchesPerSpecies => 'Catches Per Species';

  @override
  String get tripCatchesPerFishingSpot => 'Catches Per Fishing Spot';

  @override
  String get tripCatchesPerAngler => 'Catches Per Angler';

  @override
  String get tripCatchesPerBait => 'Catches Per Bait';

  @override
  String get tripSkunked => 'Skunked';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsPageFetchAtmosphereTitle => 'Auto-fetch Weather';

  @override
  String get settingsPageFetchAtmosphereDescription =>
      'Automatically fetch atmosphere and weather data when adding new catches and trips.';

  @override
  String get settingsPageFetchTideTitle => 'Auto-fetch Tide';

  @override
  String get settingsPageFetchTideDescription =>
      'Automatically fetch tide data when adding new catches.';

  @override
  String get settingsPageLogout => 'Logout';

  @override
  String get settingsPageLogoutConfirmMessage =>
      'Are you sure you want to logout?';

  @override
  String get settingsPageAbout => 'About, Terms, and Privacy';

  @override
  String get settingsPageFishingSpotDistanceTitle =>
      'Auto-fishing Spot Distance';

  @override
  String get settingsPageFishingSpotDistanceDescription =>
      'The distance within which to automatically pick fishing spots when adding catches.';

  @override
  String get settingsPageMinGpsTrailDistanceTitle => 'GPS Trail Distance';

  @override
  String get settingsPageMinGpsTrailDistanceDescription =>
      'The minimum distance between points in a GPS trail.';

  @override
  String get settingsPageThemeTitle => 'Theme';

  @override
  String get settingsPageThemeSystem => 'System';

  @override
  String get settingsPageThemeLight => 'Light';

  @override
  String get settingsPageThemeDark => 'Dark';

  @override
  String get settingsPageThemeSelect => 'Select Theme';

  @override
  String get unitsPageTitle => 'Measurement Units';

  @override
  String get unitsPageCatchLength => 'Catch Length';

  @override
  String unitsPageFractionalInches(String value) {
    return 'Fractional inches ($value)';
  }

  @override
  String unitsPageInches(String value) {
    return 'Inches ($value)';
  }

  @override
  String get unitsPageCatchWeight => 'Catch Weight';

  @override
  String unitsPageCatchWeightPoundsOunces(String value) {
    return 'Pounds and ounces ($value)';
  }

  @override
  String unitsPageCatchWeightPounds(String value) {
    return 'Pounds ($value)';
  }

  @override
  String unitsPageCatchWeightKilograms(String value) {
    return 'Kilograms ($value)';
  }

  @override
  String unitsPageWaterTemperatureFahrenheit(String value) {
    return 'Fahrenheit ($value)';
  }

  @override
  String unitsPageWaterTemperatureCelsius(String value) {
    return 'Celsius ($value)';
  }

  @override
  String unitsPageFeetInches(String value) {
    return 'Feet and inches ($value)';
  }

  @override
  String unitsPageFeet(String value) {
    return 'Feet ($value)';
  }

  @override
  String unitsPageAirTemperatureFahrenheit(String value) {
    return 'Fahrenheit ($value)';
  }

  @override
  String unitsPageAirTemperatureCelsius(String value) {
    return 'Celsius ($value)';
  }

  @override
  String unitsPageAirPressureInHg(String value) {
    return 'Inch of mercury ($value)';
  }

  @override
  String unitsPageAirPressurePsi(String value) {
    return 'Pounds per square inch ($value)';
  }

  @override
  String unitsPageAirPressureMillibars(String value) {
    return 'Millibars ($value)';
  }

  @override
  String unitsPageAirVisibilityMiles(String value) {
    return 'Miles ($value)';
  }

  @override
  String unitsPageWindSpeedMiles(String value) {
    return 'Miles per hour ($value)';
  }

  @override
  String get unitsPageDistanceTitle => 'Distance';

  @override
  String get unitsPageRodLengthTitle => 'Rod Length';

  @override
  String get unitsPageLeaderLengthTitle => 'Leader Length';

  @override
  String get unitsPageTippetLengthTitle => 'Tippet Length';

  @override
  String get mapPageMenuLabel => 'Map';

  @override
  String mapPageDeleteFishingSpot(String spot, int numOfCatches) {
    return '$spot is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String mapPageDeleteFishingSpotSingular(String spot) {
    return '$spot is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String mapPageDeleteFishingSpotNoName(int numOfCatches) {
    return 'This fishing spot is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get mapPageDeleteFishingSpotNoNameSingular =>
      'This fishing spot is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';

  @override
  String get mapPageAddCatch => 'Add Catch';

  @override
  String get mapPageSearchHint => 'Search fishing spots';

  @override
  String get mapPageDroppedPin => 'New Fishing Spot';

  @override
  String get mapPageMapTypeLight => 'Light';

  @override
  String get mapPageMapTypeSatellite => 'Satellite';

  @override
  String get mapPageMapTypeDark => 'Dark';

  @override
  String get mapPageErrorGettingLocation =>
      'Unable to retrieve current location. Ensure your device\'s location services are turned on and try again later.';

  @override
  String get mapPageErrorOpeningDirections =>
      'There are no navigation apps available on this device.';

  @override
  String get mapPageAppleMaps => 'Apple Maps™';

  @override
  String get mapPageGoogleMaps => 'Google Maps™';

  @override
  String get mapPageWaze => 'Waze™';

  @override
  String get mapPageMapTypeTooltip => 'Choose Map Type';

  @override
  String get mapPageMyLocationTooltip => 'Show My Location';

  @override
  String get mapPageShowAllTooltip => 'Show All Fishing Spots';

  @override
  String get mapPageStartTrackingTooltip => 'Start GPS Trail';

  @override
  String get mapPageStopTrackingTooltip => 'Stop GPS Trail';

  @override
  String get mapPageAddTooltip => 'Add Fishing Spot';

  @override
  String get saveFishingSpotPageNewTitle => 'New Fishing Spot';

  @override
  String get saveFishingSpotPageEditTitle => 'Edit Fishing Spot';

  @override
  String get saveFishingSpotPageBodyOfWaterLabel => 'Body of Water';

  @override
  String get saveFishingSpotPageCoordinatesLabel => 'Coordinates';

  @override
  String get formPageManageFieldText => 'Manage Fields';

  @override
  String get formPageAddCustomFieldNote =>
      'To add a custom field, tap the %s icon.';

  @override
  String get formPageManageFieldsNote => 'To manage fields, tap the %s icon.';

  @override
  String get formPageManageFieldsProDescription =>
      'You must be an Anglers\' Log Pro subscriber to use custom fields.';

  @override
  String get formPageManageUnits => 'Manage Units';

  @override
  String get formPageConfirmBackDesc =>
      'Any unsaved changes will be lost. Are you sure you want to discard changes and go back?';

  @override
  String get formPageConfirmBackAction => 'Discard';

  @override
  String get saveCustomEntityPageNewTitle => 'New Field';

  @override
  String get saveCustomEntityPageEditTitle => 'Edit Field';

  @override
  String get saveCustomEntityPageNameExists => 'Field name already exists';

  @override
  String customEntityListPageTitle(int numOfFields) {
    return 'Custom Fields ($numOfFields)';
  }

  @override
  String customEntityListPageDelete(
    String field,
    int numOfCatches,
    int numOfBaits,
  ) {
    return 'The custom field $field will no longer be associated with catches ($numOfCatches) or baits ($numOfBaits), are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get customEntityListPageSearchHint => 'Search fields';

  @override
  String get customEntityListPageEmptyListTitle => 'No Custom Fields';

  @override
  String get customEntityListPageEmptyListDescription =>
      'You haven\'t yet added any custom fields. Tap the %s button to begin.';

  @override
  String get imagePickerConfirmDelete =>
      'Are you sure you want to delete this photo?';

  @override
  String get imagePickerPageNoPhotosFoundTitle => 'No photos found';

  @override
  String get imagePickerPageNoPhotosFound =>
      'Try changing the photo source from the dropdown above.';

  @override
  String get imagePickerPageOpenCameraLabel => 'Open Camera';

  @override
  String get imagePickerPageCameraLabel => 'Camera';

  @override
  String get imagePickerPageGalleryLabel => 'Gallery';

  @override
  String get imagePickerPageBrowseLabel => 'Browse';

  @override
  String imagePickerPageSelectedLabel(int numSelected, int numTotal) {
    return '$numSelected / $numTotal Selected';
  }

  @override
  String get imagePickerPageInvalidSelectionSingle =>
      'Must select an image file.';

  @override
  String get imagePickerPageInvalidSelectionPlural =>
      'Must select image files.';

  @override
  String get imagePickerPageNoPermissionTitle => 'Permission required';

  @override
  String get imagePickerPageNoPermissionMessage =>
      'To add photos, you must grant Anglers\' Log permission to access your photo library. To do so, open your device settings.\n\nAlternatively, you can change the photos source from the dropdown menu above.';

  @override
  String get imagePickerPageOpenSettings => 'Open Settings';

  @override
  String get imagePickerPageImageDownloadError =>
      'Failed to attach photo. Please ensure you are connected to the internet and try again.';

  @override
  String get imagePickerPageImagesDownloadError =>
      'Failed to attach one or more photos. Please ensure you are connected to the internet and try again.';

  @override
  String reportListPageConfirmDelete(String report) {
    return 'Are you sure you want to delete report $report? This cannot be undone.';
  }

  @override
  String get reportListPageReportTitle => 'Custom Reports';

  @override
  String get reportListPageReportAddNote =>
      'To add a custom report, tap the %s icon.';

  @override
  String get reportListPageReportsProDescription =>
      'You must be an Anglers\' Log Pro subscriber to view custom reports.';

  @override
  String get saveSpeciesPageNewTitle => 'New Species';

  @override
  String get saveSpeciesPageEditTitle => 'Edit Species';

  @override
  String get saveSpeciesPageExistsError => 'Species already exists';

  @override
  String speciesListPageTitle(int numOfSpecies) {
    return 'Species ($numOfSpecies)';
  }

  @override
  String speciesListPageConfirmDelete(String species) {
    return '$species is associated with 0 catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String speciesListPageCatchDeleteErrorSingular(String species) {
    return '$species is associated with 1 catch and cannot be deleted.';
  }

  @override
  String speciesListPageCatchDeleteErrorPlural(
    String species,
    int numOfCatches,
  ) {
    return '$species is associated with $numOfCatches catches and cannot be deleted.';
  }

  @override
  String get speciesListPageSearchHint => 'Search species';

  @override
  String get speciesListPageEmptyListTitle => 'No Species';

  @override
  String get speciesListPageEmptyListDescription =>
      'You haven\'t yet added any species. Tap the %s button to begin.';

  @override
  String get fishingSpotPickerPageHint =>
      'Long press the map to pick exact coordinates, or select an existing fishing spot.';

  @override
  String fishingSpotListPageTitle(int numOfSpots) {
    return 'Fishing Spots ($numOfSpots)';
  }

  @override
  String get fishingSpotListPageSearchHint => 'Search fishing spots';

  @override
  String get fishingSpotListPageEmptyListTitle => 'No Fishing Spots';

  @override
  String get fishingSpotListPageEmptyListDescription =>
      'To add a fishing spot, tap the %s button on the map and save the dropped pin.';

  @override
  String get fishingSpotsSummaryEmpty =>
      'When fishing spots are added to your log, a summary of their catches will be shown here.';

  @override
  String get fishingSpotListPageNoBodyOfWater => 'No Body of Water';

  @override
  String get fishingSpotMapAddSpotHelp =>
      'Long press anywhere on the map to drop a pin and add a fishing spot.';

  @override
  String get editCoordinatesHint =>
      'Drag the map to update the fishing spot\'s coordinates.';

  @override
  String get feedbackPageTitle => 'Send Feedback';

  @override
  String get feedbackPageSend => 'Send';

  @override
  String get feedbackPageMessage => 'Message';

  @override
  String get feedbackPageBugType => 'Bug';

  @override
  String get feedbackPageSuggestionType => 'Suggestion';

  @override
  String get feedbackPageFeedbackType => 'Feedback';

  @override
  String get feedbackPageErrorSending =>
      'Error sending feedback. Please try again later, or email support@anglerslog.ca directly.';

  @override
  String get feedbackPageConnectionError =>
      'No internet connection. Please check your connection and try again.';

  @override
  String get feedbackPageSending => 'Sending feedback...';

  @override
  String get backupPageMoreTitle => 'Backup and Restore';

  @override
  String get importPageMoreTitle => 'Legacy Import';

  @override
  String get importPageTitle => 'Legacy Import';

  @override
  String get importPageDescription =>
      'Legacy import requires you to choose a backup file (.zip) that you created with an older version of Anglers\' Log. Imported legacy data is added to your existing log.\n\nThe import process may take several minutes.';

  @override
  String get importPageImportingImages => 'Copying images...';

  @override
  String get importPageImportingData => 'Copying fishing data...';

  @override
  String get importPageSuccess => 'Successfully imported data!';

  @override
  String get importPageError =>
      'There was an error importing your data. If the backup file you chose was created using Anglers\' Log, please send it to us for investigation.';

  @override
  String get importPageErrorWarningMessage =>
      'Pressing send will send Anglers\' Log all your fishing data (excluding photos). Your data will not be shared outside the Anglers\' Log organization.';

  @override
  String get importPageErrorTitle => 'Import Error';

  @override
  String get dataImporterChooseFile => 'Choose File';

  @override
  String get dataImporterStart => 'Start';

  @override
  String get migrationPageMoreTitle => 'Legacy Migration';

  @override
  String get migrationPageTitle => 'Data Migration';

  @override
  String get onboardingMigrationPageDescription =>
      'This is your first time opening Anglers\' Log since updating to 2.0. Click the button below to start the data migration process.';

  @override
  String get migrationPageDescription =>
      'You have legacy data that needs to be migrated to Anglers\' Log 2.0. Click the button below to begin.';

  @override
  String get onboardingMigrationPageError =>
      'There was an unexpected error while migrating your data to Anglers\' Log 2.0. Please send us the error report and we will investigate as soon as possible. Note that none of your data has been lost. Please visit the Settings page to retry data migration after the issue has been resolved.';

  @override
  String get migrationPageError =>
      'There was an unexpected error while migrating your data to Anglers\' Log 2.0. Please send us the error report and we will investigate as soon as possible. Note that none of your old data has been lost. Please revisit this page to retry data migration after the issue has been resolved.';

  @override
  String get migrationPageLoading => 'Migrating data to Anglers\' Log 2.0...';

  @override
  String get migrationPageSuccess => 'Successfully migrated data!';

  @override
  String get migrationPageNothingToDoDescription =>
      'Data migration is the process of converting legacy data from old versions of Anglers\' Log into the data format used by new versions.';

  @override
  String get migrationPageNothingToDoSuccess =>
      'You have no legacy data to migrate!';

  @override
  String get migrationPageFeedbackTitle => 'Migration Error';

  @override
  String get anglerNameLabel => 'Angler';

  @override
  String get onboardingJourneyWelcomeTitle => 'Welcome';

  @override
  String get onboardingJourneyStartDescription =>
      'Welcome to Anglers\' Log! Let\'s start by figuring out what kind of data you want to track.';

  @override
  String get onboardingJourneyStartButton => 'Get Started';

  @override
  String get onboardingJourneySkip => 'No thanks, I\'ll learn as I go.';

  @override
  String get onboardingJourneyCatchFieldDescription =>
      'When you log a catch, what do you want to know?';

  @override
  String get onboardingJourneyManageFieldsTitle => 'Manage Fields';

  @override
  String get onboardingJourneyManageFieldsDescription =>
      'Manage default fields, or add custom fields at any time when adding or editing gear, a catch, bait, trip, or weather.';

  @override
  String get onboardingJourneyManageFieldsSpecies => 'Rainbow Trout';

  @override
  String get onboardingJourneyLocationAccessTitle => 'Location Access';

  @override
  String get onboardingJourneyLocationAccessDescription =>
      'Anglers\' Log uses location services to show your current location on the in-app map, to automatically create fishing spots when adding catches, and to create GPS trails while fishing.';

  @override
  String get onboardingJourneyHowToFeedbackTitle => 'Send Feedback';

  @override
  String get onboardingJourneyHowToFeedbackDescription =>
      'Report a problem, suggest a feature, or send us feedback anytime. We\'d love to hear from you!';

  @override
  String get onboardingJourneyNotNow => 'Not Now';

  @override
  String get emptyListPlaceholderNoResultsTitle => 'No results found';

  @override
  String get emptyListPlaceholderNoResultsDescription =>
      'Please adjust your search filter to find what you\'re looking for.';

  @override
  String get proPageBackup => 'Automatic backup with Google Drive™';

  @override
  String get proPageCsv => 'Export log to spreadsheet (CSV)';

  @override
  String get proPageAtmosphere => 'Fetch atmosphere, weather, and tide data';

  @override
  String get proPageReports => 'Create custom reports and filters';

  @override
  String get proPageCustomFields => 'Create custom input fields';

  @override
  String get proPageGpsTrails => 'Create and track realtime GPS trails';

  @override
  String get proPageCopyCatch => 'Copy catches';

  @override
  String get proPageSpeciesCounter => 'Realtime species caught counter';

  @override
  String get periodDawn => 'Dawn';

  @override
  String get periodMorning => 'Morning';

  @override
  String get periodMidday => 'Midday';

  @override
  String get periodAfternoon => 'Afternoon';

  @override
  String get periodEvening => 'Evening';

  @override
  String get periodDusk => 'Dusk';

  @override
  String get periodNight => 'Night';

  @override
  String get periodPickerAll => 'All times of day';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonPickerAll => 'All seasons';

  @override
  String get measurementSystemImperial => 'Imperial';

  @override
  String get measurementSystemImperialDecimal => 'Imperial Decimal';

  @override
  String get measurementSystemMetric => 'Metric';

  @override
  String get numberBoundaryAny => 'Any';

  @override
  String get numberBoundaryLessThan => 'Less than (<)';

  @override
  String get numberBoundaryLessThanOrEqualTo => 'Less than or equal to (≤)';

  @override
  String get numberBoundaryEqualTo => 'Equal to (=)';

  @override
  String get numberBoundaryGreaterThan => 'Greater than (>)';

  @override
  String get numberBoundaryGreaterThanOrEqualTo =>
      'Greater than or equal to (≥)';

  @override
  String get numberBoundaryRange => 'Range';

  @override
  String numberBoundaryLessThanValue(String value) {
    return '< $value';
  }

  @override
  String numberBoundaryLessThanOrEqualToValue(String value) {
    return '≤ $value';
  }

  @override
  String numberBoundaryEqualToValue(String value) {
    return '= $value';
  }

  @override
  String numberBoundaryGreaterThanValue(String value) {
    return '> $value';
  }

  @override
  String numberBoundaryGreaterThanOrEqualToValue(String value) {
    return '≥ $value';
  }

  @override
  String numberBoundaryRangeValue(String from, String to) {
    return '$from - $to';
  }

  @override
  String get unitFeet => 'ft';

  @override
  String get unitInches => 'in';

  @override
  String get unitPounds => 'lbs';

  @override
  String get unitOunces => 'oz';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitMeters => 'm';

  @override
  String get unitCentimeters => 'cm';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitMilesPerHour => 'mph';

  @override
  String get unitKilometersPerHour => 'km/h';

  @override
  String get unitMillibars => 'MB';

  @override
  String get unitPoundsPerSquareInch => 'psi';

  @override
  String get unitPercent => '%';

  @override
  String get unitInchOfMercury => 'inHg';

  @override
  String get unitMiles => 'mi';

  @override
  String get unitKilometers => 'km';

  @override
  String get unitX => 'X';

  @override
  String get unitAught => 'O';

  @override
  String get unitPoundTest => 'lb test';

  @override
  String get unitHashtag => '#';

  @override
  String get unitMetersPerSecond => 'm/s';

  @override
  String unitConvertToValue(String unit) {
    return 'Convert to $unit';
  }

  @override
  String get numberFilterInputFrom => 'From';

  @override
  String get numberFilterInputTo => 'To';

  @override
  String get numberFilterInputValue => 'Value';

  @override
  String get filterTitleWaterTemperature => 'Water Temperature Filter';

  @override
  String get filterTitleWaterDepth => 'Water Depth Filter';

  @override
  String get filterTitleLength => 'Length Filter';

  @override
  String get filterTitleWeight => 'Weight Filter';

  @override
  String get filterTitleQuantity => 'Quantity Filter';

  @override
  String get filterTitleAirTemperature => 'Air Temperature Filter';

  @override
  String get filterTitleAirPressure => 'Atmospheric Pressure Filter';

  @override
  String get filterTitleAirHumidity => 'Air Humidity Filter';

  @override
  String get filterTitleAirVisibility => 'Air Visibility Filter';

  @override
  String get filterTitleWindSpeed => 'Wind Speed Filter';

  @override
  String filterValueWaterTemperature(String value) {
    return 'Water Temperature: $value';
  }

  @override
  String filterValueWaterDepth(String value) {
    return 'Water Depth: $value';
  }

  @override
  String filterValueLength(String value) {
    return 'Length: $value';
  }

  @override
  String filterValueWeight(String value) {
    return 'Weight: $value';
  }

  @override
  String filterValueQuantity(String value) {
    return 'Quantity: $value';
  }

  @override
  String filterValueAirTemperature(String value) {
    return 'Air Temperature: $value';
  }

  @override
  String filterValueAirPressure(String value) {
    return 'Atmospheric Pressure: $value';
  }

  @override
  String filterValueAirHumidity(String value) {
    return 'Air Humidity: $value%';
  }

  @override
  String filterValueAirVisibility(String value) {
    return 'Air Visibility: $value';
  }

  @override
  String filterValueWindSpeed(String value) {
    return 'Wind Speed: $value';
  }

  @override
  String filterPageInvalidEndValue(String value) {
    return 'Must be greater than $value';
  }

  @override
  String get moonPhaseNew => 'New';

  @override
  String get moonPhaseWaxingCrescent => 'Waxing Crescent';

  @override
  String get moonPhaseFirstQuarter => '1st Quarter';

  @override
  String get moonPhaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get moonPhaseFull => 'Full';

  @override
  String get moonPhaseWaningGibbous => 'Waning Gibbous';

  @override
  String get moonPhaseLastQuarter => 'Last Quarter';

  @override
  String get moonPhaseWaningCrescent => 'Waning Crescent';

  @override
  String moonPhaseChip(String value) {
    return '$value Moon';
  }

  @override
  String get atmosphereInputTemperature => 'Temperature';

  @override
  String get atmosphereInputAirTemperature => 'Air Temperature';

  @override
  String get atmosphereInputSkyConditions => 'Sky Conditions';

  @override
  String get atmosphereInputNoSkyConditions => 'No sky conditions';

  @override
  String get atmosphereInputWindSpeed => 'Wind Speed';

  @override
  String get atmosphereInputWind => 'Wind';

  @override
  String get atmosphereInputWindDirection => 'Wind Direction';

  @override
  String get atmosphereInputPressure => 'Pressure';

  @override
  String get atmosphereInputAtmosphericPressure => 'Atmospheric Pressure';

  @override
  String get atmosphereInputHumidity => 'Humidity';

  @override
  String get atmosphereInputAirHumidity => 'Air Humidity';

  @override
  String get atmosphereInputVisibility => 'Visibility';

  @override
  String get atmosphereInputAirVisibility => 'Air Visibility';

  @override
  String get atmosphereInputMoon => 'Moon';

  @override
  String get atmosphereInputMoonPhase => 'Moon Phase';

  @override
  String get atmosphereInputSunrise => 'Sunrise';

  @override
  String get atmosphereInputTimeOfSunrise => 'Time of Sunrise';

  @override
  String get atmosphereInputSunset => 'Sunset';

  @override
  String get atmosphereInputTimeOfSunset => 'Time of Sunset';

  @override
  String get directionNorth => 'N';

  @override
  String get directionNorthEast => 'NE';

  @override
  String get directionEast => 'E';

  @override
  String get directionSouthEast => 'SE';

  @override
  String get directionSouth => 'S';

  @override
  String get directionSouthWest => 'SW';

  @override
  String get directionWest => 'W';

  @override
  String get directionNorthWest => 'NW';

  @override
  String directionWindChip(String value) {
    return 'Wind: $value';
  }

  @override
  String get skyConditionSnow => 'Snow';

  @override
  String get skyConditionDrizzle => 'Drizzle';

  @override
  String get skyConditionDust => 'Dust';

  @override
  String get skyConditionFog => 'Fog';

  @override
  String get skyConditionRain => 'Rain';

  @override
  String get skyConditionTornado => 'Tornado';

  @override
  String get skyConditionHail => 'Hail';

  @override
  String get skyConditionIce => 'Ice';

  @override
  String get skyConditionStorm => 'Storm';

  @override
  String get skyConditionMist => 'Mist';

  @override
  String get skyConditionSmoke => 'Smoke';

  @override
  String get skyConditionOvercast => 'Overcast';

  @override
  String get skyConditionCloudy => 'Cloudy';

  @override
  String get skyConditionClear => 'Clear';

  @override
  String get skyConditionSunny => 'Sunny';

  @override
  String get pickerTitleBait => 'Select Bait';

  @override
  String get pickerTitleBaits => 'Select Baits';

  @override
  String get pickerTitleBaitCategory => 'Select Bait Category';

  @override
  String get pickerTitleAngler => 'Select Angler';

  @override
  String get pickerTitleAnglers => 'Select Anglers';

  @override
  String get pickerTitleFishingMethods => 'Select Fishing Methods';

  @override
  String get pickerTitleWaterClarity => 'Select Water Clarity';

  @override
  String get pickerTitleWaterClarities => 'Select Water Clarities';

  @override
  String get pickerTitleDateRange => 'Select Date Range';

  @override
  String get pickerTitleFields => 'Select Fields';

  @override
  String get pickerTitleReport => 'Select Report';

  @override
  String get pickerTitleSpecies => 'Select Species';

  @override
  String get pickerTitleFishingSpot => 'Select Fishing Spot';

  @override
  String get pickerTitleFishingSpots => 'Select Fishing Spots';

  @override
  String get pickerTitleTimeOfDay => 'Select Time of Day';

  @override
  String get pickerTitleTimesOfDay => 'Select Times of Day';

  @override
  String get pickerTitleSeason => 'Select Season';

  @override
  String get pickerTitleSeasons => 'Select Seasons';

  @override
  String get pickerTitleMoonPhase => 'Select Moon Phase';

  @override
  String get pickerTitleMoonPhases => 'Select Moon Phases';

  @override
  String get pickerTitleSkyCondition => 'Select Sky Condition';

  @override
  String get pickerTitleSkyConditions => 'Select Sky Conditions';

  @override
  String get pickerTitleWindDirection => 'Select Wind Direction';

  @override
  String get pickerTitleWindDirections => 'Select Wind Directions';

  @override
  String get pickerTitleTide => 'Select Tide';

  @override
  String get pickerTitleTides => 'Select Tides';

  @override
  String get pickerTitleBodyOfWater => 'Select Body of Water';

  @override
  String get pickerTitleBodiesOfWater => 'Select Bodies of Water';

  @override
  String get pickerTitleCatches => 'Select Catches';

  @override
  String get pickerTitleTimeZone => 'Select Time Zone';

  @override
  String get pickerTitleGpsTrails => 'Select GPS Trails';

  @override
  String get pickerTitleGear => 'Select Gear';

  @override
  String get pickerTitleRodAction => 'Select Action';

  @override
  String get pickerTitleRodPower => 'Select Power';

  @override
  String get pickerTitleTrip => 'Select Trip';

  @override
  String get keywordsTemperatureMetric => 'celsius temperature degrees c';

  @override
  String get keywordsTemperatureImperial => 'fahrenheit temperature degrees f';

  @override
  String get keywordsSpeedImperial => 'miles per hour speed wind';

  @override
  String get keywordsAirPressureMetric => 'atmospheric air pressure millibars';

  @override
  String get keywordsAirPressureImperial =>
      'atmospheric air pressure pounds per square inch';

  @override
  String get keywordsAirHumidity => 'humidity percent moisture';

  @override
  String get keywordsAirVisibilityMetric => 'kilometers kilometres visibility';

  @override
  String get keywordsAirVisibilityImperial => 'miles visibility';

  @override
  String get keywordsPercent => 'percent';

  @override
  String get keywordsInchOfMercury =>
      'inch of mercury barometric atmospheric pressure';

  @override
  String get keywordsSunrise => 'sunrise';

  @override
  String get keywordsSunset => 'sunset';

  @override
  String get keywordsCatchAndRelease => 'kept keep released';

  @override
  String get keywordsFavorite => 'favourite favorite star starred';

  @override
  String get keywordsDepthMetric => 'depth meters metres';

  @override
  String get keywordsDepthImperial => 'depth feet inches';

  @override
  String get keywordsLengthMetric => 'length centimeters cm';

  @override
  String get keywordsLengthImperial => 'length inches in \"';

  @override
  String get keywordsWeightMetric => 'weight kilos kilograms kg';

  @override
  String get keywordsWeightImperial => 'weight pounds ounces lbs oz';

  @override
  String get keywordsX => 'x';

  @override
  String get keywordsAught => 'aught ought';

  @override
  String get keywordsPoundTest => 'pound test';

  @override
  String get keywordsHashtag => '#';

  @override
  String get keywordsMetersPerSecond => 'meters metres per second m/s';

  @override
  String get keywordsNorth => 'n north';

  @override
  String get keywordsNorthEast => 'ne northeast';

  @override
  String get keywordsEast => 'e east';

  @override
  String get keywordsSouthEast => 'se southeast';

  @override
  String get keywordsSouth => 's south';

  @override
  String get keywordsSouthWest => 'sw southwest';

  @override
  String get keywordsWest => 'w west';

  @override
  String get keywordsNorthWest => 'nw northwest';

  @override
  String get keywordsWindDirection => 'wind direction';

  @override
  String get keywordsMoon => 'moon phase';

  @override
  String get tideInputTitle => 'Tide';

  @override
  String tideInputLowTimeValue(String value) {
    return 'Low: $value';
  }

  @override
  String tideInputHighTimeValue(String value) {
    return 'High: $value';
  }

  @override
  String tideInputDatumValue(String value) {
    return 'Datum: $value';
  }

  @override
  String get tideInputFirstLowTimeLabel => 'Time of First Low Tide';

  @override
  String get tideInputFirstHighTimeLabel => 'Time of First High Tide';

  @override
  String get tideInputSecondLowTimeLabel => 'Time of Second Low Tide';

  @override
  String get tideInputSecondHighTimeLabel => 'Time of Second High Tide';

  @override
  String get tideTypeLow => 'Low';

  @override
  String get tideTypeOutgoing => 'Outgoing';

  @override
  String get tideTypeHigh => 'High';

  @override
  String get tideTypeSlack => 'Slack';

  @override
  String get tideTypeIncoming => 'Incoming';

  @override
  String get tideLow => 'Low Tide';

  @override
  String get tideOutgoing => 'Outgoing Tide';

  @override
  String get tideHigh => 'High Tide';

  @override
  String get tideSlack => 'Slack Tide';

  @override
  String get tideIncoming => 'Incoming Tide';

  @override
  String tideTimeAndHeight(String height, String time) {
    return '$height at $time';
  }

  @override
  String get saveBaitVariantPageTitle => 'Edit Bait Variant';

  @override
  String get saveBaitVariantPageEditTitle => 'New Bait Variant';

  @override
  String get saveBaitVariantPageModelNumber => 'Model Number';

  @override
  String get saveBaitVariantPageSize => 'Size';

  @override
  String get saveBaitVariantPageMinDiveDepth => 'Minimum Dive Depth';

  @override
  String get saveBaitVariantPageMaxDiveDepth => 'Maximum Dive Depth';

  @override
  String get saveBaitVariantPageDescription => 'Description';

  @override
  String get baitVariantPageVariantLabel => 'Variant of';

  @override
  String get baitVariantPageModel => 'Model Number';

  @override
  String get baitVariantPageSize => 'Size';

  @override
  String get baitVariantPageDiveDepth => 'Dive Depth';

  @override
  String get baitTypeArtificial => 'Artificial';

  @override
  String get baitTypeReal => 'Real';

  @override
  String get baitTypeLive => 'Live';

  @override
  String bodyOfWaterListPageDeleteMessage(String bodyOfWater, int numOfSpots) {
    return '$bodyOfWater is associated with $numOfSpots fishing spots; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String bodyOfWaterListPageDeleteMessageSingular(String bodyOfWater) {
    return '$bodyOfWater is associated with 1 fishing spot; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String bodyOfWaterListPageTitle(int numOfBodiesOfWater) {
    return 'Bodies of Water ($numOfBodiesOfWater)';
  }

  @override
  String get bodyOfWaterListPageSearchHint => 'Search bodies of water';

  @override
  String get bodyOfWaterListPageEmptyListTitle => 'No Bodies of Water';

  @override
  String get bodyOfWaterListPageEmptyListDescription =>
      'You haven\'t yet added any bodies of water. Tap the %s button to begin.';

  @override
  String get bodiesOfWaterSummaryEmpty =>
      'When bodies of water are added to your log, a summary of their catches will be shown here.';

  @override
  String get saveBodyOfWaterPageNewTitle => 'New Body of Water';

  @override
  String get saveBodyOfWaterPageEditTitle => 'Edit Body of Water';

  @override
  String get saveBodyOfWaterPageExistsMessage => 'Body of water already exists';

  @override
  String get mapAttributionTitleApple => 'Mapbox Maps SDK for iOS';

  @override
  String get mapAttributionTitleAndroid => 'Mapbox Maps SDK for Android';

  @override
  String get mapAttributionMapbox => '© Mapbox';

  @override
  String get mapAttributionOpenStreetMap => '© OpenStreetMap';

  @override
  String get mapAttributionImproveThisMap => 'Improve This Map';

  @override
  String get mapAttributionMaxar => '© Maxar';

  @override
  String get mapAttributionTelemetryTitle => 'Mapbox Telemetry';

  @override
  String get mapAttributionTelemetryDescription =>
      'Help make OpenStreetMap and Mapbox maps better by contributing anonymous usage data.';

  @override
  String get entityNameAnglers => 'Anglers';

  @override
  String get entityNameAngler => 'Angler';

  @override
  String get entityNameBaitCategories => 'Bait Categories';

  @override
  String get entityNameBaitCategory => 'Bait Category';

  @override
  String get entityNameBaits => 'Baits';

  @override
  String get entityNameBait => 'Bait';

  @override
  String get entityNameBodiesOfWater => 'Bodies of Water';

  @override
  String get entityNameBodyOfWater => 'Body of Water';

  @override
  String get entityNameCatch => 'Catch';

  @override
  String get entityNameCatches => 'Catches';

  @override
  String get entityNameCustomFields => 'Custom Fields';

  @override
  String get entityNameCustomField => 'Custom Field';

  @override
  String get entityNameFishingMethods => 'Fishing Methods';

  @override
  String get entityNameFishingMethod => 'Fishing Method';

  @override
  String get entityNameGear => 'Gear';

  @override
  String get entityNameGpsTrails => 'GPS Trails';

  @override
  String get entityNameGpsTrail => 'GPS Trail';

  @override
  String get entityNameSpecies => 'Species';

  @override
  String get entityNameTrip => 'Trip';

  @override
  String get entityNameTrips => 'Trips';

  @override
  String get entityNameWaterClarities => 'Water Clarities';

  @override
  String get entityNameWaterClarity => 'Water Clarity';

  @override
  String get tripSummaryTitle => 'Trip Summary';

  @override
  String get tripSummaryTotalTripTime => 'Total Trip Time';

  @override
  String get tripSummaryLongestTrip => 'Longest Trip';

  @override
  String get tripSummarySinceLastTrip => 'Since Last Trip';

  @override
  String get tripSummaryAverageTripTime => 'Average Trip Time';

  @override
  String get tripSummaryAverageTimeBetweenTrips => 'Between Trips';

  @override
  String get tripSummaryAverageTimeBetweenCatches => 'Between Catches';

  @override
  String get tripSummaryCatchesPerTrip => 'Catches Per Trip';

  @override
  String get tripSummaryCatchesPerHour => 'Catches Per Hour';

  @override
  String get tripSummaryWeightPerTrip => 'Weight Per Trip';

  @override
  String get tripSummaryBestWeight => 'Best Weight';

  @override
  String get tripSummaryLengthPerTrip => 'Length Per Trip';

  @override
  String get tripSummaryBestLength => 'Best Length';

  @override
  String get backupPageTitle => 'Backup';

  @override
  String get backupPageDescription =>
      'Your data is copied to a private folder in your Google Drive™ and is not shared publicly.\n\nThe backup process may take several minutes.';

  @override
  String get backupPageAction => 'Backup Now';

  @override
  String get backupPageErrorTitle => 'Backup Error';

  @override
  String get backupPageAutoTitle => 'Automatically Backup';

  @override
  String get backupPageLastBackupLabel => 'Last Backup';

  @override
  String get backupPageLastBackupNever => 'Never';

  @override
  String get restorePageTitle => 'Restore';

  @override
  String get restorePageDescription =>
      'Restoring data completely replaces your existing log with the data stored in Google Drive™. If there is no data, your log remains unchanged.\n\nThe restore process may take several minutes.';

  @override
  String get restorePageAction => 'Restore Now';

  @override
  String get restorePageErrorTitle => 'Restore Error';

  @override
  String get backupRestoreAuthError =>
      'Authentication error, please try again later.';

  @override
  String get backupRestoreAutoSignedOutError =>
      'Auto-backup failed due to an authentication timeout. Please sign in again.';

  @override
  String get backupRestoreAutoNetworkError =>
      'Auto-backup failed due to a network connectivity issue. Please do a manual backup or wait for the next auto-backup attempt.';

  @override
  String get backupRestoreCreateFolderError =>
      'Failed to create backup folder, please try again later.';

  @override
  String get backupRestoreFolderNotFound =>
      'Backup folder not found. You must backup your data before it can be restored.';

  @override
  String get backupRestoreApiRequestError =>
      'The network may have been interrupted. Verify your internet connection and try again. If the issue persists, please send Anglers\' Log a report for investigation.';

  @override
  String get backupRestoreDatabaseNotFound =>
      'Backup data file not found. You must backup your data before it can be restored.';

  @override
  String get backupRestoreAccessDenied =>
      'Anglers\' Log doesn\'t have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.';

  @override
  String get backupRestoreStorageFull =>
      'Your Google Drive™ storage is full. Please free some space and try again.';

  @override
  String get backupRestoreAuthenticating => 'Authenticating...';

  @override
  String get backupRestoreFetchingFiles => 'Fetching data...';

  @override
  String get backupRestoreCreatingFolder => 'Creating backup folder...';

  @override
  String get backupRestoreBackingUpDatabase => 'Backing up database...';

  @override
  String backupRestoreBackingUpImages(String percent) {
    return 'Backing up images$percent...';
  }

  @override
  String get backupRestoreDownloadingDatabase => 'Downloading database...';

  @override
  String backupRestoreDownloadingImages(String percent) {
    return 'Downloading images$percent...';
  }

  @override
  String get backupRestoreReloadingData => 'Reloading data...';

  @override
  String get backupRestoreSuccess => 'Success!';

  @override
  String get cloudAuthSignOut => 'Sign out';

  @override
  String get cloudAuthSignedInAs => 'Signed in as';

  @override
  String get cloudAuthSignInWithGoogle => 'Sign in with Google';

  @override
  String get cloudAuthDescription =>
      'To continue, you must sign in to your Google account. Data is saved to a private Google Drive™ folder and can only be accessed by Anglers\' Log.';

  @override
  String get cloudAuthError => 'Error signing in, please try again later.';

  @override
  String get cloudAuthNetworkError =>
      'There was a network error while signing in. Please ensure you are connected to the internet and try again.';

  @override
  String get asyncFeedbackSendReport => 'Send Report';

  @override
  String get addAnythingTitle => 'Add New';

  @override
  String get proBlurUpgradeButton => 'Upgrade';

  @override
  String get aboutPageVersion => 'Version';

  @override
  String get aboutPageEula => 'Terms of Use (EULA)';

  @override
  String get aboutPagePrivacy => 'Privacy Policy';

  @override
  String get aboutPageWorldTides => 'WorldTides™ Privacy Policy';

  @override
  String get aboutPageWorldTidePrivacy =>
      'Tidal data retrieved from www.worldtides.info. Copyright © 2014-2023 Brainware LLC.\n\nLicensed for use of individual spatial coordinates by an end-user.\n\nNO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS TIDAL DATA.\nYou may not use this data if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).\n\nTidal data is obtained from various sources and is covered in part or whole by various copyrights. For details see: http://www.worldtides.info/copyright';

  @override
  String get fishingSpotDetailsAddDetails => 'Add Details';

  @override
  String fishingSpotDetailsCatches(int numOfCatches) {
    return '$numOfCatches Catches';
  }

  @override
  String get fishingSpotDetailsCatch => '1 Catch';

  @override
  String get timeZoneInputLabel => 'Time Zone';

  @override
  String get timeZoneInputDescription => 'Defaults to your current time zone.';

  @override
  String get timeZoneInputSearchHint => 'Search time zones';

  @override
  String get pollsPageTitle => 'Feature Polls';

  @override
  String get pollsPageDescription =>
      'Vote to determine which features will be added in the next version of Anglers\' Log.';

  @override
  String get pollsPageNoPollsTitle => 'No Polls';

  @override
  String get pollsPageNoPollsDescription =>
      'There currently aren\'t any feature polls. If you\'d like to request a feature, please send us feedback!';

  @override
  String get pollsPageSendFeedback => 'Send Feedback';

  @override
  String get pollsPageNextFreeFeature => 'Next Free Feature';

  @override
  String get pollsPageNextProFeature => 'Next Pro Feature';

  @override
  String get pollsPageThankYouFree =>
      'Thank you for voting in the free feature poll!';

  @override
  String get pollsPageThankYouPro =>
      'Thank you for voting in the pro feature poll!';

  @override
  String get pollsPageError =>
      'There was an error casting your vote. Please try again later.';

  @override
  String get pollsPageComingSoonFree => 'Coming Soon To Free Users (As Voted)';

  @override
  String get pollsPageComingSoonPro => 'Coming Soon To Pro Users (As Voted)';

  @override
  String get permissionLocationTitle => 'Location Access';

  @override
  String get permissionCurrentLocationDescription =>
      'To show your current location, you must grant Anglers\' Log access to read your device\'s location. To do so, open your device settings.';

  @override
  String get permissionGpsTrailDescription =>
      'To create an accurate GPS trail, Anglers\' Log must be able to access your device\'s location at all times while tracking is active. To grant the required permission, open your device\'s settings.';

  @override
  String get permissionOpenSettings => 'Open Settings';

  @override
  String get permissionLocationNotificationDescription => 'GPS trail is active';

  @override
  String get calendarPageTitle => 'Calendar';

  @override
  String get calendarPageTripLabel => 'Trip';

  @override
  String gpsTrailListPageTitle(int numOfTrails) {
    return 'GPS Trails ($numOfTrails)';
  }

  @override
  String get gpsTrailListPageSearchHint => 'Search GPS trails';

  @override
  String get gpsTrailListPageEmptyListTitle => 'No GPS Trails';

  @override
  String get gpsTrailListPageEmptyListDescription =>
      'To start a GPS trail, tap the %s button on the map.';

  @override
  String get gpsTrailListPageDeleteMessageSingular =>
      'This GPS trail is associated with 1 trip; are you sure you want to delete it? This cannot be undone.';

  @override
  String gpsTrailListPageDeleteMessage(int numOfTrips) {
    return 'This GPS trail is associated with $numOfTrips trips; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String gpsTrailListPageNumberOfPoints(int numOfPoints) {
    return '$numOfPoints Points';
  }

  @override
  String get gpsTrailListPageInProgress => 'In Progress';

  @override
  String get saveGpsTrailPageEditTitle => 'Edit GPS Trail';

  @override
  String get tideFetcherErrorNoLocationFound =>
      'Fetch location is too far inland to determine tidal information.';

  @override
  String get csvPageTitle => 'Export CSV';

  @override
  String get csvPageAction => 'Export';

  @override
  String get csvPageDescription =>
      'A separate CSV file will be created for each selection below.';

  @override
  String get csvPageImportWarning =>
      'When importing into spreadsheet software, the file origin of the exported CSV file(s) is Unicode (UTF-8) and the delimiter is a comma.';

  @override
  String get csvPageBackupWarning =>
      'CSV files are not backups, and cannot be imported into Anglers\' Log. Instead, use the Backup and Restore buttons on the More page.';

  @override
  String get csvPageSuccess => 'Success!';

  @override
  String get csvPageMustSelect =>
      'Please select at least one export option above.';

  @override
  String get tripFieldStartDate => 'Start Date';

  @override
  String get tripFieldEndDate => 'End Date';

  @override
  String get tripFieldStartTime => 'Start Time';

  @override
  String get tripFieldEndTime => 'End Time';

  @override
  String get tripFieldPhotos => 'Photos';

  @override
  String gearListPageTitle(int numOfGear) {
    return 'Gear ($numOfGear)';
  }

  @override
  String gearListPageDeleteMessage(String gear, int numOfCatches) {
    return '$gear is associated with $numOfCatches catches; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String gearListPageDeleteMessageSingular(String gear) {
    return '$gear is associated with 1 catch; are you sure you want to delete it? This cannot be undone.';
  }

  @override
  String get gearListPageSearchHint => 'Search gear';

  @override
  String get gearListPageEmptyListTitle => 'No Gear';

  @override
  String get gearListPageEmptyListDescription =>
      'You haven\'t yet added any gear. Tap the %s button to begin.';

  @override
  String get gearSummaryEmpty =>
      'When gear is added to your log, a summary of their catches will be shown here.';

  @override
  String get gearActionXFast => 'X-Fast';

  @override
  String get gearActionFast => 'Fast';

  @override
  String get gearActionModerateFast => 'Moderate Fast';

  @override
  String get gearActionModerate => 'Moderate';

  @override
  String get gearActionSlow => 'Slow';

  @override
  String get gearPowerUltralight => 'Ultralight';

  @override
  String get gearPowerLight => 'Light';

  @override
  String get gearPowerMediumLight => 'Medium Light';

  @override
  String get gearPowerMedium => 'Medium';

  @override
  String get gearPowerMediumHeavy => 'Medium Heavy';

  @override
  String get gearPowerHeavy => 'Heavy';

  @override
  String get gearPowerXHeavy => 'X-Heavy';

  @override
  String get gearPowerXxHeavy => 'XX-Heavy';

  @override
  String get gearPowerXxxHeavy => 'XXX-Heavy';

  @override
  String get gearFieldImage => 'Photo';

  @override
  String get gearFieldRodMakeModel => 'Rod Made and Model';

  @override
  String get gearFieldRodSerialNumber => 'Rod Serial Number';

  @override
  String get gearFieldRodLength => 'Rod Length';

  @override
  String get gearFieldRodAction => 'Rod Action';

  @override
  String get gearFieldRodPower => 'Rod Power';

  @override
  String get gearFieldReelMakeModel => 'Reel Make and Model';

  @override
  String get gearFieldReelSerialNumber => 'Reel Serial Number';

  @override
  String get gearFieldReelSize => 'Reel Size';

  @override
  String get gearFieldLineMakeModel => 'Line Make and Model';

  @override
  String get gearFieldLineRating => 'Line Rating';

  @override
  String get gearFieldLineColor => 'Line Color';

  @override
  String get gearFieldLeaderLength => 'Leader Length';

  @override
  String get gearFieldLeaderRating => 'Leader Rating';

  @override
  String get gearFieldTippetLength => 'Tippet Length';

  @override
  String get gearFieldTippetRating => 'Tippet Rating';

  @override
  String get gearFieldHookMakeModel => 'Hook Make and Model';

  @override
  String get gearFieldHookSize => 'Hook Size';

  @override
  String get saveGearPageEditTitle => 'Edit Gear';

  @override
  String get saveGearPageNewTitle => 'New Gear';

  @override
  String get saveGearPageNameExists => 'Gear name already exists';

  @override
  String gearPageSerialNumber(String serialNo) {
    return 'Serial Number: $serialNo';
  }

  @override
  String gearPageSize(String size) {
    return 'Size: $size';
  }

  @override
  String gearPageLeader(String leader) {
    return 'Leader: $leader';
  }

  @override
  String gearPageTippet(String tippet) {
    return 'Tippet: $tippet';
  }

  @override
  String get notificationPermissionPageDesc =>
      'Allow Anglers\' Log to notify you if a data backup fails for any reason, including requiring re-authentication.';

  @override
  String get notificationErrorBackupTitle => 'Backup Error';

  @override
  String get notificationErrorBackupBody =>
      'Uh oh! Something went wrong while backing up your data. Tap here for details.';

  @override
  String get notificationChannelNameBackup => 'Data Backup';

  @override
  String get speciesCounterPageTitle => 'Species Counter';

  @override
  String get speciesCounterPageReset => 'Reset';

  @override
  String get speciesCounterPageCreateTrip => 'Create Trip';

  @override
  String get speciesCounterPageAddToTrip => 'Append Trip';

  @override
  String get speciesCounterPageSelect => 'Select Species';

  @override
  String speciesCounterPageTripUpdated(String trip) {
    return 'Species counts added to $trip.';
  }

  @override
  String get speciesCounterPageGeneralTripName => 'trip';

  @override
  String get locationDataFetcherErrorNoPermission =>
      'Permission is required to fetch data. Please grant Anglers\' Log the location permission and try again.';

  @override
  String get locationDataFetcherPermissionError =>
      'There was an error requesting location permission. The Anglers\' Log team has been notified, and we apologize for the inconvenience.';

  @override
  String get landingPageInitError =>
      'Uh oh! Something went wrong during initialization. The Anglers\' Log team has been notified, and we apologize for the inconvenience.';

  @override
  String get changeLogPageTitle => 'What\'s New';

  @override
  String get changeLogPagePreviousVersion => 'Your Previous Version';

  @override
  String get changeLog_2022_1 => 'A complete rewrite of Anglers\' Log';

  @override
  String get changeLog_2022_2 => 'A fresh and modern look and feel';

  @override
  String get changeLog_2022_3 =>
      'A completely new, extensive and detailed statistics feature';

  @override
  String get changeLog_2022_4 =>
      'Detailed atmosphere and weather data, including moon phases and tide';

  @override
  String get changeLog_2022_5 =>
      'Get more out of Anglers\' Log by subscribing to Anglers\' Log Pro';

  @override
  String get changeLog_2022_6 => 'Plus many more user-requested features';

  @override
  String get changeLog_210_1 =>
      'In More > Feature Polls, you can now vote on what features you want to see next';

  @override
  String get changeLog_210_2 =>
      'Fixed issue where personal best photos\' corners weren\'t rounded';

  @override
  String get changeLog_210_3 =>
      'Fixed issue where catch quantity values weren\'t being counted on the Stats page';

  @override
  String get changeLog_210_4 =>
      'Automatic fishing spot picking distance is now configurable in Settings';

  @override
  String get changeLog_212_1 => 'Fixed crash while importing legacy data';

  @override
  String get changeLog_212_2 => 'Fixed crash while editing comparison reports';

  @override
  String get changeLog_212_3 =>
      'Fixed map appearing for some users after returning to the foreground';

  @override
  String get changeLog_212_4 => 'Removed notes input field character limit';

  @override
  String get changeLog_213_1 =>
      'Fixed issue where data restoring would sometimes fail';

  @override
  String get changeLog_213_2 => 'Fixed crash during legacy data migration';

  @override
  String get changeLog_213_3 => 'Performance improvements';

  @override
  String get changeLog_213_4 => 'Free users will no longer see ads';

  @override
  String get changeLog_215_1 =>
      'Improved efficiency of report calculations, which results in a smoother user experience';

  @override
  String get changeLog_216_1 => 'Fishing spot coordinates are now editable';

  @override
  String get changeLog_216_2 => 'Improved backup and restore error messages';

  @override
  String get changeLog_216_3 =>
      'Fixed issue where sometimes fishing spot \"Directions\" button didn\'t work';

  @override
  String get changeLog_216_4 =>
      'Fixed issue where the photo gallery would sometimes appear empty';

  @override
  String get changeLog_216_5 => 'Fixed several crashes';

  @override
  String get changeLog_220_1 =>
      'Added a calendar view of trips and catches to the \"More\" page';

  @override
  String get changeLog_220_2 =>
      'Fixed multiple issues with displaying baits on the \"Stats\" page';

  @override
  String get changeLog_220_3 => 'Fixed crash when photo data became unreadable';

  @override
  String get changeLog_230_1 =>
      'Add live GPS tracking that can be enabled by tapping the %s button on the map';

  @override
  String get changeLog_230_2 =>
      'Countries whose locale allows it, can now use commas as decimal points';

  @override
  String get changeLog_230_3 =>
      'Fixed issue where a photo\'s time and location weren\'t always used when adding a catch';

  @override
  String get changeLog_230_4 =>
      'Fixed a bug where the wrong catches were being shown on the stats page';

  @override
  String get changeLog_230_5 => 'Minor UI bug fixes';

  @override
  String get changeLog_232_1 =>
      'Fixed an issue where trip start and end times could not be set';

  @override
  String get changeLog_233_1 =>
      'Fixed an issue where trip start and end dates weren\'t selectable from the \"Manage Fields\" menu';

  @override
  String get changeLog_233_2 => 'Some general stability improvements';

  @override
  String get changeLog_234_1 =>
      'You will now be warned when leaving a page without first pressing the \"SAVE\" button';

  @override
  String get changeLog_234_2 =>
      'A trip\'s manually set start time is now used when fetching atmosphere and weather data';

  @override
  String get changeLog_234_3 =>
      'Fixed an issue where photos didn\'t show in the gallery when adding a catch';

  @override
  String get changeLog_234_4 =>
      'Fixed an issue where the map wasn\'t always able to fetch your current location';

  @override
  String get changeLog_240_1 => 'Added support for Dark Mode';

  @override
  String get changeLog_240_2 =>
      'Removed decimal digits on a trip\'s length stats tiles';

  @override
  String get changeLog_240_3 =>
      'Stats time period selection is now saved across app launches';

  @override
  String get changeLog_240_4 => 'Added \"Sunny\" as a sky condition';

  @override
  String get changeLog_240_5 => 'Note fields can now include blank lines';

  @override
  String get changeLog_240_6 =>
      'Note fields are no longer truncated to 4 lines';

  @override
  String get changeLog_241_1 =>
      'Fixed a crash while fetching atmosphere and weather data';

  @override
  String get changeLog_241_2 => 'Fixed a rare crash while adding a catch';

  @override
  String get changeLog_241_3 =>
      'Fixed an issue where the fishing spot was reset while adding a catch';

  @override
  String get changeLog_241_4 =>
      'When adding trips, you are now given the option to automatically set existing fields based on the selected catches';

  @override
  String get changeLog_241_5 =>
      'Several general stability improvements and crash fixes';

  @override
  String get changeLog_243_1 =>
      'Fixed inaccurate fetched atmosphere and weather data';

  @override
  String get changeLog_250_1 => 'Tide data can now be fetched from WorldTides™';

  @override
  String get changeLog_250_2 => 'Added \"Evening\" time of day';

  @override
  String get changeLog_250_3 =>
      'Fixed an issue where a fishing spot couldn\'t be added if it was too close to another spot';

  @override
  String get changeLog_250_4 =>
      'Fixed an issue inputting decimal values for languages that use commas as separators';

  @override
  String get changeLog_250_5 =>
      'Fixed an issue where location couldn\'t be read from photos';

  @override
  String get changeLog_251_1 =>
      'Fixed an issue where non-US locales couldn\'t change their measurement units';

  @override
  String get changeLog_252_1 =>
      'Automatic backups are now triggered on catch, trip, and bait changes';

  @override
  String get changeLog_252_2 => 'Fixed duplicate negative sign on tide heights';

  @override
  String get changeLog_252_3 =>
      'Fixed an issue where custom reports weren\'t tappable after upgrading to Pro';

  @override
  String get changeLog_252_4 =>
      'Fixed empty catch length/weight values showing on stats catch lists';

  @override
  String get changeLog_260_1 =>
      'Pro users can now export their data to a spreadsheet via More > Export CSV.';

  @override
  String get changeLog_260_2 =>
      'All users can now add gear and attach them to catches.';

  @override
  String get changeLog_260_3 =>
      'Fixed issue where a bait\'s name would get cut off by the variant text in the bait list.';

  @override
  String get changeLog_260_4 =>
      'Auto-fetched data is now updated when a catch\'s fishing spot changes.';

  @override
  String get changeLog_260_5 =>
      'Atmosphere and weather data is now auto-fetched for trips.';

  @override
  String get changeLog_270_1 =>
      'Added a realtime species caught counter (Pro feature) to the More page.';

  @override
  String get changeLog_270_2 =>
      'Added a copy catch button (Pro feature) when viewing a catch.';

  @override
  String get changeLog_270_3 => 'Added a photo to bait variants.';

  @override
  String get changeLog_270_4 => 'Added water conditions to trips.';

  @override
  String get changeLog_270_5 => 'Added failed backup notifications.';

  @override
  String get changeLog_270_6 => 'Added low and high heights to tide charts.';

  @override
  String get changeLog_270_7 =>
      'Added meters per second as a wind speed unit option.';

  @override
  String get changeLog_270_8 =>
      'Fixed an issue where reports would show the same data for different time periods.';

  @override
  String get changeLog_270_9 =>
      'Fixed an issue where you couldn\'t choose the CSV save location on some devices.';

  @override
  String get changeLog_270_10 =>
      'Fixed an issue where you couldn\'t share catches or trips on some devices.';

  @override
  String get changeLog_270_11 =>
      'Fixed an issue where the Trip Summary report would show incorrect best length and weight values.';

  @override
  String get changeLog_270_12 =>
      'Fixed an erroneous network error when trying to send us feedback.';

  @override
  String get changeLog_270_13 =>
      'Fishing spot can now be skipped when adding a catch.';

  @override
  String get changeLog_270_14 =>
      'Fishing spot can now be removed from a catch.';

  @override
  String get changeLog_270_15 =>
      'Exported CSV files now include latitude, longitude, and custom fields columns.';

  @override
  String get changeLog_270_16 =>
      'The \"Skunked\" stamp now says \"Blanked\" for UK users.';

  @override
  String get changeLog_271_1 =>
      'Tide chart now shows y-axis labels in the correct unit.';

  @override
  String get changeLog_271_2 =>
      'Fixed issue where some catch photos would be removed after an app update.';

  @override
  String get changeLog_272_1 => 'Fixed crash when opening external links.';

  @override
  String get changeLog_273_1 =>
      'Added number of catches to fishing spot details.';

  @override
  String get changeLog_273_2 => 'Added tide datum value to tide details.';

  @override
  String get changeLog_273_3 => 'Fixed unreliable zooming on photos.';

  @override
  String get changeLog_273_4 => 'Fixed error fetching weather data.';

  @override
  String get changeLog_273_5 => 'Fixed tide height values.';

  @override
  String get changeLog_273_6 => 'Fixed crash starting GPS trails.';

  @override
  String get changeLog_273_7 => 'Fixed cut off text on stats bar charts.';

  @override
  String get changeLog_274_1 => 'Fixed issue adding text to some text fields.';

  @override
  String get changeLog_275_1 =>
      'Fixed the decimal being removed from a catch\'s weight.';

  @override
  String get changeLog_275_2 =>
      'Fixed some incorrect rounding of water temperatures.';

  @override
  String get changeLog_275_3 =>
      'Added a \"not importable\" warning to CSV exporting.';

  @override
  String get changeLog_276_1 => 'Fixed number formatting in some regions.';

  @override
  String get changeLog_277_1 =>
      'Fixed crash when device\'s location was turned off.';

  @override
  String get changeLog_277_2 => 'Fixed rare crash while onboarding.';

  @override
  String get changeLog_277_3 => 'Fixed number formatting for users in Norway.';

  @override
  String get changeLog_278_1 =>
      'Fixed a crash when requesting location permission.';

  @override
  String get changeLog_278_2 =>
      'Fixed the app freezing on startup for users in certain regions.';

  @override
  String get translationWarningPageTitle => 'Translations';

  @override
  String get translationWarningPageDescription =>
      'The text in Anglers\' Log has been translated using AI. If you notice a mistake, or something doesn\'t make sense, please reach out by tapping More, then Send Feedback. Your help is always appreciated, thank you!';

  @override
  String get backupRestorePageOpenDoc => 'Open Documentation';

  @override
  String get backupRestorePageWarningApple =>
      'The backup and restore feature has proven to be unreliable, and we are considering other options. In the meantime, it is highly recommended that you setup automatic backups for your entire device to ensure no data is lost. For more information, visit Apple\'s documentation.';

  @override
  String get backupRestorePageWarningGoogle =>
      'The backup and restore feature has proven to be unreliable, and we are considering other options. In the meantime, it is highly recommended that you setup automatic backups for your entire device to ensure no data is lost. For more information, visit Google\'s documentation.';

  @override
  String get backupRestorePageWarningOwnRisk =>
      'Use this feature at your own risk.';

  @override
  String get proPageBackupWarning =>
      'Auto-backup has proven to be unreliable. Use this feature at your own risk while we investigate. For more details, visit the Backup and Restore pages in the More menu.';

  @override
  String get changeLog_279_1 => 'Fixed some user interface bugs.';

  @override
  String get changeLog_279_2 =>
      'Added a warning to reflect the unreliability of cloud backup.';

  @override
  String get changeLog_279_3 => 'Add Spanish translations.';

  @override
  String get changeLog_2710_1 =>
      'Fixed large number formatting for regions that use apostrophes.';

  @override
  String get changeLog_2710_2 =>
      'Fixed some text alignment issues on the Pro page.';

  @override
  String get changeLog_2711_1 =>
      'Fixed an error sending feedback without an email address.';

  @override
  String get changeLog_2711_2 =>
      'Catches can now be added while adding Trips without closing the save Trip page.';

  @override
  String get changeLog_2711_3 =>
      'Fixed missing \"Since Last Catch\" and \"Since Last Trip\" stats tiles.';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AnglersLogLocalizationsEnGb extends AnglersLogLocalizationsEn {
  AnglersLogLocalizationsEnGb() : super('en_GB');

  @override
  String get tripSkunked => 'Blanked';
}

/// The translations for English, as used in the United States (`en_US`).
class AnglersLogLocalizationsEnUs extends AnglersLogLocalizationsEn {
  AnglersLogLocalizationsEnUs() : super('en_US');

  @override
  String get catchFieldFavorite => 'Favorite';

  @override
  String get catchFieldFavoriteDescription =>
      'Whether a catch was one of your favorites.';

  @override
  String get saveReportPageFavorites => 'Favorites Only';

  @override
  String get saveReportPageFavoritesFilter => 'Favorites only';

  @override
  String unitsPageCentimeters(String value) {
    return 'Centimeters ($value)';
  }

  @override
  String unitsPageMeters(String value) {
    return 'Meters ($value)';
  }

  @override
  String unitsPageAirVisibilityKilometers(String value) {
    return 'Kilometers ($value)';
  }

  @override
  String unitsPageWindSpeedKilometers(String value) {
    return 'Kilometers per hour ($value)';
  }

  @override
  String unitsPageWindSpeedMeters(String value) {
    return 'Meters per second ($value)';
  }

  @override
  String get inputColorLabel => 'Color';
}
