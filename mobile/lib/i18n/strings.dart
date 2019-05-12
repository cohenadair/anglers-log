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
  String fromId(String id) => _getString(id);

  /// If a specific string for a language and country exists, use it, otherwise
  /// use the default.
  String _getString(String key) {
    String value = _values[_locale.languageCode][_locale.countryCode][key];
    if (value == null) {
      return _values[_locale.languageCode]["default"][key];
    }
    return value;
  }

  String get appName => _getString("appName");
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