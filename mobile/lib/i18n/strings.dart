import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/english_strings.dart';

class Strings {
  static const List<String> _supportedLanguages = ["en"];

  static Map<String, Map<String, Map<String, String>>> _values = {
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
  String get ok => _string("ok");
  String get error => _string("error");
  String get warning => _string("warning");
  String get continueString => _string("continue");
  String get yes => _string("yes");
  String get no => _string("no");
  String get today => _string("today");
  String get yesterday => _string("yesterday");
  String get directions => _string("directions");

  String get fieldTypeNumber => _string("fieldType_number");
  String get fieldTypeBoolean => _string("fieldType_boolean");
  String get fieldTypeText => _string("fieldType_text");

  String get inputRequiredMessage => _string("input_requiredMessage");
  String get inputNameLabel => _string("input_nameLabel");
  String get inputNameRequired => _string("input_nameRequired");
  String get inputDescriptionLabel => _string("input_descriptionLabel");
  String get inputInvalidNumber => _string("input_invalidNumber");

  String get tripListPageMenuLabel => _string("tripListPage_menuLabel");
  String get tripListPageTitle => _string("tripListPage_title");

  String get catchListPageMenuLabel => _string("catchListPage_menuLabel");
  String get catchListPageTitle => _string("catchListPage_title");

  String get addCatchPageDateTimeLabel => _string("addCatchPage_dateTimeLabel");
  String get addCatchPageDateLabel => _string("addCatchPage_dateLabel");
  String get addCatchPageTimeLabel => _string("addCatchPage_timeLabel");

  String get photosPageMenuLabel => _string("photosPage_menuLabel");
  String get photosPageTitle => _string("photosPage_title");

  String get baitListPageMenuLabel => _string("baitListPage_menuLabel");
  String get baitListPageTitle => _string("baitListPage_title");

  String get statsPageTitle => _string("statsPage_title");

  String get morePageTitle => _string("morePage_title");

  String get settingsPageTitle => _string("settingsPage_title");

  String get mapPageMenuLabel => _string("mapPage_menuLabel");
  String get mapPageDeleteFishingSpot => _string("mapPage_DeleteFishingSpot");

  String get formPageAddFieldText => _string("formPage_addFieldText");
  String get formPageRemoveFieldsText => _string("formPage_removeFieldsText");
  String get formPageConfirmRemoveField => _string("formPage_confirmRemoveField");
  String get formPageConfirmRemoveFields => _string("formPage_confirmRemoveFields");
  String get formPageSelectFieldTitle => _string("formPage_selectFieldTitle");

  String get selectionPageAddCustomField => _string("selectionPage_addCustomField");

  String get addCustomFieldPageTitle => _string("addCustomFieldPage_title");

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

  String get fishingSpotBottomSheetLatLngLabel => _string("fishingSpotBottomSheet_latLngLabel");
  String get fishingSpotBottomSheetDroppedPin => _string("fishingSpotBottomSheet_droppedPin");
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