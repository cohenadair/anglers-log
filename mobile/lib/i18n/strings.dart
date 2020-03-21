import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/english_strings.dart';

class Strings {
  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> get _values => {
    "en" : englishStrings,
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
    String value = _values[_locale.languageCode][_locale.countryCode][key];
    if (value == null) {
      return _values[_locale.languageCode]["default"][key];
    }
    return value;
  }

  String get appName => _string("appName");

  String get cancel => _string("cancel");
  String get done => _string("done");
  String get save => _string("save");
  String get edit => _string("edit");
  String get delete => _string("delete");
  String get none => _string("none");
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
  String get addAnother => _string("addAnother");

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

  String get tripListPageMenuLabel => _string("tripListPage_menuLabel");
  String get tripListPageTitle => _string("tripListPage_title");

  String get catchListPageMenuLabel => _string("catchListPage_menuLabel");
  String get catchListPageTitle => _string("catchListPage_title");

  String get addCatchPageNewTitle => _string("addCatchPage_newTitle");
  String get addCatchPageDateTimeLabel => _string("addCatchPage_dateTimeLabel");
  String get addCatchPageDateLabel => _string("addCatchPage_dateLabel");
  String get addCatchPageTimeLabel => _string("addCatchPage_timeLabel");

  String get photosPageMenuLabel => _string("photosPage_menuLabel");
  String get photosPageTitle => _string("photosPage_title");

  String get baitListPageMenuLabel => _string("baitListPage_menuLabel");
  String get baitListPageTitle => _string("baitListPage_title");
  String get baitListPageOtherCategory => _string("baitListPage_otherCategory");

  String get baitPageDeleteMessage => _string("baitPage_deleteMessage");

  String get saveBaitPageNewTitle => _string("saveBaitPage_newTitle");
  String get saveBaitPageEditTitle => _string("saveBaitPage_editTitle");
  String get saveBaitPageCategoryLabel => _string("saveBaitPage_categoryLabel");
  String get saveBaitPageNewCategoryLabel => _string("saveBaitPage_newCategoryLabel");
  String get saveBaitPageEditCategoryLabel => _string("saveBaitPage_editCategoryLabel");
  String get saveBaitPageCategoryExistsMessage => _string("saveBaitPage_categoryExistsMessage");
  String get saveBaitPageCategoryPickerTitle => _string("saveBaitPage_categoryPickerTitle");
  String get saveBaitPageConfirmDeleteCategory => _string("saveBaitPage_confirmDeleteCategory");
  String get saveBaitPageBaitExists => _string("saveBaitPage_baitExists");

  String get statsPageTitle => _string("statsPage_title");

  String get morePageTitle => _string("morePage_title");

  String get settingsPageTitle => _string("settingsPage_title");

  String get mapPageMenuLabel => _string("mapPage_menuLabel");
  String get mapPageDeleteFishingSpot => _string("mapPage_deleteFishingSpot");
  String get mapPageAddCatch => _string("mapPage_addCatch");
  String get mapPageSearchHint => _string("mapPage_searchHint");
  String get mapPageNoSearchResults => _string("mapPage_noSearchResults");
  String get mapPageDroppedPin => _string("mapPage_droppedPin");
  String get mapPageMapTypeNormal => _string("mapPage_mapTypeNormal");
  String get mapPageMapTypeSatellite => _string("mapPage_mapTypeSatellite");
  String get mapPageMapTypeTerrain => _string("mapPage_mapTypeTerrain");
  String get mapPageMapTypeHybrid => _string("mapPage_mapTypeHybrid");
  String get mapPageErrorGettingLocation => _string("mapPage_errorGettingLocation");

  String get saveFishingSpotPageNewTitle => _string("saveFishingSpotPage_newTitle");
  String get saveFishingSpotPageEditTitle => _string("saveFishingSpotPage_editTitle");

  String get formPageManageFieldText => _string("formPage_manageFieldText");
  String get formPageRemoveFieldsText => _string("formPage_removeFieldsText");
  String get formPageConfirmRemoveField => _string("formPage_confirmRemoveField");
  String get formPageConfirmRemoveFields => _string("formPage_confirmRemoveFields");
  String get formPageSelectFieldsTitle => _string("formPage_selectFieldsTitle");

  String get selectionPageAddCustomField => _string("selectionPage_addCustomField");

  String get imagePickerPageNoPhotosFound => _string("imagePickerPage_noPhotosFound");
  String get imagePickerPageOpenCameraLabel => _string("imagePickerPage_openCameraLabel");
  String get imagePickerPageCameraLabel => _string("imagePickerPage_cameraLabel");
  String get imagePickerPageGalleryLabel => _string("imagePickerPage_galleryLabel");
  String get imagePickerPageBrowseLabel => _string("imagePickerPage_browseLabel");
  String get imagePickerPageSelectedLabel => _string("imagePickerPage_selectedLabel");
  String get imagePickerPageInvalidSelectionSingle => _string("imagePickerPage_invalidSelectionSingle");
  String get imagePickerPageInvalidSelectionPlural => _string("imagePickerPage_invalidSelectionPlural");

  String get speciesPickerPageNewTitle => _string("speciesPickerPage_newTitle");
  String get speciesPickerPageEditTitle => _string("speciesPickerPage_editTitle");
  String get speciesPickerPageSpeciesExists => _string("speciesPickerPage_speciesExists");
  String get speciesPickerPageTitle => _string("speciesPickerPage_title");
  String get speciesPickerPageConfirmDelete => _string("speciesPickerPage_confirmDelete");

  String get fishingSpotPickerPageTitle => _string("fishingSpotPickerPage_title");

  String get addCustomFieldPageTitle => _string("addCustomFieldPage_title");
  String get addCustomFieldPageNameExists => _string("addCustomFieldPage_nameExists");

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
  String get analysisDurationLast14Days => _string("analysisDuration_last14Days");
  String get analysisDurationLast30Days => _string("analysisDuration_last30Days");
  String get analysisDurationLast60Days => _string("analysisDuration_last60Days");
  String get analysisDurationLast12Months => _string("analysisDuration_last12Months");
  String get analysisDurationCustom => _string("analysisDuration_custom");

  String get dateTimeFormat => _string("dateTimeFormat");
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