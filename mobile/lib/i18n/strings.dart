import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/english_strings.dart';

typedef LocalizedString = String Function(BuildContext);

class Strings {
  static const List<Locale> supportedLocales = [
    Locale("en", "US"),
    Locale("en", "CA"),
    Locale("en", "GB"),
    Locale("en", "AU"),
  ];

  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> get _values => {
        "en": englishStrings,
      };

  static Strings of(BuildContext context) =>
      Localizations.of<Strings>(context, Strings)!;

  final Locale _locale;

  Strings(this._locale);

  /// Should be used sparingly, and only to avoid passing a Context object
  /// around unnecessarily.
  String fromId(String id) => _string(id);

  /// If a specific string for a language and country exists, use it, otherwise
  /// use the default.
  String _string(String key) {
    var langCode = _locale.languageCode;
    if (!_values.containsKey(langCode)) {
      // Current locale not supported, default to English.
      langCode = "en";
    }

    var langMap = _values[langCode]!;

    String? result;
    if (isNotEmpty(_locale.countryCode) &&
        langMap.containsKey(_locale.countryCode!)) {
      result = langMap[_locale.countryCode!]![key];
    }

    if (result == null && langMap.containsKey("default")) {
      result = langMap["default"]![key];
    }

    assert(result != null, "String key $key doesn't exist");
    return result!;
  }

  String get appName => _string("appName");

  String get hashtag => _string("hashtag");

  String get shareTextAndroid => _string("share_textAndroid");

  String get shareTextApple => _string("share_textApple");

  String get shareLength => _string("share_length");

  String get shareWeight => _string("share_weight");

  String get shareBait => _string("share_bait");

  String get shareBaits => _string("share_baits");

  String get shareCatches => _string("share_catches");

  String get rateDialogTitle => _string("rateDialog_title");

  String get rateDialogDescription => _string("rateDialog_description");

  String get rateDialogRate => _string("rateDialog_rate");

  String get rateDialogLater => _string("rateDialog_later");

  String get cancel => _string("cancel");

  String get done => _string("done");

  String get save => _string("save");

  String get edit => _string("edit");

  String get delete => _string("delete");

  String get none => _string("none");

  String get all => _string("all");

  String get next => _string("next");

  String get ok => _string("ok");

  String get error => _string("error");

  String get warning => _string("warning");

  String get continueString => _string("continue");

  String get yes => _string("yes");

  String get no => _string("no");

  String get clear => _string("clear");

  String get today => _string("today");

  String get yesterday => _string("yesterday");

  String get directions => _string("directions");

  String get close => _string("close");

  String get back => _string("back");

  String get latLng => _string("latLng");

  String get latLngNoLabels => _string("latLng_noLabels");

  String get add => _string("add");

  String get more => _string("more");

  String get na => _string("na");

  String get finish => _string("finish");

  String get by => _string("by");

  String get unknown => _string("unknown");

  String get devName => _string("devName");

  String get numberOfCatches => _string("numberOfCatches");

  String get numberOfCatchesSingular => _string("numberOfCatchesSingular");

  String get unknownSpecies => _string("unknownSpecies");

  String get unknownBait => _string("unknownBait");

  String get viewDetails => _string("viewDetails");

  String get viewAll => _string("viewAll");

  String get share => _string("share");

  String get fieldTypeNumber => _string("fieldType_number");

  String get fieldTypeBoolean => _string("fieldType_boolean");

  String get fieldTypeText => _string("fieldType_text");

  String get inputRequiredMessage => _string("input_requiredMessage");

  String get inputNameLabel => _string("input_nameLabel");

  String get inputColorLabel => _string("input_colorLabel");

  String get inputGenericRequired => _string("input_genericRequired");

  String get inputDescriptionLabel => _string("input_descriptionLabel");

  String get inputNotesLabel => _string("input_notesLabel");

  String get inputInvalidNumber => _string("input_invalidNumber");

  String get inputPhotoLabel => _string("input_photoLabel");

  String get inputPhotosLabel => _string("input_photosLabel");

  String get inputNotSelected => _string("input_notSelected");

  String get inputEmailLabel => _string("input_emailLabel");

  String get inputInvalidEmail => _string("input_invalidEmail");

  String get inputPasswordLabel => _string("input_passwordLabel");

  String get inputPasswordInvalidLength =>
      _string("input_passwordInvalidLength");

  String get inputAtmosphere => _string("input_atmosphere");

  String get inputFetch => _string("input_fetch");

  String get inputAutoFetch => _string("input_autoFetch");

  String get inputCurrentLocation => _string("input_currentLocation");

  String get inputGenericFetchError => _string("input_genericFetchError");

  String get tripListPageTitle => _string("tripListPage_title");

  String get tripListPageSearchHint => _string("tripListPage_searchHint");

  String get tripListPageEmptyListTitle =>
      _string("tripListPage_emptyListTitle");

  String get tripListPageEmptyListDescription =>
      _string("tripListPage_emptyListDescription");

  String get tripListPageDeleteMessage => _string("tripListPage_deleteMessage");

  String get saveTripPageEditTitle => _string("saveTripPage_editTitle");

  String get saveTripPageNewTitle => _string("saveTripPage_newTitle");

  String get saveTripPageAutoSetTitle => _string("saveTripPage_autoSetTitle");

  String get saveTripPageAutoSetDescription =>
      _string("saveTripPage_autoSetDescription");

  String get saveTripPageStartDate => _string("saveTripPage_startDate");

  String get saveTripPageStartTime => _string("saveTripPage_startTime");

  String get saveTripPageStartDateTime => _string("saveTripPage_startDateTime");

  String get saveTripPageEndDate => _string("saveTripPage_endDate");

  String get saveTripPageEndTime => _string("saveTripPage_endTime");

  String get saveTripPageEndDateTime => _string("saveTripPage_endDateTime");

  String get saveTripPageAllDay => _string("saveTripPage_allDay");

  String get saveTripPageCatchesDesc => _string("saveTripPage_catchesDesc");

  String get saveTripPageNoCatches => _string("saveTripPage_noCatches");

  String get saveTripPageNoBodiesOfWater =>
      _string("saveTripPage_noBodiesOfWater");

  String get saveTripPageNoGpsTrails => _string("saveTripPage_noGpsTrails");

  String get tripCatchesPerSpecies => _string("trip_catchesPerSpecies");

  String get tripCatchesPerFishingSpot => _string("trip_catchesPerFishingSpot");

  String get tripCatchesPerAngler => _string("trip_catchesPerAngler");

  String get tripCatchesPerBait => _string("trip_catchesPerBait");

  String get tripSkunked => _string("trip_skunked");

  String get catchListPageTitle => _string("catchListPage_title");

  String get catchListPageSearchHint => _string("catchListPage_searchHint");

  String get catchListPageEmptyListTitle =>
      _string("catchListPage_emptyListTitle");

  String get catchListPageEmptyListDescription =>
      _string("catchListPage_emptyListDescription");

  String get catchListItemLength => _string("catchListItem_length");

  String get catchListItemWeight => _string("catchListItem_weight");

  String get catchListItemNotSet => _string("catchListItem_notSet");

  String get catchPageDeleteMessage => _string("catchPage_deleteMessage");

  String get catchPageDeleteWithTripMessage =>
      _string("catchPage_deleteWithTripMessage");

  String get catchPageReleased => _string("catchPage_released");

  String get catchPageKept => _string("catchPage_kept");

  String get catchPageQuantityLabel => _string("catchPage_quantityLabel");

  String get saveCatchPageNewTitle => _string("saveCatchPage_newTitle");

  String get saveCatchPageEditTitle => _string("saveCatchPage_editTitle");

  String get catchFieldTide => _string("catchField_tide");

  String get catchFieldDateTime => _string("catchField_dateTime");

  String get catchFieldDate => _string("catchField_date");

  String get catchFieldTime => _string("catchField_time");

  String get catchFieldCatchAndRelease => _string("catchField_catchAndRelease");

  String get catchFieldCatchAndReleaseDescription =>
      _string("catchField_catchAndReleaseDescription");

  String get catchFieldFavorite => _string("catchField_favorite");

  String get catchFieldFavoriteDescription =>
      _string("catchField_favoriteDescription");

  String get catchFieldPeriod => _string("catchField_period");

  String get catchFieldPeriodDescription =>
      _string("catchField_periodDescription");

  String get catchFieldSeason => _string("catchField_season");

  String get catchFieldSeasonDescription =>
      _string("catchField_seasonDescription");

  String get catchFieldImages => _string("catchField_images");

  String get catchFieldFishingSpot => _string("catchField_fishingSpot");

  String get catchFieldFishingSpotDescription =>
      _string("catchField_fishingSpotDescription");

  String get catchFieldBaitLabel => _string("catchField_bait");

  String get catchFieldAnglerLabel => _string("catchField_angler");

  String get catchFieldGearLabel => _string("catchField_gear");

  String get catchFieldMethodsDescription =>
      _string("catchField_methodsDescription");

  String get catchFieldNoMethods => _string("catchField_noMethods");

  String get catchFieldNoBaits => _string("catchField_noBaits");

  String get catchFieldNoGear => _string("catchField_noGear");

  String get catchFieldWaterClarityLabel =>
      _string("catchField_waterClarityLabel");

  String get catchFieldWaterDepthLabel => _string("catchField_waterDepthLabel");

  String get catchFieldWaterDepthFeet => _string("catchField_waterDepthFeet");

  String get catchFieldTideHeightLabel => _string("catchField_tideHeightLabel");

  String get catchFieldWaterDepthInches =>
      _string("catchField_waterDepthInches");

  String get catchFieldWaterDepthMeters =>
      _string("catchField_waterDepthMeters");

  String get catchFieldWaterTemperatureLabel =>
      _string("catchField_waterTemperatureLabel");

  String get catchFieldLengthLabel => _string("catchField_lengthLabel");

  String get catchFieldWeightLabel => _string("catchField_weightLabel");

  String get catchFieldQuantityLabel => _string("catchField_quantityLabel");

  String get catchFieldQuantityDescription =>
      _string("catchField_quantityDescription");

  String get catchFieldNotesLabel => _string("catchField_notesLabel");

  String get saveReportPageNewTitle => _string("saveReportPage_newTitle");

  String get saveReportPageEditTitle => _string("saveReportPage_editTitle");

  String get saveReportPageNameExists => _string("saveReportPage_nameExists");

  String get saveReportTypeTitle => _string("saveReportPage_typeTitle");

  String get saveReportPageComparison => _string("saveReportPage_comparison");

  String get saveReportPageSummary => _string("saveReportPage_summary");

  String get saveReportPageStartDateRangeLabel =>
      _string("saveReportPage_startDateRangeLabel");

  String get saveReportPageEndDateRangeLabel =>
      _string("saveReportPage_endDateRangeLabel");

  String get saveReportPageAllAnglers => _string("saveReportPage_allAnglers");

  String get saveReportPageAllWaterClarities =>
      _string("saveReportPage_allWaterClarities");

  String get saveReportPageAllSpecies => _string("saveReportPage_allSpecies");

  String get saveReportPageAllBaits => _string("saveReportPage_allBaits");

  String get saveReportPageAllGear => _string("saveReportPage_allGear");

  String get saveReportPageAllBodiesOfWater =>
      _string("saveReportPage_allBodiesOfWater");

  String get saveReportPageAllFishingSpots =>
      _string("saveReportPage_allFishingSpots");

  String get saveReportPageAllMethods => _string("saveReportPage_allMethods");

  String get saveReportPageCatchAndRelease =>
      _string("saveReportPage_catchAndRelease");

  String get saveReportPageCatchAndReleaseFilter =>
      _string("saveReportPage_catchAndReleaseFilter");

  String get saveReportPageFavorites => _string("saveReportPage_favorites");

  String get saveReportPageFavoritesFilter =>
      _string("saveReportPage_favoritesFilter");

  String get saveReportPageAllWindDirections =>
      _string("saveReportPage_allWindDirections");

  String get saveReportPageAllSkyConditions =>
      _string("saveReportPage_allSkyConditions");

  String get saveReportPageAllMoonPhases =>
      _string("saveReportPage_allMoonPhases");

  String get saveReportPageAllTideTypes =>
      _string("saveReportPage_allTideTypes");

  String get photosPageMenuLabel => _string("photosPage_menuLabel");

  String get photosPageTitle => _string("photosPage_title");

  String get photosPageEmptyTitle => _string("photosPage_emptyTitle");

  String get photosPageEmptyDescription =>
      _string("photosPage_emptyDescription");

  String get baitListPageTitle => _string("baitListPage_title");

  String get baitListPageOtherCategory => _string("baitListPage_otherCategory");

  String get baitListPageSearchHint => _string("baitListPage_searchHint");

  String get baitListPageDeleteMessage => _string("baitListPage_deleteMessage");

  String get baitListPageDeleteMessageSingular =>
      _string("baitListPage_deleteMessageSingular");

  String get baitListPageEmptyListTitle =>
      _string("baitListPage_emptyListTitle");

  String get baitListPageEmptyListDescription =>
      _string("baitListPage_emptyListDescription");

  String get baitsSummaryEmpty => _string("baitsSummary_empty");

  String get baitListPageVariantsLabel => _string("baitListPage_variantsLabel");

  String get baitListPageVariantLabel => _string("baitListPage_variantLabel");

  String get reportListPageConfirmDelete =>
      _string("reportListPage_confirmDelete");

  String get reportListPageReportTitle => _string("reportListPage_reportTitle");

  String get reportListPageReportAddNote =>
      _string("reportListPage_reportAddNote");

  String get reportListPageReportsProDescription =>
      _string("reportListPage_reportsProDescription");

  String get saveBaitPageNewTitle => _string("saveBaitPage_newTitle");

  String get saveBaitPageEditTitle => _string("saveBaitPage_editTitle");

  String get saveBaitPageCategoryLabel => _string("saveBaitPage_categoryLabel");

  String get saveBaitPageBaitExists => _string("saveBaitPage_baitExists");

  String get saveBaitPageVariants => _string("saveBaitPage_variants");

  String get saveBaitPageDeleteVariantSingular =>
      _string("saveBaitPage_deleteVariantSingular");

  String get saveBaitPageDeleteVariantPlural =>
      _string("saveBaitPage_deleteVariantPlural");

  String get saveBaitCategoryPageNewTitle =>
      _string("saveBaitCategoryPage_newTitle");

  String get saveBaitCategoryPageEditTitle =>
      _string("saveBaitCategoryPage_editTitle");

  String get saveBaitCategoryPageExistsMessage =>
      _string("saveBaitCategoryPage_existsMessage");

  String get baitCategoryListPageTitle => _string("baitCategoryListPage_title");

  String get baitCategoryListPageDeleteMessage =>
      _string("baitCategoryListPage_deleteMessage");

  String get baitCategoryListPageDeleteMessageSingular =>
      _string("baitCategoryListPage_deleteMessageSingular");

  String get baitCategoryListPageSearchHint =>
      _string("baitCategoryListPage_searchHint");

  String get baitCategoryListPageEmptyListTitle =>
      _string("baitCategoryListPage_emptyListTitle");

  String get baitCategoryListPageEmptyListDescription =>
      _string("baitCategoryListPage_emptyListDescription");

  String get saveAnglerPageNewTitle => _string("saveAnglerPage_newTitle");

  String get saveAnglerPageEditTitle => _string("saveAnglerPage_editTitle");

  String get saveAnglerPageExistsMessage =>
      _string("saveAnglerPage_existsMessage");

  String get anglerListPageTitle => _string("anglerListPage_title");

  String get anglerListPageDeleteMessage =>
      _string("anglerListPage_deleteMessage");

  String get anglerListPageDeleteMessageSingular =>
      _string("anglerListPage_deleteMessageSingular");

  String get anglerListPageSearchHint => _string("anglerListPage_searchHint");

  String get anglerListPageEmptyListTitle =>
      _string("anglerListPage_emptyListTitle");

  String get anglerListPageEmptyListDescription =>
      _string("anglerListPage_emptyListDescription");

  String get anglersSummaryEmpty => _string("anglersSummary_empty");

  String get saveMethodPageNewTitle => _string("saveMethodPage_newTitle");

  String get saveMethodPageEditTitle => _string("saveMethodPage_editTitle");

  String get saveMethodPageExistsMessage =>
      _string("saveMethodPage_existsMessage");

  String get methodListPageTitle => _string("methodListPage_title");

  String get methodListPageDeleteMessage =>
      _string("methodListPage_deleteMessage");

  String get methodListPageDeleteMessageSingular =>
      _string("methodListPage_deleteMessageSingular");

  String get methodListPageSearchHint => _string("methodListPage_searchHint");

  String get methodListPageEmptyListTitle =>
      _string("methodListPage_emptyListTitle");

  String get methodListPageEmptyListDescription =>
      _string("methodListPage_emptyListDescription");

  String get methodSummaryEmpty => _string("methodSummary_empty");

  String get saveWaterClarityPageNewTitle =>
      _string("saveWaterClarityPage_newTitle");

  String get saveWaterClarityPageEditTitle =>
      _string("saveWaterClarityPage_editTitle");

  String get saveWaterClarityPageExistsMessage =>
      _string("saveWaterClarityPage_existsMessage");

  String get waterClarityListPageTitle => _string("waterClarityListPage_title");

  String get waterClarityListPageDeleteMessage =>
      _string("waterClarityListPage_deleteMessage");

  String get waterClarityListPageDeleteMessageSingular =>
      _string("waterClarityListPage_deleteMessageSingular");

  String get waterClarityListPageSearchHint =>
      _string("waterClarityListPage_searchHint");

  String get waterClarityListPageEmptyListTitle =>
      _string("waterClarityListPage_emptyListTitle");

  String get waterClarityListPageEmptyListDescription =>
      _string("waterClarityListPage_emptyListDescription");

  String get waterClaritiesSummaryEmpty =>
      _string("waterClaritiesSummary_empty");

  String get statsPageMenuTitle => _string("statsPage_menuTitle");

  String get statsPageTitle => _string("statsPage_title");

  String get statsPageNewReport => _string("statsPage_newReport");

  String get statsPageSpeciesSummary => _string("statsPage_speciesSummary");

  String get statsPageCatchSummary => _string("statsPage_catchSummary");

  String get statsPageAnglerSummary => _string("statsPage_anglerSummary");

  String get statsPageBaitSummary => _string("statsPage_baitSummary");

  String get statsPageBaitVariantAllLabel =>
      _string("statsPage_baitVariantAllLabel");

  String get statsPageBodyOfWaterSummary =>
      _string("statsPage_bodyOfWaterSummary");

  String get statsPageFishingSpotSummary =>
      _string("statsPage_fishingSpotSummary");

  String get statsPageMethodSummary => _string("statsPage_methodSummary");

  String get statsPageMoonPhaseSummary => _string("statsPage_moonPhaseSummary");

  String get statsPagePeriodSummary => _string("statsPage_periodSummary");

  String get statsPageSeasonSummary => _string("statsPage_seasonSummary");

  String get statsPageTideSummary => _string("statsPage_tideSummary");

  String get statsPageWaterClaritySummary =>
      _string("statsPage_waterClaritySummary");

  String get statsPageGearSummary => _string("statsPage_gearSummary");

  String get statsPagePersonalBests => _string("statsPage_waterPersonalBests");

  String get personalBestsTrip => _string("personalBests_trip");

  String get personalBestsLongest => _string("personalBests_longest");

  String get personalBestsHeaviest => _string("personalBests_heaviest");

  String get personalBestsSpeciesByLength =>
      _string("personalBests_speciesByLength");

  String get personalBestsSpeciesByLengthLabel =>
      _string("personalBests_speciesByLengthLabel");

  String get personalBestsSpeciesByWeight =>
      _string("personalBests_speciesByWeight");

  String get personalBestsSpeciesByWeightLabel =>
      _string("personalBests_speciesByWeightLabel");

  String get personalBestsShowAllSpecies =>
      _string("personalBests_showAllSpecies");

  String get personalBestsAverage => _string("personalBests_average");

  String get personalBestsNoDataTitle => _string("personalBests_noDataTitle");

  String get personalBestsNoDataDescription =>
      _string("personalBests_noDataDescription");

  String get reportViewEmptyLog => _string("reportView_emptyLog");

  String get reportViewEmptyLogDescription =>
      _string("reportView_emptyLogDescription");

  String get reportViewNoCatches => _string("reportView_noCatches");

  String get reportViewNoCatchesDescription =>
      _string("reportView_noCatchesDescription");

  String get reportViewNoCatchesReportDescription =>
      _string("reportView_noCatchesReportDescription");

  String get reportSummaryViewCatches => _string("reportSummary_viewCatches");

  String get reportSummaryCatchTitle => _string("reportSummary_catchTitle");

  String get reportSummaryPerSpecies => _string("reportSummary_perSpecies");

  String get reportSummaryPerFishingSpot =>
      _string("reportSummary_perFishingSpot");

  String get reportSummaryPerBait => _string("reportSummary_perBait");

  String get reportSummaryPerAngler => _string("reportSummary_perAngler");

  String get reportSummaryPerBodyOfWater =>
      _string("reportSummary_perBodyOfWater");

  String get reportSummaryPerMethod => _string("reportSummary_perMethod");

  String get reportSummaryPerMoonPhase => _string("reportSummary_perMoonPhase");

  String get reportSummaryPerPeriod => _string("reportSummary_perPeriod");

  String get reportSummaryPerSeason => _string("reportSummary_perSeason");

  String get reportSummaryPerTideType => _string("reportSummary_perTideType");

  String get reportSummaryPerWaterClarity =>
      _string("reportSummary_perWaterClarity");

  String get reportSummarySinceLastCatch =>
      _string("reportSummary_sinceLastCatch");

  String get reportSummaryNumberOfCatches =>
      _string("reportSummary_numberOfCatches");

  String get reportSummaryFilters => _string("reportSummary_filters");

  String get reportSummaryViewSpecies => _string("reportSummary_viewSpecies");

  String get reportSummaryPerSpeciesDescription =>
      _string("reportSummary_perSpeciesDescription");

  String get reportSummaryViewFishingSpots =>
      _string("reportSummary_viewFishingSpots");

  String get reportSummaryPerFishingSpotDescription =>
      _string("reportSummary_perFishingSpotDescription");

  String get reportSummaryViewBaits => _string("reportSummary_viewBaits");

  String get reportSummaryPerBaitDescription =>
      _string("reportSummary_perBaitDescription");

  String get reportSummaryViewMoonPhases =>
      _string("reportSummary_viewMoonPhases");

  String get reportSummaryPerMoonPhaseDescription =>
      _string("reportSummary_perMoonPhaseDescription");

  String get reportSummaryViewTides => _string("reportSummary_viewTides");

  String get reportSummaryPerTideDescription =>
      _string("reportSummary_perTideDescription");

  String get reportSummaryViewAnglers => _string("reportSummary_viewAnglers");

  String get reportSummaryPerAnglerDescription =>
      _string("reportSummary_perAnglerDescription");

  String get reportSummaryViewBodiesOfWater =>
      _string("reportSummary_viewBodiesOfWater");

  String get reportSummaryPerBodyOfWaterDescription =>
      _string("reportSummary_perBodyOfWaterDescription");

  String get reportSummaryViewMethods => _string("reportSummary_viewMethods");

  String get reportSummaryPerMethodDescription =>
      _string("reportSummary_perMethodDescription");

  String get reportSummaryViewPeriods => _string("reportSummary_viewPeriods");

  String get reportSummaryPerPeriodDescription =>
      _string("reportSummary_perPeriodDescription");

  String get reportSummaryViewSeasons => _string("reportSummary_viewSeasons");

  String get reportSummaryPerSeasonDescription =>
      _string("reportSummary_perSeasonDescription");

  String get reportSummaryViewWaterClarities =>
      _string("reportSummary_viewWaterClarities");

  String get reportSummaryPerWaterClarityDescription =>
      _string("reportSummary_perWaterClarityDescription");

  String get reportSummaryPerHour => _string("reportSummary_perHour");

  String get reportSummaryViewAllHours => _string("reportSummary_viewAllHours");

  String get reportSummaryViewAllHoursDescription =>
      _string("reportSummary_viewAllHoursDescription");

  String get reportSummaryPerMonth => _string("reportSummary_perMonth");

  String get reportSummaryViewAllMonths =>
      _string("reportSummary_viewAllMonths");

  String get reportSummaryViewAllMonthsDescription =>
      _string("reportSummary_viewAllMonthsDescription");

  String get reportSummarySpeciesTitle => _string("reportSummary_speciesTitle");

  String get reportSummaryPerGear => _string("reportSummary_perGear");

  String get reportSummaryViewGear => _string("reportSummary_viewGear");

  String get reportSummaryPerGearDescription =>
      _string("reportSummary_perGearDescription");

  String get morePageTitle => _string("morePage_title");

  String get morePageRateApp => _string("morePage_rateApp");

  String get morePagePro => _string("morePage_pro");

  String get morePageRateErrorApple => _string("morePage_rateErrorApple");

  String get morePageRateErrorAndroid => _string("morePage_rateErrorAndroid");

  String get settingsPageTitle => _string("settingsPage_title");

  String get settingsPageLogout => _string("settingsPage_logout");

  String get settingsPageLogoutConfirmMessage =>
      _string("settingsPage_logoutConfirmMessage");

  String get settingsPageFetchAtmosphereTitle =>
      _string("settingsPage_fetchAtmosphereTitle");

  String get settingsPageFetchAtmosphereDescription =>
      _string("settingsPage_fetchAtmosphereDescription");

  String get settingsPageFetchTideTitle =>
      _string("settingsPage_fetchTideTitle");

  String get settingsPageFetchTideDescription =>
      _string("settingsPage_fetchTideDescription");

  String get settingsPageAbout => _string("settingsPage_about");

  String get settingsPageFishingSpotDistanceTitle =>
      _string("settingsPage_fishingSpotDistanceTitle");

  String get settingsPageMinGpsTrailDistanceTitle =>
      _string("settingsPage_minGpsTrailDistanceTitle");

  String get settingsPageMinGpsTrailDistanceDescription =>
      _string("settingsPage_minGpsTrailDistanceDescription");

  String get settingsPageFishingSpotDistanceDescription =>
      _string("settingsPage_fishingSpotDistanceDescription");

  String get settingsPageThemeTitle => _string("settingsPage_themeTitle");

  String get settingsPageThemeSystem => _string("settingsPage_themeSystem");

  String get settingsPageThemeLight => _string("settingsPage_themeLight");

  String get settingsPageThemeDark => _string("settingsPage_themeDark");

  String get settingsPageThemeSelect => _string("settingsPage_themeSelect");

  String get unitsPageTitle => _string("unitsPage_title");

  String get unitsPageCatchLength => _string("unitsPage_catchLength");

  String get unitsPageCentimeters => _string("unitsPage_centimeters");

  String get unitsPageMeters => _string("unitsPage_meters");

  String get unitsPageAirVisibilityKilometers =>
      _string("unitsPage_airVisibilityKilometers");

  String get unitsPageWindSpeedKilometers =>
      _string("unitsPage_windSpeedKilometers");

  String get unitsPageFractionalInches => _string("unitsPage_fractionalInches");

  String get unitsPageInches => _string("unitsPage_inches");

  String get unitsPageCatchWeight => _string("unitsPage_catchWeight");

  String get unitsPageCatchWeightPoundsOunces =>
      _string("unitsPage_catchWeightPoundsOunces");

  String get unitsPageCatchWeightPounds =>
      _string("unitsPage_catchWeightPounds");

  String get unitsPageCatchWeightKilograms =>
      _string("unitsPage_catchWeightKilograms");

  String get unitsPageWaterTemperatureFahrenheit =>
      _string("unitsPage_waterTemperatureFahrenheit");

  String get unitsPageWaterTemperatureCelsius =>
      _string("unitsPage_waterTemperatureCelsius");

  String get unitsPageFeetInches => _string("unitsPage_feetInches");

  String get unitsPageFeet => _string("unitsPage_feet");

  String get unitsPageAirTemperatureFahrenheit =>
      _string("unitsPage_airTemperatureFahrenheit");

  String get unitsPageAirTemperatureCelsius =>
      _string("unitsPage_airTemperatureCelsius");

  String get unitsPageAirPressureInHg => _string("unitsPage_airPressureInHg");

  String get unitsPageAirPressurePsi => _string("unitsPage_airPressurePsi");

  String get unitsPageAirPressureMillibars =>
      _string("unitsPage_airPressureMillibars");

  String get unitsPageAirVisibilityMiles =>
      _string("unitsPage_airVisibilityMiles");

  String get unitsPageWindSpeedMiles => _string("unitsPage_windSpeedMiles");

  String get unitsPageDistanceTitle => _string("unitsPage_distanceTitle");

  String get unitsPageRodLengthTitle => _string("unitsPage_rodLengthTitle");

  String get unitsPageRodLengthFeetAndInches =>
      _string("unitsPage_rodLengthFeetAndInches");

  String get unitsPageRodLengthFeet => _string("unitsPage_rodLengthFeet");

  String get unitsPageRodLengthMeters => _string("unitsPage_rodLengthMeters");

  String get unitsPageLeaderLengthTitle =>
      _string("unitsPage_leaderLengthTitle");

  String get unitsPageLeaderLengthFeetAndInches =>
      _string("unitsPage_leaderLengthFeetAndInches");

  String get unitsPageLeaderLengthFeet => _string("unitsPage_leaderLengthFeet");

  String get unitsPageLeaderLengthMeters =>
      _string("unitsPage_leaderLengthMeters");

  String get unitsPageTippetLengthTitle =>
      _string("unitsPage_tippetLengthTitle");

  String get unitsPageTippetLengthInches =>
      _string("unitsPage_tippetLengthInches");

  String get unitsPageTippetLengthCentimeters =>
      _string("unitsPage_tippetLengthCentimeters");

  String get mapPageMenuLabel => _string("mapPage_menuLabel");

  String get mapPageDeleteFishingSpot => _string("mapPage_deleteFishingSpot");

  String get mapPageDeleteFishingSpotSingular =>
      _string("mapPage_deleteFishingSpotSingular");

  String get mapPageDeleteFishingSpotNoName =>
      _string("mapPage_deleteFishingSpotNoName");

  String get mapPageDeleteFishingSpotNoNameSingular =>
      _string("mapPage_deleteFishingSpotNoNameSingular");

  String get mapPageAddCatch => _string("mapPage_addCatch");

  String get mapPageSearchHint => _string("mapPage_searchHint");

  String get mapPageDroppedPin => _string("mapPage_droppedPin");

  String get mapPageMapTypeLight => _string("mapPage_mapTypeLight");

  String get mapPageMapTypeSatellite => _string("mapPage_mapTypeSatellite");

  String get mapPageMapTypeDark => _string("mapPage_mapTypeDark");

  String get mapPageErrorGettingLocation =>
      _string("mapPage_errorGettingLocation");

  String get mapPageAppleMaps => _string("mapPage_appleMaps");

  String get mapPageGoogleMaps => _string("mapPage_googleMaps");

  String get mapPageWaze => _string("mapPage_waze");

  String get mapPageErrorOpeningDirections =>
      _string("mapPage_errorOpeningDirections");

  String get mapPageMapTypeTooltip => _string("mapPage_mapTypeTooltip");

  String get mapPageMyLocationTooltip => _string("mapPage_myLocationTooltip");

  String get mapPageShowAllTooltip => _string("mapPage_showAllTooltip");

  String get mapPageStartTrackingTooltip =>
      _string("mapPage_startTrackingTooltip");

  String get mapPageStopTrackingTooltip =>
      _string("mapPage_stopTrackingTooltip");

  String get mapPageAddTooltip => _string("mapPage_addTooltip");

  String get saveFishingSpotPageNewTitle =>
      _string("saveFishingSpotPage_newTitle");

  String get saveFishingSpotPageEditTitle =>
      _string("saveFishingSpotPage_editTitle");

  String get saveFishingSpotPageBodyOfWaterLabel =>
      _string("saveFishingSpotPage_bodyOfWaterLabel");

  String get saveFishingSpotPageCoordinatesLabel =>
      _string("saveFishingSpotPage_coordinatesLabel");

  String get formPageManageFieldText => _string("formPage_manageFieldText");

  String get formPageRemoveFieldsText => _string("formPage_removeFieldsText");

  String get formPageConfirmRemoveField =>
      _string("formPage_confirmRemoveField");

  String get formPageConfirmRemoveFields =>
      _string("formPage_confirmRemoveFields");

  String get formPageItemAddCustomFieldNote =>
      _string("formPage_addCustomFieldNote");

  String get formPageManageFieldsNote => _string("formPage_manageFieldsNote");

  String get formPageManageFieldsProDescription =>
      _string("formPage_manageFieldsProDescription");

  String get formPageManageUnits => _string("formPage_manageUnits");

  String get formPageConfirmBackDesc => _string("formPage_confirmBackDesc");

  String get formPageConfirmBackAction => _string("formPage_confirmBackAction");

  String get imagePickerConfirmDelete => _string("imagePicker_confirmDelete");

  String get imagePickerPageNoPhotosFoundTitle =>
      _string("imagePickerPage_noPhotosFoundTitle");

  String get imagePickerPageNoPhotosFound =>
      _string("imagePickerPage_noPhotosFound");

  String get imagePickerPageOpenCameraLabel =>
      _string("imagePickerPage_openCameraLabel");

  String get imagePickerPageCameraLabel =>
      _string("imagePickerPage_cameraLabel");

  String get imagePickerPageGalleryLabel =>
      _string("imagePickerPage_galleryLabel");

  String get imagePickerPageBrowseLabel =>
      _string("imagePickerPage_browseLabel");

  String get imagePickerPageSelectedLabel =>
      _string("imagePickerPage_selectedLabel");

  String get imagePickerPageInvalidSelectionSingle =>
      _string("imagePickerPage_invalidSelectionSingle");

  String get imagePickerPageInvalidSelectionPlural =>
      _string("imagePickerPage_invalidSelectionPlural");

  String get imagePickerPageNoPermissionTitle =>
      _string("imagePickerPage_noPermissionTitle");

  String get imagePickerPageNoPermissionMessage =>
      _string("imagePickerPage_noPermissionMessage");

  String get imagePickerPageOpenSettings =>
      _string("imagePickerPage_openSettings");

  String get imagePickerPageImageDownloadError =>
      _string("imagePickerPage_imageDownloadError");

  String get imagePickerPageImagesDownloadError =>
      _string("imagePickerPage_imagesDownloadError");

  String get saveSpeciesPageNewTitle => _string("saveSpeciesPage_newTitle");

  String get saveSpeciesPageEditTitle => _string("saveSpeciesPage_editTitle");

  String get saveSpeciesPageExistsError =>
      _string("saveSpeciesPage_existsError");

  String get speciesListPageTitle => _string("speciesListPage_title");

  String get speciesListPageConfirmDelete =>
      _string("speciesListPage_confirmDelete");

  String get speciesListPageCatchDeleteErrorSingular =>
      _string("speciesListPage_catchDeleteErrorSingular");

  String get speciesListPageCatchDeleteErrorPlural =>
      _string("speciesListPage_catchDeleteErrorPlural");

  String get speciesListPageSearchHint => _string("speciesListPage_searchHint");

  String get speciesListPageEmptyListTitle =>
      _string("speciesListPage_emptyListTitle");

  String get speciesListPageEmptyListDescription =>
      _string("speciesListPage_emptyListDescription");

  String get fishingSpotPickerPageHint => _string("fishingSpotPickerPage_hint");

  String get fishingSpotListPageTitle => _string("fishingSpotListPage_title");

  String get fishingSpotListPageSearchHint =>
      _string("fishingSpotListPage_searchHint");

  String get fishingSpotListPageEmptyListTitle =>
      _string("fishingSpotListPage_emptyListTitle");

  String get fishingSpotListPageEmptyListDescription =>
      _string("fishingSpotListPage_emptyListDescription");

  String get fishingSpotsSummaryEmpty => _string("fishingSpotsSummary_empty");

  String get fishingSpotListPageNoBodyOfWater =>
      _string("fishingSpotListPage_noBodyOfWater");

  String get fishingSpotMapAddSpotHelp => _string("fishingSpotMap_addSpotHelp");

  String get editCoordinatesHint => _string("editCoordinatesHint");

  String get customEntityListPageTitle => _string("customEntityListPage_title");

  String get customEntityListPageDelete =>
      _string("customEntityListPage_delete");

  String get customEntityListPageSearchHint =>
      _string("customEntityListPage_searchHint");

  String get customEntityListPageEmptyListTitle =>
      _string("customEntityListPage_emptyListTitle");

  String get customEntityListPageEmptyListDescription =>
      _string("customEntityListPage_emptyListDescription");

  String get saveCustomEntityPageNewTitle =>
      _string("saveCustomEntityPage_newTitle");

  String get saveCustomEntityPageEditTitle =>
      _string("saveCustomEntityPage_editTitle");

  String get saveCustomEntityPageNameExists =>
      _string("saveCustomEntityPage_nameExists");

  String get feedbackPageTitle => _string("feedbackPage_title");

  String get feedbackPageSend => _string("feedbackPage_send");

  String get feedbackPageMessage => _string("feedbackPage_message");

  String get feedbackPageBugType => _string("feedbackPage_bugType");

  String get feedbackPageSuggestionType =>
      _string("feedbackPage_suggestionType");

  String get feedbackPageFeedbackType => _string("feedbackPage_feedbackType");

  String get feedbackPageErrorSending => _string("feedbackPage_errorSending");

  String get feedbackPageConnectionError =>
      _string("feedbackPage_connectionError");

  String get feedbackPageSending => _string("feedbackPage_sending");

  String get importPageMoreTitle => _string("importPage_moreTitle");

  String get importPageTitle => _string("importPage_title");

  String get importPageDescription => _string("importPage_description");

  String get importPageImportingImages => _string("importPage_importingImages");

  String get importPageImportingData => _string("importPage_importingData");

  String get importPageSuccess => _string("importPage_success");

  String get importPageError => _string("importPage_error");

  String get importPageErrorWarningMessage =>
      _string("importPage_errorWarningMessage");

  String get importPageErrorTitle => _string("importPage_errorTitle");

  String get dataImporterChooseFile => _string("dataImporter_chooseFile");

  String get dataImporterStart => _string("dataImporter_start");

  String get migrationPageMoreTitle => _string("migrationPage_moreTitle");

  String get migrationPageTitle => _string("migrationPage_title");

  String get onboardingMigrationPageDescription =>
      _string("onboardingMigrationPage_description");

  String get migrationPageDescription => _string("migrationPage_description");

  String get onboardingMigrationPageError =>
      _string("onboardingMigrationPage_error");

  String get migrationPageError => _string("migrationPage_error");

  String get migrationPageLoading => _string("migrationPage_loading");

  String get migrationPageSuccess => _string("migrationPage_success");

  String get migrationPageNothingToDoDescription =>
      _string("migrationPage_nothingToDoDescription");

  String get migrationPageNothingToDoSuccess =>
      _string("migrationPage_nothingToDoSuccess");

  String get migrationPageFeedbackTitle =>
      _string("migrationPage_feedbackTitle");

  String get anglerNameLabel => _string("angler_nameLabel");

  String get analysisDurationAllDates => _string("analysisDuration_allDates");

  String get analysisDurationToday => _string("analysisDuration_today");

  String get analysisDurationYesterday => _string("analysisDuration_yesterday");

  String get analysisDurationThisWeek => _string("analysisDuration_thisWeek");

  String get analysisDurationThisMonth => _string("analysisDuration_thisMonth");

  String get analysisDurationThisYear => _string("analysisDuration_thisYear");

  String get analysisDurationLastWeek => _string("analysisDuration_lastWeek");

  String get analysisDurationLastMonth => _string("analysisDuration_lastMonth");

  String get analysisDurationLastYear => _string("analysisDuration_lastYear");

  String get analysisDurationLast7Days => _string("analysisDuration_last7Days");

  String get analysisDurationLast14Days =>
      _string("analysisDuration_last14Days");

  String get analysisDurationLast30Days =>
      _string("analysisDuration_last30Days");

  String get analysisDurationLast60Days =>
      _string("analysisDuration_last60Days");

  String get analysisDurationLast12Months =>
      _string("analysisDuration_last12Months");

  String get analysisDurationCustom => _string("analysisDuration_custom");

  String get yearsFormat => _string("yearsFormat");

  String get daysFormat => _string("daysFormat");

  String get hoursFormat => _string("hoursFormat");

  String get minutesFormat => _string("minutesFormat");

  String get secondsFormat => _string("secondsFormat");

  String get dateTimeFormat => _string("dateTimeFormat");

  String get dateRangeFormat => _string("dateRangeFormat");

  String get dateDurationFormat => _string("dateDurationFormat");

  String get onboardingJourneyWelcomeTitle =>
      _string("onboardingJourney_welcomeTitle");

  String get onboardingJourneyStartDescription =>
      _string("onboardingJourney_startDescription");

  String get onboardingJourneyStartButton =>
      _string("onboardingJourney_startButton");

  String get onboardingJourneySkip => _string("onboardingJourney_skip");

  String get onboardingJourneyCatchFieldDescription =>
      _string("onboardingJourney_catchFieldDescription");

  String get onboardingJourneyManageFieldsTitle =>
      _string("onboardingJourney_manageFieldsTitle");

  String get onboardingJourneyManageFieldsDescription =>
      _string("onboardingJourney_manageFieldsDescription");

  String get onboardingJourneyManageFieldsSpecies =>
      _string("onboardingJourney_manageFieldsSpecies");

  String get onboardingJourneyLocationAccessTitle =>
      _string("onboardingJourney_locationAccessTitle");

  String get onboardingJourneyLocationAccessDescription =>
      _string("onboardingJourney_locationAccessDescription");

  String get onboardingJourneyLocationAccessButton =>
      _string("onboardingJourney_locationAccessButton");

  String get onboardingJourneyHowToFeedbackTitle =>
      _string("onboardingJourney_howToFeedbackTitle");

  String get onboardingJourneyHowToFeedbackDescription =>
      _string("onboardingJourney_howToFeedbackDescription");

  String get onboardingJourneyNotNow => _string("onboardingJourney_notNow");

  String get emptyListPlaceholderNoResultsTitle =>
      _string("emptyListPlaceholder_noResultsTitle");

  String get emptyListPlaceholderNoResultsDescription =>
      _string("emptyListPlaceholder_noResultsDescription");

  String get loginPageLoginTitle => _string("loginPage_loginTitle");

  String get loginPageLoginButtonText => _string("loginPage_loginButtonText");

  String get loginPageLoginQuestionText =>
      _string("loginPage_loginQuestionText");

  String get loginPageLoginActionText => _string("loginPage_loginActionText");

  String get loginPageSignUpTitle => _string("loginPage_signUpTitle");

  String get loginPageSignUpButtonText => _string("loginPage_signUpButtonText");

  String get loginPageSignUpQuestionText =>
      _string("loginPage_signUpQuestionText");

  String get loginPageSignUpActionText => _string("loginPage_signUpActionText");

  String get loginPagePasswordResetQuestion =>
      _string("loginPage_passwordResetQuestion");

  String get loginPagePasswordResetAction =>
      _string("loginPage_passwordResetAction");

  String get loginPageErrorUnknown => _string("loginPage_errorUnknown");

  String get loginPageErrorUnknownServer =>
      _string("loginPage_errorUnknownServer");

  String get loginPageErrorNoConnection =>
      _string("loginPage_errorNoConnection");

  String get loginPageErrorInvalidEmail =>
      _string("loginPage_errorInvalidEmail");

  String get loginPageErrorUserDisabled =>
      _string("loginPage_errorUserDisabled");

  String get loginPageErrorUserNotFound =>
      _string("loginPage_errorUserNotFound");

  String get loginPageErrorWrongPassword =>
      _string("loginPage_errorWrongPassword");

  String get loginPageErrorEmailInUse => _string("loginPage_errorEmailInUse");

  String get loginPageResetPasswordMessage =>
      _string("loginPage_resetPasswordMessage");

  String get proPageUpgradeTitle => _string("proPage_upgradeTitle");

  String get proPageProTitle => _string("proPage_proTitle");

  String get proPageBackup => _string("proPage_backup");

  String get proPageCsv => _string("proPage_csv");

  String get proPageAtmosphere => _string("proPage_atmosphere");

  String get proPageSync => _string("proPage_sync");

  String get proPageReports => _string("proPage_reports");

  String get proPageCustomFields => _string("proPage_customFields");

  String get proPageGpsTrails => _string("proPage_gpsTrails");

  String get proPageYearlyTitle => _string("proPage_yearlyTitle");

  String get proPageYearlyTrial => _string("proPage_yearlyTrial");

  String get proPageYearlySubtext => _string("proPage_yearlySubtext");

  String get proPageMonthlyTitle => _string("proPage_monthlyTitle");

  String get proPageMonthlyTrial => _string("proPage_monthlyTrial");

  String get proPageMonthlySubtext => _string("proPage_monthlySubtext");

  String get proPageFetchError => _string("proPage_fetchError");

  String get proPageUpgradeSuccess => _string("proPage_upgradeSuccess");

  String get proPageRestoreQuestion => _string("proPage_restoreQuestion");

  String get proPageRestoreAction => _string("proPage_restoreAction");

  String get proPageRestoreNoneFoundAppStore =>
      _string("proPage_restoreNoneFoundAppStore");

  String get proPageRestoreNoneFoundGooglePlay =>
      _string("proPage_restoreNoneFoundGooglePlay");

  String get proPageRestoreError => _string("proPage_restoreError");

  String get proPageDisclosureApple => _string("proPage_disclosureApple");

  String get proPageDisclosureAndroid => _string("proPage_disclosureAndroid");

  String get periodDawn => _string("period_dawn");

  String get periodMorning => _string("period_morning");

  String get periodMidday => _string("period_midday");

  String get periodAfternoon => _string("period_afternoon");

  String get periodEvening => _string("period_evening");

  String get periodDusk => _string("period_dusk");

  String get periodNight => _string("period_night");

  String get periodPickerAll => _string("period_pickerAll");

  String get seasonWinter => _string("season_winter");

  String get seasonSpring => _string("season_spring");

  String get seasonSummer => _string("season_summer");

  String get seasonAutumn => _string("season_autumn");

  String get seasonPickerAll => _string("season_pickerAll");

  String get measurementSystemImperial => _string("measurementSystem_imperial");

  String get measurementSystemImperialDecimal =>
      _string("measurementSystem_imperialDecimal");

  String get measurementSystemMetric => _string("measurementSystem_metric");

  String get numberBoundaryAny => _string("numberBoundary_any");

  String get numberBoundaryLessThan => _string("numberBoundary_lessThan");

  String get numberBoundaryLessThanOrEqualTo =>
      _string("numberBoundary_lessThanOrEqualTo");

  String get numberBoundaryEqualTo => _string("numberBoundary_equalTo");

  String get numberBoundaryGreaterThan => _string("numberBoundary_greaterThan");

  String get numberBoundaryGreaterThanOrEqualTo =>
      _string("numberBoundary_greaterThanOrEqualTo");

  String get numberBoundaryRange => _string("numberBoundary_range");

  String get numberBoundaryLessThanValue =>
      _string("numberBoundary_lessThanValue");

  String get numberBoundaryLessThanOrEqualToValue =>
      _string("numberBoundary_lessThanOrEqualToValue");

  String get numberBoundaryEqualToValue =>
      _string("numberBoundary_equalToValue");

  String get numberBoundaryGreaterThanValue =>
      _string("numberBoundary_greaterThanValue");

  String get numberBoundaryGreaterThanOrEqualToValue =>
      _string("numberBoundary_greaterThanOrEqualToValue");

  String get numberBoundaryRangeValue => _string("numberBoundary_rangeValue");

  String get unitFeet => _string("unit_feet");

  String get unitInches => _string("unit_inches");

  String get unitPounds => _string("unit_pounds");

  String get unitOunces => _string("unit_ounces");

  String get unitFahrenheit => _string("unit_fahrenheit");

  String get unitMeters => _string("unit_meters");

  String get unitCentimeters => _string("unit_centimeters");

  String get unitKilograms => _string("unit_kilograms");

  String get unitCelsius => _string("unit_celsius");

  String get unitMilesPerHour => _string("unit_milesPerHour");

  String get unitKilometersPerHour => _string("unit_kilometersPerHour");

  String get unitMillibars => _string("unit_millibars");

  String get unitPoundsPerSquareInch => _string("unit_poundsPerSquareInch");

  String get unitPercent => _string("unit_percent");

  String get unitInchOfMercury => _string("unit_inchOfMercury");

  String get unitMiles => _string("unit_miles");

  String get unitKilometers => _string("unit_kilometers");

  String get unitX => _string("unit_x");

  String get unitAught => _string("unit_aught");

  String get unitPoundTest => _string("unit_poundTest");

  String get unitHashtag => _string("unit_hashtag");

  String get unitConvertToValue => _string("unit_convertToValue");

  String get numberFilterInputFrom => _string("numberFilterInput_from");

  String get numberFilterInputTo => _string("numberFilterInput_to");

  String get numberFilterInputValue => _string("numberFilterInput_value");

  String get filterTitleWaterTemperature =>
      _string("filterTitle_waterTemperature");

  String get filterTitleWaterDepth => _string("filterTitle_waterDepth");

  String get filterTitleLength => _string("filterTitle_length");

  String get filterTitleWeight => _string("filterTitle_weight");

  String get filterTitleQuantity => _string("filterTitle_quantity");

  String get filterTitleAirTemperature => _string("filterTitle_airTemperature");

  String get filterTitleAirPressure => _string("filterTitle_airPressure");

  String get filterTitleAirHumidity => _string("filterTitle_airHumidity");

  String get filterTitleAirVisibility => _string("filterTitle_airVisibility");

  String get filterTitleWindSpeed => _string("filterTitle_windSpeed");

  String get filterPageInvalidEndValue => _string("filterPage_invalidEndValue");

  String get filterValueWaterTemperature =>
      _string("filterValue_waterTemperature");

  String get filterValueWaterDepth => _string("filterValue_waterDepth");

  String get filterValueLength => _string("filterValue_length");

  String get filterValueWeight => _string("filterValue_weight");

  String get filterValueQuantity => _string("filterValue_quantity");

  String get filterValueAirTemperature => _string("filterValue_airTemperature");

  String get filterValueAirPressure => _string("filterValue_airPressure");

  String get filterValueAirHumidity => _string("filterValue_airHumidity");

  String get filterValueAirVisibility => _string("filterValue_airVisibility");

  String get filterValueWindSpeed => _string("filterValue_windSpeed");

  String get moonPhaseNew => _string("moonPhase_new");

  String get moonPhaseWaxingCrescent => _string("moonPhase_waxingCrescent");

  String get moonPhaseFirstQuarter => _string("moonPhase_firstQuarter");

  String get moonPhaseWaxingGibbous => _string("moonPhase_waxingGibbous");

  String get moonPhaseFull => _string("moonPhase_full");

  String get moonPhaseWaningGibbous => _string("moonPhase_waningGibbous");

  String get moonPhaseLastQuarter => _string("moonPhase_lastQuarter");

  String get moonPhaseWaningCrescent => _string("moonPhase_waningCrescent");

  String get moonPhaseChip => _string("moonPhase_chip");

  String get atmosphereInputTemperature =>
      _string("atmosphereInput_temperature");

  String get atmosphereInputAirTemperature =>
      _string("atmosphereInput_airTemperature");

  String get atmosphereInputSkyConditions =>
      _string("atmosphereInput_skyConditions");

  String get atmosphereInputNoSkyConditions =>
      _string("atmosphereInput_noSkyConditions");

  String get atmosphereInputWindSpeed => _string("atmosphereInput_windSpeed");

  String get atmosphereInputWind => _string("atmosphereInput_wind");

  String get atmosphereInputWindDirection =>
      _string("atmosphereInput_windDirection");

  String get atmosphereInputPressure => _string("atmosphereInput_pressure");

  String get atmosphereInputAtmosphericPressure =>
      _string("atmosphereInput_atmosphericPressure");

  String get atmosphereInputHumidity => _string("atmosphereInput_humidity");

  String get atmosphereInputAirHumidity =>
      _string("atmosphereInput_airHumidity");

  String get atmosphereInputVisibility => _string("atmosphereInput_visibility");

  String get atmosphereInputAirVisibility =>
      _string("atmosphereInput_airVisibility");

  String get atmosphereInputMoon => _string("atmosphereInput_moon");

  String get atmosphereInputMoonPhase => _string("atmosphereInput_moonPhase");

  String get atmosphereInputSunrise => _string("atmosphereInput_sunrise");

  String get atmosphereInputTimeOfSunrise =>
      _string("atmosphereInput_timeOfSunrise");

  String get atmosphereInputSunset => _string("atmosphereInput_sunset");

  String get atmosphereInputTimeOfSunset =>
      _string("atmosphereInput_timeOfSunset");

  String get directionNorth => _string("direction_north");

  String get directionNorthEast => _string("direction_northEast");

  String get directionEast => _string("direction_east");

  String get directionSouthEast => _string("direction_southEast");

  String get directionSouth => _string("direction_south");

  String get directionSouthWest => _string("direction_southWest");

  String get directionWest => _string("direction_west");

  String get directionNorthWest => _string("direction_northWest");

  String get directionWindChip => _string("direction_windChip");

  String get skyConditionSnow => _string("skyCondition_snow");

  String get skyConditionDrizzle => _string("skyCondition_drizzle");

  String get skyConditionDust => _string("skyCondition_dust");

  String get skyConditionFog => _string("skyCondition_fog");

  String get skyConditionRain => _string("skyCondition_rain");

  String get skyConditionTornado => _string("skyCondition_tornado");

  String get skyConditionHail => _string("skyCondition_hail");

  String get skyConditionIce => _string("skyCondition_ice");

  String get skyConditionStorm => _string("skyCondition_storm");

  String get skyConditionMist => _string("skyCondition_mist");

  String get skyConditionSmoke => _string("skyCondition_smoke");

  String get skyConditionOvercast => _string("skyCondition_overcast");

  String get skyConditionCloudy => _string("skyCondition_cloudy");

  String get skyConditionClear => _string("skyCondition_clear");

  String get skyConditionSunny => _string("skyCondition_sunny");

  String get pickerTitleBait => _string("pickerTitle_bait");

  String get pickerTitleBaits => _string("pickerTitle_baits");

  String get pickerTitleBaitCategory => _string("pickerTitle_baitCategory");

  String get pickerTitleAngler => _string("pickerTitle_angler");

  String get pickerTitleAnglers => _string("pickerTitle_anglers");

  String get pickerTitleFishingMethods => _string("pickerTitle_fishingMethods");

  String get pickerTitleWaterClarity => _string("pickerTitle_waterClarity");

  String get pickerTitleWaterClarities => _string("pickerTitle_waterClarities");

  String get pickerTitleDateRange => _string("pickerTitle_dateRange");

  String get pickerTitleFields => _string("pickerTitle_fields");

  String get pickerTitleReport => _string("pickerTitle_report");

  String get pickerTitleSpecies => _string("pickerTitle_species");

  String get pickerTitleFishingSpot => _string("pickerTitle_fishingSpot");

  String get pickerTitleFishingSpots => _string("pickerTitle_fishingSpots");

  String get pickerTitleTimeOfDay => _string("pickerTitle_timeOfDay");

  String get pickerTitleTimesOfDay => _string("pickerTitle_timesOfDay");

  String get pickerTitleSeason => _string("pickerTitle_season");

  String get pickerTitleSeasons => _string("pickerTitle_seasons");

  String get pickerTitleMoonPhase => _string("pickerTitle_moonPhase");

  String get pickerTitleMoonPhases => _string("pickerTitle_moonPhases");

  String get pickerTitleSkyCondition => _string("pickerTitle_skyCondition");

  String get pickerTitleSkyConditions => _string("pickerTitle_skyConditions");

  String get pickerTitleWindDirection => _string("pickerTitle_windDirection");

  String get pickerTitleWindDirections => _string("pickerTitle_windDirections");

  String get pickerTitleTide => _string("pickerTitle_tide");

  String get pickerTitleTides => _string("pickerTitle_tides");

  String get pickerTitleBodyOfWater => _string("pickerTitle_bodyOfWater");

  String get pickerTitleBodiesOfWater => _string("pickerTitle_bodiesOfWater");

  String get pickerTitleCatches => _string("pickerTitle_catches");

  String get pickerTitleTimeZone => _string("pickerTitle_timeZone");

  String get pickerTitleGpsTrails => _string("pickerTitle_gpsTrails");

  String get pickerTitleGear => _string("pickerTitle_gear");

  String get pickerTitleRodAction => _string("pickerTitle_rodAction");

  String get pickerTitleRodPower => _string("pickerTitle_rodPower");

  String get keywordsTemperatureMetric => _string("keywords_temperatureMetric");

  String get keywordsTemperatureImperial =>
      _string("keywords_temperatureImperial");

  String get keywordsSpeedMetric => _string("keywords_speedMetric");

  String get keywordsSpeedImperial => _string("keywords_speedImperial");

  String get keywordsAirPressureMetric => _string("keywords_airPressureMetric");

  String get keywordsAirPressureImperial =>
      _string("keywords_airPressureImperial");

  String get keywordsAirHumidity => _string("keywords_airHumidity");

  String get keywordsAirVisibilityMetric =>
      _string("keywords_airVisibilityMetric");

  String get keywordsAirVisibilityImperial =>
      _string("keywords_airVisibilityImperial");

  String get keywordsSunrise => _string("keywords_sunrise");

  String get keywordsSunset => _string("keywords_sunset");

  String get keywordsCatchAndRelease => _string("keywords_catchAndRelease");

  String get keywordsFavorite => _string("keywords_favorite");

  String get keywordsDepthMetric => _string("keywords_depthMetric");

  String get keywordsDepthImperial => _string("keywords_depthImperial");

  String get keywordsLengthMetric => _string("keywords_lengthMetric");

  String get keywordsLengthImperial => _string("keywords_lengthImperial");

  String get keywordsWeightMetric => _string("keywords_weightMetric");

  String get keywordsWeightImperial => _string("keywords_weightImperial");

  String get keywordsPercent => _string("keywords_percent");

  String get keywordsInchOfMercury => _string("keywords_inchOfMercury");

  String get keywordsX => _string("keywords_x");

  String get keywordsAught => _string("keywords_aught");

  String get keywordsPoundTest => _string("keywords_poundTest");

  String get keywordsHashtag => _string("keywords_hashtag");

  String get keywordsNorth => _string("keywords_north");

  String get keywordsNorthEast => _string("keywords_northEast");

  String get keywordsEast => _string("keywords_east");

  String get keywordsSouthEast => _string("keywords_southEast");

  String get keywordsSouth => _string("keywords_south");

  String get keywordsSouthWest => _string("keywords_southWest");

  String get keywordsWest => _string("keywords_west");

  String get keywordsNorthWest => _string("keywords_northWest");

  String get keywordsWindDirection => _string("keywords_windDirection");

  String get keywordsMoon => _string("keywords_moon");

  String get tideInputTitle => _string("tideInput_title");

  String get tideInputLowTimeValue => _string("tideInput_lowTimeValue");

  String get tideInputHighTimeValue => _string("tideInput_highTimeValue");

  String get tideInputFirstLowTimeLabel =>
      _string("tideInput_firstLowTimeLabel");

  String get tideInputFirstHighTimeLabel =>
      _string("tideInput_firstHighTimeLabel");

  String get tideInputSecondLowTimeLabel =>
      _string("tideInput_secondLowTimeLabel");

  String get tideInputSecondHighTimeLabel =>
      _string("tideInput_secondHighTimeLabel");

  String get tideTypeLow => _string("tideType_low");

  String get tideTypeOutgoing => _string("tideType_outgoing");

  String get tideTypeHigh => _string("tideType_high");

  String get tideTypeSlack => _string("tideType_slack");

  String get tideTypeIncoming => _string("tideType_incoming");

  String get tideLow => _string("tide_low");

  String get tideOutgoing => _string("tide_outgoing");

  String get tideHigh => _string("tide_high");

  String get tideSlack => _string("tide_slack");

  String get tideIncoming => _string("tide_incoming");

  String get tideTimeAndHeight => _string("tide_timeAndHeight");

  String get tideInputFetch => _string("tideInput_fetch");

  String get tideInputAutoFetch => _string("tideInput_autoFetch");

  String get saveBaitVariantPageTitle => _string("saveBaitVariantPage_title");

  String get saveBaitVariantPageEditTitle =>
      _string("saveBaitVariantPage_editTitle");

  String get saveBaitVariantPageModelNumber =>
      _string("saveBaitVariantPage_modelNumber");

  String get saveBaitVariantPageSize => _string("saveBaitVariantPage_size");

  String get saveBaitVariantPageMinDiveDepth =>
      _string("saveBaitVariantPage_minDiveDepth");

  String get saveBaitVariantPageMaxDiveDepth =>
      _string("saveBaitVariantPage_maxDiveDepth");

  String get saveBaitVariantPageDescription =>
      _string("saveBaitVariantPage_description");

  String get baitVariantPageVariantLabel =>
      _string("baitVariantPage_variantLabel");

  String get baitVariantPageModel => _string("baitVariantPage_model");

  String get baitVariantPageSize => _string("baitVariantPage_size");

  String get baitVariantPageDiveDepth => _string("baitVariantPage_diveDepth");

  String get baitTypeArtificial => _string("baitType_artificial");

  String get baitTypeReal => _string("baitType_real");

  String get baitTypeLive => _string("baitType_live");

  String get bodyOfWaterListPageDeleteMessage =>
      _string("bodyOfWaterListPage_deleteMessage");

  String get bodyOfWaterListPageDeleteMessageSingular =>
      _string("bodyOfWaterListPage_deleteMessageSingular");

  String get bodyOfWaterListPageTitle => _string("bodyOfWaterListPage_title");

  String get bodyOfWaterListPageSearchHint =>
      _string("bodyOfWaterListPage_searchHint");

  String get bodyOfWaterListPageEmptyListTitle =>
      _string("bodyOfWaterListPage_emptyListTitle");

  String get bodyOfWaterListPageEmptyListDescription =>
      _string("bodyOfWaterListPage_emptyListDescription");

  String get bodiesOfWaterSummaryEmpty => _string("bodiesOfWaterSummary_empty");

  String get saveBodyOfWaterPageNewTitle =>
      _string("saveBodyOfWaterPage_newTitle");

  String get saveBodyOfWaterPageEditTitle =>
      _string("saveBodyOfWaterPage_editTitle");

  String get saveBodyOfWaterPageExistsMessage =>
      _string("saveBodyOfWaterPage_existsMessage");

  String get mapAttributionTitleApple => _string("mapAttribution_titleApple");

  String get mapAttributionTitleAndroid =>
      _string("mapAttribution_titleAndroid");

  String get mapAttributionMapbox => _string("mapAttribution_mapbox");

  String get mapAttributionOpenStreetMap =>
      _string("mapAttribution_openStreetMap");

  String get mapAttributionImproveThisMap =>
      _string("mapAttributionImproveThisMap");

  String get mapAttributionMaxar => _string("mapAttribution_maxar");

  String get mapAttributionTelemetryTitle =>
      _string("mapAttribution_telemetryTitle");

  String get mapAttributionTelemetryDescription =>
      _string("mapAttribution_telemetryDescription");

  String get welcomeTitle => _string("welcome_title");

  String get welcomeChanges => _string("welcome_changes");

  String get welcomeChangelogLink1 => _string("welcome_changelog_link1");

  String get welcomeChangelogLink2 => _string("welcome_changelog_link2");

  String get welcomeNext => _string("welcome_next");

  String get emailVerificationDesc1 => _string("emailVerification_desc1");

  String get emailVerificationDesc2 => _string("emailVerification_desc2");

  String get emailVerificationSendAgain =>
      _string("emailVerification_sendAgain");

  String get emailVerificationSignOut => _string("emailVerification_signOut");

  String get emailVerificationError => _string("emailVerification_error");

  String get emailVerificationSent => _string("emailVerification_sent");

  String get entityNameAnglers => _string("entityName_anglers");

  String get entityNameAngler => _string("entityName_angler");

  String get entityNameBaitCategories => _string("entityName_baitCategories");

  String get entityNameBaitCategory => _string("entityName_baitCategory");

  String get entityNameBaits => _string("entityName_baits");

  String get entityNameBait => _string("entityName_bait");

  String get entityNameBodiesOfWater => _string("entityName_bodiesOfWater");

  String get entityNameBodyOfWater => _string("entityName_bodyOfWater");

  String get entityNameCatch => _string("entityName_catch");

  String get entityNameCatches => _string("entityName_catches");

  String get entityNameCustomFields => _string("entityName_customFields");

  String get entityNameCustomField => _string("entityName_customField");

  String get entityNameFishingMethods => _string("entityName_fishingMethods");

  String get entityNameFishingMethod => _string("entityName_fishingMethod");

  String get entityNameGear => _string("entityName_gear");

  String get entityNameGpsTrails => _string("entityName_gpsTrails");

  String get entityNameGpsTrail => _string("entityName_gpsTrail");

  String get entityNameSpecies => _string("entityName_species");

  String get entityNameTrip => _string("entityName_trip");

  String get entityNameTrips => _string("entityName_trips");

  String get entityNameWaterClarities => _string("entityName_waterClarities");

  String get entityNameWaterClarity => _string("entityName_waterClarity");

  String get tripSummaryTitle => _string("tripSummary_title");

  String get tripSummaryTotalTripTime => _string("tripSummary_totalTripTime");

  String get tripSummaryLongestTrip => _string("tripSummary_longestTrip");

  String get tripSummarySinceLastTrip => _string("tripSummary_sinceLastTrip");

  String get tripSummaryAverageTripTime =>
      _string("tripSummary_averageTripTime");

  String get tripSummaryAverageTimeBetweenTrips =>
      _string("tripSummary_averageTimeBetweenTrips");

  String get tripSummaryAverageTimeBetweenCatches =>
      _string("tripSummary_averageTimeBetweenCatches");

  String get tripSummaryCatchesPerTrip => _string("tripSummary_catchesPerTrip");

  String get tripSummaryCatchesPerHour => _string("tripSummary_catchesPerHour");

  String get tripSummaryWeightPerTrip => _string("tripSummary_weightPerTrip");

  String get tripSummaryBestWeight => _string("tripSummary_bestWeight");

  String get tripSummaryLengthPerTrip => _string("tripSummary_lengthPerTrip");

  String get tripSummaryBestLength => _string("tripSummary_bestLength");

  String get backupPageTitle => _string("backupPage_title");

  String get backupPageDescription => _string("backupPage_description");

  String get backupPageAction => _string("backupPage_action");

  String get backupPageErrorTitle => _string("backupPage_errorTitle");

  String get backupPageAutoTitle => _string("backupPage_autoTitle");

  String get backupPageLastBackupLabel => _string("backupPage_lastBackupLabel");

  String get backupPageLastBackupNever => _string("backupPage_lastBackupNever");

  String get restorePageTitle => _string("restorePage_title");

  String get restorePageDescription => _string("restorePage_description");

  String get restorePageAction => _string("restorePage_action");

  String get restorePageErrorTitle => _string("restorePage_errorTitle");

  String get backupRestoreAuthError => _string("backupRestore_authError");

  String get backupRestoreCreateFolderError =>
      _string("backupRestore_createFolderError");

  String get backupRestoreFolderNotFound =>
      _string("backupRestore_folderNotFound");

  String get backupRestoreApiRequestError =>
      _string("backupRestore_apiRequestError");

  String get backupRestoreDatabaseNotFound =>
      _string("backupRestore_databaseNotFound");

  String get backupRestoreAccessDenied => _string("backupRestore_accessDenied");

  String get backupRestoreAuthenticating =>
      _string("backupRestore_authenticating");

  String get backupRestoreFetchingFiles =>
      _string("backupRestore_fetchingFiles");

  String get backupRestoreCreatingFolder =>
      _string("backupRestore_creatingFolder");

  String get backupRestoreBackingUpDatabase =>
      _string("backupRestore_backingUpDatabase");

  String get backupRestoreBackingUpImages =>
      _string("backupRestore_backingUpImages");

  String get backupRestoreDownloadingDatabase =>
      _string("backupRestore_downloadingDatabase");

  String get backupRestoreDownloadingImages =>
      _string("backupRestore_downloadingImages");

  String get backupRestoreReloadingData =>
      _string("backupRestore_reloadingData");

  String get backupRestoreSuccess => _string("backupRestore_success");

  String get cloudAuthSignOut => _string("cloudAuth_signOut");

  String get cloudAuthSignedInAs => _string("cloudAuth_signedInAs");

  String get cloudAuthSignInWithGoogle => _string("cloudAuth_signInWithGoogle");

  String get cloudAuthDescription => _string("cloudAuth_description");

  String get cloudAuthError => _string("cloudAuth_error");

  String get cloudAuthNetworkError => _string("cloudAuth_networkError");

  String get asyncFeedbackSendReport => _string("asyncFeedback_sendReport");

  String get addAnythingTitle => _string("addAnything_title");

  String get proBlurUpgradeButton => _string("proBlur_upgradeButton");

  String get aboutPageVersion => _string("aboutPage_version");

  String get aboutPageEula => _string("aboutPage_eula");

  String get aboutPagePrivacy => _string("aboutPage_privacy");

  String get aboutPageWorldTides => _string("aboutPage_worldTides");

  String get aboutPageWorldTidePrivacy => _string("aboutPage_worldTidePrivacy");

  String get fishingSpotDetailsAddDetails =>
      _string("fishingSpotDetails_addDetails");

  String get timeZoneInputLabel => _string("timeZoneInput_label");

  String get timeZoneInputDescription => _string("timeZoneInput_description");

  String get timeZoneInputSearchHint => _string("timeZoneInput_searchHint");

  String get pollsPageTitle => _string("pollsPage_title");

  String get pollsPageDescription => _string("pollsPage_description");

  String get pollsPageNoPollsTitle => _string("pollsPage_noPollsTitle");

  String get pollsPageNoPollsDescription =>
      _string("pollsPage_noPollsDescription");

  String get pollsPageSendFeedback => _string("pollsPage_sendFeedback");

  String get pollsPageNextFreeFeature => _string("pollsPage_nextFreeFeature");

  String get pollsPageNextProFeature => _string("pollsPage_nextProFeature");

  String get pollsPageThankYouFree => _string("pollsPage_thankYouFree");

  String get pollsPageThankYouPro => _string("pollsPage_thankYouPro");

  String get pollsPageError => _string("pollsPage_error");

  String get pollsPageComingSoonFree => _string("pollsPage_comingSoonFree");

  String get pollsPageComingSoonPro => _string("pollsPage_comingSoonPro");

  String get permissionLocationTitle => _string("permission_locationTitle");

  String get permissionCurrentLocationDescription =>
      _string("permission_currentLocationDescription");

  String get permissionGpsTrailDescription =>
      _string("permission_gpsTrailDescription");

  String get permissionOpenSettings => _string("permission_openSettings");

  String get permissionLocationNotificationDescription =>
      _string("permission_locationNotificationDescription");

  String get calendarPageTitle => _string("calendarPage_title");

  String get calendarPageTripLabel => _string("calendarPage_tripLabel");

  String get gpsTrailListPageTitle => _string("gpsTrailListPage_title");

  String get gpsTrailListPageSearchHint =>
      _string("gpsTrailListPage_searchHint");

  String get gpsTrailListPageEmptyListTitle =>
      _string("gpsTrailListPage_emptyListTitle");

  String get gpsTrailListPageEmptyListDescription =>
      _string("gpsTrailListPage_emptyListDescription");

  String get gpsTrailListPageDeleteMessageSingular =>
      _string("gpsTrailListPage_deleteMessageSingular");

  String get gpsTrailListPageDeleteMessage =>
      _string("gpsTrailListPage_deleteMessage");

  String get gpsTrailListPageNumberOfPoints =>
      _string("gpsTrailListPage_numberOfPoints");

  String get gpsTrailListPageInProgress =>
      _string("gpsTrailListPage_inProgress");

  String get saveGpsTrailPageEditTitle => _string("saveGpsTrailPage_editTitle");

  String get tideFetcherErrorNoLocationFound =>
      _string("tideFetcher_errorNoLocationFound");

  String get csvPageTitle => _string("csvPage_title");

  String get csvPageAction => _string("csvPage_action");

  String get csvPageDescription => _string("csvPage_description");

  String get csvPageImportWarning => _string("csvPage_importWarning");

  String get csvPageSuccess => _string("csvPage_success");

  String get csvPageMustSelect => _string("csvPage_mustSelect");

  String get tripFieldStartDate => _string("tripField_startDate");

  String get tripFieldEndDate => _string("tripField_endDate");

  String get tripFieldStartTime => _string("tripField_startTime");

  String get tripFieldEndTime => _string("tripField_endTime");

  String get tripFieldPhotos => _string("tripField_photos");

  String get gearListPageTitle => _string("gearListPage_title");

  String get gearListPageDeleteMessage => _string("gearListPage_deleteMessage");

  String get gearListPageDeleteMessageSingular =>
      _string("gearListPage_deleteMessageSingular");

  String get gearListPageSearchHint => _string("gearListPage_searchHint");

  String get gearListPageEmptyListTitle =>
      _string("gearListPage_emptyListTitle");

  String get gearListPageEmptyListDescription =>
      _string("gearListPage_emptyListDescription");

  String get gearSummaryEmpty => _string("gearSummary_empty");

  String get gearActionXFast => _string("gearAction_xFast");

  String get gearActionFast => _string("gearAction_fast");

  String get gearActionModerateFast => _string("gearAction_moderateFast");

  String get gearActionModerate => _string("gearAction_moderate");

  String get gearActionSlow => _string("gearAction_slow");

  String get gearPowerUltralight => _string("gearPower_ultralight");

  String get gearPowerLight => _string("gearPower_light");

  String get gearPowerMediumLight => _string("gearPower_mediumLight");

  String get gearPowerMedium => _string("gearPower_medium");

  String get gearPowerMediumHeavy => _string("gearPower_mediumHeavy");

  String get gearPowerHeavy => _string("gearPower_heavy");

  String get gearPowerXHeavy => _string("gearPower_xHeavy");

  String get gearPowerXxHeavy => _string("gearPower_xxHeavy");

  String get gearPowerXxxHeavy => _string("gearPower_xxxHeavy");

  String get gearFieldImage => _string("gearField_image");

  String get gearFieldRodMakeModel => _string("gearField_rodMakeModel");

  String get gearFieldRodSerialNumber => _string("gearField_rodSerialNumber");

  String get gearFieldRodLength => _string("gearField_rodLength");

  String get gearFieldRodAction => _string("gearField_rodAction");

  String get gearFieldRodPower => _string("gearField_rodPower");

  String get gearFieldReelMakeModel => _string("gearField_reelMakeModel");

  String get gearFieldReelSerialNumber => _string("gearField_reelSerialNumber");

  String get gearPageSize => _string("gearPage_size");

  String get gearPageLeader => _string("gearPage_leader");

  String get gearPageTippet => _string("gearPage_tippet");

  String get gearFieldReelSize => _string("gearField_reelSize");

  String get gearFieldLineMakeModel => _string("gearField_lineMakeModel");

  String get gearFieldLineRating => _string("gearField_lineRating");

  String get gearFieldLineColor => _string("gearField_lineColor");

  String get gearFieldLeaderLength => _string("gearField_leaderLength");

  String get gearFieldLeaderRating => _string("gearField_leaderRating");

  String get gearFieldTippetLength => _string("gearField_tippetLength");

  String get gearFieldTippetRating => _string("gearField_tippetRating");

  String get gearFieldHookMakeModel => _string("gearField_hookMakeModel");

  String get gearFieldHookSize => _string("gearField_hookSize");

  String get saveGearPageEditTitle => _string("saveGearPage_editTitle");

  String get saveGearPageNewTitle => _string("saveGearPage_newTitle");

  String get saveGearPageNameExists => _string("saveGearPage_nameExists");

  String get gearPageSerialNumber => _string("gearPage_serialNumber");

  String get changeLogPageTitle => _string("changeLogPage_title");

  String get changeLogPagePreviousVersion =>
      _string("changeLogPage_previousVersion");

  String get changeLog_2022_1 => _string("changeLog_2.0.22_1");

  String get changeLog_2022_2 => _string("changeLog_2.0.22_2");

  String get changeLog_2022_3 => _string("changeLog_2.0.22_3");

  String get changeLog_2022_4 => _string("changeLog_2.0.22_4");

  String get changeLog_2022_5 => _string("changeLog_2.0.22_5");

  String get changeLog_2022_6 => _string("changeLog_2.0.22_6");

  String get changeLog_210_1 => _string("changeLog_2.1.0_1");

  String get changeLog_210_2 => _string("changeLog_2.1.0_2");

  String get changeLog_210_3 => _string("changeLog_2.1.0_3");

  String get changeLog_210_4 => _string("changeLog_2.1.0_4");

  String get changeLog_212_1 => _string("changeLog_2.1.2_1");

  String get changeLog_212_2 => _string("changeLog_2.1.2_2");

  String get changeLog_212_3 => _string("changeLog_2.1.2_3");

  String get changeLog_212_4 => _string("changeLog_2.1.2_4");

  String get changeLog_213_1 => _string("changeLog_2.1.3_1");

  String get changeLog_213_2 => _string("changeLog_2.1.3_2");

  String get changeLog_213_3 => _string("changeLog_2.1.3_3");

  String get changeLog_213_4 => _string("changeLog_2.1.3_4");

  String get changeLog_215_1 => _string("changeLog_2.1.5_1");

  String get changeLog_216_1 => _string("changeLog_2.1.6_1");

  String get changeLog_216_2 => _string("changeLog_2.1.6_2");

  String get changeLog_216_3 => _string("changeLog_2.1.6_3");

  String get changeLog_216_4 => _string("changeLog_2.1.6_4");

  String get changeLog_216_5 => _string("changeLog_2.1.6_5");

  String get changeLog_220_1 => _string("changeLog_2.2.0_1");

  String get changeLog_220_2 => _string("changeLog_2.2.0_2");

  String get changeLog_220_3 => _string("changeLog_2.2.0_3");

  String get changeLog_230_1 => _string("changeLog_2.3.0_1");

  String get changeLog_230_2 => _string("changeLog_2.3.0_2");

  String get changeLog_230_3 => _string("changeLog_2.3.0_3");

  String get changeLog_230_4 => _string("changeLog_2.3.0_4");

  String get changeLog_230_5 => _string("changeLog_2.3.0_5");

  String get changeLog_232_1 => _string("changeLog_2.3.2_1");

  String get changeLog_233_1 => _string("changeLog_2.3.3_1");

  String get changeLog_233_2 => _string("changeLog_2.3.3_2");

  String get changeLog_234_1 => _string("changeLog_2.3.4_1");

  String get changeLog_234_2 => _string("changeLog_2.3.4_2");

  String get changeLog_234_3 => _string("changeLog_2.3.4_3");

  String get changeLog_234_4 => _string("changeLog_2.3.4_4");

  String get changeLog_240_1 => _string("changeLog_2.4.0_1");

  String get changeLog_240_2 => _string("changeLog_2.4.0_2");

  String get changeLog_240_3 => _string("changeLog_2.4.0_3");

  String get changeLog_240_4 => _string("changeLog_2.4.0_4");

  String get changeLog_240_5 => _string("changeLog_2.4.0_5");

  String get changeLog_240_6 => _string("changeLog_2.4.0_6");

  String get changeLog_241_1 => _string("changeLog_2.4.1_1");

  String get changeLog_241_2 => _string("changeLog_2.4.1_2");

  String get changeLog_241_3 => _string("changeLog_2.4.1_3");

  String get changeLog_241_4 => _string("changeLog_2.4.1_4");

  String get changeLog_241_5 => _string("changeLog_2.4.1_5");

  String get changeLog_243_1 => _string("changeLog_2.4.3_1");

  String get changeLog_250_1 => _string("changeLog_2.5.0_1");

  String get changeLog_250_2 => _string("changeLog_2.5.0_2");

  String get changeLog_250_3 => _string("changeLog_2.5.0_3");

  String get changeLog_250_4 => _string("changeLog_2.5.0_4");

  String get changeLog_250_5 => _string("changeLog_2.5.0_5");

  String get changeLog_251_1 => _string("changeLog_2.5.1_1");

  String get changeLog_252_1 => _string("changeLog_2.5.2_1");

  String get changeLog_252_2 => _string("changeLog_2.5.2_2");

  String get changeLog_252_3 => _string("changeLog_2.5.2_3");

  String get changeLog_252_4 => _string("changeLog_2.5.2_4");

  String get changeLog_260_1 => _string("changeLog_2.6.0_1");

  String get changeLog_260_2 => _string("changeLog_2.6.0_2");

  String get changeLog_260_3 => _string("changeLog_2.6.0_3");

  String get changeLog_260_4 => _string("changeLog_2.6.0_4");

  String get changeLog_260_5 => _string("changeLog_2.6.0_5");
}

class StringsDelegate extends LocalizationsDelegate<Strings> {
  @override
  bool isSupported(Locale locale) =>
      Strings._supportedLanguages.contains(locale.languageCode);

  @override
  Future<Strings> load(Locale locale) =>
      SynchronousFuture<Strings>(Strings(locale));

  @override
  bool shouldReload(LocalizationsDelegate<Strings> old) => false;
}
