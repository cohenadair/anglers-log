import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../i18n/english_strings.dart';

class Strings {
  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> get _values => {
        "en": englishStrings,
      };

  static Strings of(BuildContext context) =>
      Localizations.of<Strings>(context, Strings);

  final Locale _locale;

  Strings(this._locale);

  /// Should be used sparingly, and only to avoid passing a Context object
  /// around unnecessarily.
  String fromId(String id) => _string(id);

  /// If a specific string for a language and country exists, use it, otherwise
  /// use the default.
  String _string(String key) {
    var value = _values[_locale.languageCode][_locale.countryCode][key];
    if (value == null) {
      return _values[_locale.languageCode]["default"][key];
    }
    return value;
  }

  String get appName => _string("appName");
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
  String get latLng => _string("latLng");
  String get latLngNoLabels => _string("latLng_noLabels");
  String get add => _string("add");
  String get more => _string("more");
  String get customFields => _string("customFields");
  String get na => _string("na");
  String get finish => _string("finish");
  String get by => _string("by");
  String get devName => _string("devName");

  String get fieldTypeNumber => _string("fieldType_number");
  String get fieldTypeBoolean => _string("fieldType_boolean");
  String get fieldTypeText => _string("fieldType_text");

  String get inputRequiredMessage => _string("input_requiredMessage");
  String get inputNameLabel => _string("input_nameLabel");
  String get inputGenericRequired => _string("input_genericRequired");
  String get inputDescriptionLabel => _string("input_descriptionLabel");
  String get inputInvalidNumber => _string("input_invalidNumber");
  String get inputPhotoLabel => _string("input_photoLabel");
  String get inputPhotosLabel => _string("input_photosLabel");
  String get inputNotSelected => _string("input_notSelected");
  String get inputEmailLabel => _string("input_emailLabel");
  String get inputInvalidEmail => _string("input_invalidEmail");
  String get inputPasswordLabel => _string("input_passwordLabel");
  String get inputPasswordInvalidLength =>
      _string("input_passwordInvalidLength");

  String get addAnythingPageCatch => _string("addAnythingPage_catch");
  String get addAnythingPageTrip => _string("addAnythingPage_trip");

  String get tripListPageMenuLabel => _string("tripListPage_menuLabel");
  String get tripListPageTitle => _string("tripListPage_title");

  String get catchListPageMenuLabel => _string("catchListPage_menuLabel");
  String get catchListPageTitle => _string("catchListPage_title");
  String get catchListPageSearchHint => _string("catchListPage_searchHint");
  String get catchListPageEmptyListTitle =>
      _string("catchListPage_emptyListTitle");
  String get catchListPageEmptyListDescription =>
      _string("catchListPage_emptyListDescription");

  String get catchPageDeleteMessage => _string("catchPage_deleteMessage");

  String get saveCatchPageNewTitle => _string("saveCatchPage_newTitle");
  String get saveCatchPageEditTitle => _string("saveCatchPage_editTitle");

  String get catchFieldDateTime => _string("catchField_dateTime");
  String get catchFieldDate => _string("catchField_date");
  String get catchFieldTime => _string("catchField_time");
  String get catchFieldSpecies => _string("catchField_species");
  String get catchFieldImages => _string("catchField_images");
  String get catchFieldFishingSpot => _string("catchField_fishingSpot");
  String get catchFieldFishingSpotDescription =>
      _string("catchField_fishingSpotDescription");
  String get catchFieldBaitLabel => _string("catchField_bait");

  String get saveCustomReportPageNewTitle =>
      _string("saveCustomReportPage_newTitle");
  String get saveCustomReportPageEditTitle =>
      _string("saveCustomReportPage_editTitle");
  String get saveCustomReportPageNameExists =>
      _string("saveCustomReportPage_nameExists");
  String get saveCustomReportTypeTitle =>
      _string("saveCustomReportPage_typeTitle");
  String get saveCustomReportPageComparison =>
      _string("saveCustomReportPage_comparison");
  String get saveCustomReportPageSummary =>
      _string("saveCustomReportPage_summary");
  String get saveCustomReportPageStartDateRangeLabel =>
      _string("saveCustomReportPage_startDateRangeLabel");
  String get saveCustomReportPageEndDateRangeLabel =>
      _string("saveCustomReportPage_endDateRangeLabel");
  String get saveCustomReportPageSpecies =>
      _string("saveCustomReportPage_species");
  String get saveCustomReportPageAllSpecies =>
      _string("saveCustomReportPage_allSpecies");
  String get saveCustomReportPageAllBaits =>
      _string("saveCustomReportPage_allBaits");
  String get saveCustomReportPageAllFishingSpots =>
      _string("saveCustomReportPage_allFishingSpots");

  String get photosPageMenuLabel => _string("photosPage_menuLabel");
  String get photosPageTitle => _string("photosPage_title");
  String get photosPageEmptyTitle => _string("photosPage_emptyTitle");
  String get photosPageEmptyDescription =>
      _string("photosPage_emptyDescription");

  String get baitListPageMenuLabel => _string("baitListPage_menuLabel");
  String get baitListPageTitle => _string("baitListPage_title");
  String get baitListPagePickerTitle => _string("baitListPage_pickerTitle");
  String get baitListPagePickerTitleMulti =>
      _string("baitListPage_pickerTitleMulti");
  String get baitListPageOtherCategory => _string("baitListPage_otherCategory");
  String get baitListPageSearchHint => _string("baitListPage_searchHint");
  String get baitListPageDeleteMessage => _string("baitListPage_deleteMessage");
  String get baitListPageDeleteMessageSingular =>
      _string("baitListPage_deleteMessageSingular");
  String get baitListPageEmptyListTitle =>
      _string("baitListPage_emptyListTitle");
  String get baitListPageEmptyListDescription =>
      _string("baitListPage_emptyListDescription");

  String get reportListPagePickerTitle => _string("reportListPage_pickerTitle");
  String get reportListPageConfirmDelete =>
      _string("reportListPage_confirmDelete");
  String get reportListPageCustomReportTitle =>
      _string("reportListPage_customReportTitle");
  String get reportListPageCustomReportAddNote =>
      _string("reportListPage_customReportAddNote");

  String get saveBaitPageNewTitle => _string("saveBaitPage_newTitle");
  String get saveBaitPageEditTitle => _string("saveBaitPage_editTitle");
  String get saveBaitPageCategoryLabel => _string("saveBaitPage_categoryLabel");
  String get saveBaitPageBaitExists => _string("saveBaitPage_baitExists");

  String get saveBaitCategoryPageNewTitle =>
      _string("saveBaitCategoryPage_newTitle");
  String get saveBaitCategoryPageEditTitle =>
      _string("saveBaitCategoryPage_editTitle");
  String get saveBaitCategoryPageExistsMessage =>
      _string("saveBaitCategoryPage_existsMessage");

  String get baitCategoryListPageMenuTitle =>
      _string("baitCategoryListPage_menuTitle");
  String get baitCategoryListPageTitle => _string("baitCategoryListPage_title");
  String get baitCategoryListPagePickerTitle =>
      _string("baitCategoryListPage_pickerTitle");
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

  String get statsPageMenuTitle => _string("statsPage_menuTitle");
  String get statsPageTitle => _string("statsPage_title");
  String get statsPageReportOverview => _string("statsPage_reportOverview");
  String get statsPageNewReport => _string("statsPage_newReport");

  String get reportViewNoCatches => _string("reportView_noCatches");
  String get reportViewNoCatchesDescription =>
      _string("reportView_noCatchesDescription");
  String get reportViewNoCatchesCustomReportDescription =>
      _string("reportView_noCatchesCustomReportDescription");

  String get reportSummaryViewCatches => _string("reportSummary_viewCatches");
  String get reportSummaryCatchTitle => _string("reportSummary_catchTitle");
  String get reportSummaryPerSpecies => _string("reportSummary_perSpecies");
  String get reportSummaryPerFishingSpot =>
      _string("reportSummary_perFishingSpot");
  String get reportSummaryPerBait => _string("reportSummary_perBait");
  String get reportSummarySinceLastCatch =>
      _string("reportSummary_sinceLastCatch");
  String get reportSummaryNumberOfCatches =>
      _string("reportSummary_numberOfCatches");
  String get reportSummaryFilters => _string("reportSummary_filters");
  String get reportSummaryViewSpecies => _string("reportSummary_viewSpecies");
  String get reportSummaryCatchesPerSpeciesDescription =>
      _string("reportSummary_catchesPerSpeciesDescription");
  String get reportSummaryViewFishingSpots =>
      _string("reportSummary_viewFishingSpots");
  String get reportSummaryCatchesPerFishingSpotDescription =>
      _string("reportSummary_catchesPerFishingSpotDescription");
  String get reportSummaryViewBaits => _string("reportSummary_viewBaits");
  String get reportSummaryCatchesPerBaitDescription =>
      _string("reportSummary_catchesPerBaitDescription");
  String get reportSummarySpeciesTitle => _string("reportSummary_speciesTitle");
  String get reportSummaryBaitsPerSpeciesDescription =>
      _string("reportSummary_baitsPerSpeciesDescription");
  String get reportSummaryFishingSpotsPerSpeciesDescription =>
      _string("reportSummary_fishingSpotsPerSpeciesDescription");

  String get dateRangePickerPageTitle => _string("dateRangePickerPage_title");

  String get morePageTitle => _string("morePage_title");
  String get morePageRateApp => _string("morePage_rateApp");
  String get morePagePro => _string("morePage_pro");

  String get settingsPageTitle => _string("settingsPage_title");
  String get settingsPageLogout => _string("settingsPage_logout");
  String get settingsPageLogoutConfirmMessage =>
      _string("settingsPage_logoutConfirmMessage");

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
  String get mapPageMapTypeNormal => _string("mapPage_mapTypeNormal");
  String get mapPageMapTypeSatellite => _string("mapPage_mapTypeSatellite");
  String get mapPageMapTypeTerrain => _string("mapPage_mapTypeTerrain");
  String get mapPageMapTypeHybrid => _string("mapPage_mapTypeHybrid");
  String get mapPageErrorGettingLocation =>
      _string("mapPage_errorGettingLocation");
  String get mapPageAppleMaps => _string("mapPage_appleMaps");
  String get mapPageGoogleMaps => _string("mapPage_googleMaps");
  String get mapPageWaze => _string("mapPage_waze");
  String get mapPageErrorOpeningDirections =>
      _string("mapPage_errorOpeningDirections");

  String get saveFishingSpotPageNewTitle =>
      _string("saveFishingSpotPage_newTitle");
  String get saveFishingSpotPageEditTitle =>
      _string("saveFishingSpotPage_editTitle");

  String get formPageManageFieldText => _string("formPage_manageFieldText");
  String get formPageRemoveFieldsText => _string("formPage_removeFieldsText");
  String get formPageConfirmRemoveField =>
      _string("formPage_confirmRemoveField");
  String get formPageConfirmRemoveFields =>
      _string("formPage_confirmRemoveFields");
  String get formPageSelectFieldsTitle => _string("formPage_selectFieldsTitle");
  String get formPageItemAddCustomFieldNote =>
      _string("formPage_addCustomFieldNote");
  String get formPageManageFieldsNote => _string("formPage_manageFieldsNote");

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

  String get saveSpeciesPageNewTitle => _string("saveSpeciesPage_newTitle");
  String get saveSpeciesPageEditTitle => _string("saveSpeciesPage_editTitle");
  String get saveSpeciesPageExistsError =>
      _string("saveSpeciesPage_existsError");

  String get speciesListPageMenuTitle => _string("speciesListPage_menuTitle");
  String get speciesListPageTitle => _string("speciesListPage_title");
  String get speciesListPagePickerTitle =>
      _string("speciesListPage_pickerTitle");
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

  String get fishingSpotPickerPageTitle =>
      _string("fishingSpotPickerPage_title");
  String get fishingSpotPickerPageHint => _string("fishingSpotPickerPage_hint");

  String get fishingSpotListPageTitle => _string("fishingSpotListPage_title");
  String get fishingSpotListPageMultiPickerTitle =>
      _string("fishingSpotListPage_multiPickerTitle");
  String get fishingSpotListPageSinglePickerTitle =>
      _string("fishingSpotListPage_singlePickerTitle");
  String get fishingSpotListPageSearchHint =>
      _string("fishingSpotListPage_searchHint");
  String get fishingSpotListPageEmptyListTitle =>
      _string("fishingSpotListPage_emptyListTitle");
  String get fishingSpotListPageEmptyListDescription =>
      _string("fishingSpotListPage_emptyListDescription");

  String get fishingSpotMapLocationPermissionTitle =>
      _string("fishingSpotMap_locationPermissionTitle");
  String get fishingSpotMapLocationPermissionDescription =>
      _string("fishingSpotMap_locationPermissionDescription");
  String get fishingSpotMapLocationPermissionOpenSettings =>
      _string("fishingSpotMap_locationPermissionOpenSettings");

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
  String get importPageSendReport => _string("importPage_sendReport");
  String get importPageErrorWarningMessage =>
      _string("importPage_errorWarningMessage");
  String get importPageErrorTitle => _string("importPage_errorTitle");

  String get dataImporterChooseFile => _string("dataImporter_chooseFile");
  String get dataImporterStart => _string("dataImporter_start");

  String get migrationPageTitle => _string("migrationPage_title");
  String get migrationPageDescription => _string("migrationPage_description");
  String get migrationPageError => _string("migrationPage_error");
  String get migrationPageLoading => _string("migrationPage_loading");
  String get migrationPageSuccess => _string("migrationPage_success");
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

  String get daysFormat => _string("daysFormat");
  String get hoursFormat => _string("hoursFormat");
  String get minutesFormat => _string("minutesFormat");
  String get secondsFormat => _string("secondsFormat");
  String get dateTimeFormat => _string("dateTimeFormat");
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
  String get proPageSync => _string("proPage_sync");
  String get proPageCustomReports => _string("proPage_customReports");
  String get proPageCustomFields => _string("proPage_customFields");
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
