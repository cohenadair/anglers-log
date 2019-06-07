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

  String get cancel => _getString("cancel");
  String get done => _getString("done");
  String get save => _getString("save");
  String get delete => _getString("delete");
  String get none => _getString("none");
  String get ok => _getString("ok");
  String get error => _getString("error");
  String get warning => _getString("warning");
  String get continueString => _getString("continue");
  String get yes => _getString("yes");
  String get no => _getString("no");

  String get inputRequiredMessage => _getString("input_requiredMessage");

  String get loginPageLoginTitle => _getString("loginPage_loginTitle");
  String get loginPageLoginButtonText => _getString("loginPage_loginButtonText");
  String get loginPageLoginQuestionText => _getString("loginPage_loginQuestionText");
  String get loginPageLoginActionText => _getString("loginPage_loginActionText");
  String get loginPageSignUpTitle => _getString("loginPage_signUpTitle");
  String get loginPageSignUpButtonText => _getString("loginPage_signUpButtonText");
  String get loginPageSignUpQuestionText => _getString("loginPage_signUpQuestionText");
  String get loginPageSignUpActionText => _getString("loginPage_signUpActionText");
  String get loginPageEmailLabel => _getString("loginPage_emailLabel");
  String get loginPageEmailRequired => _getString("loginPage_emailRequired");
  String get loginPageEmailInvalidFormat => _getString("loginPage_emailInvalidFormat");
  String get loginPagePasswordLabel => _getString("loginPage_passwordLabel");
  String get loginPagePasswordRequired => _getString("loginPage_passwordRequired");
  String get loginPagePasswordInvalidLength => _getString("loginPage_passwordInvalidLength");
  String get loginPageErrorLoginUnknown => _getString("loginPage_errorLoginUnknown");
  String get loginPageErrorSignUpUnknown => _getString("loginPage_errorSignUpUnknown");
  String get loginPageErrorCredentials => _getString("loginPage_errorCredentials");

  String get settingsPageTitle => _getString("settingsPage_title");
  String get settingsPageAccountHeading => _getString("settingsPage_accountHeading");
  String get settingsPageLogout => _getString("settingsPage_logout");
  String get settingsPathLogoutConfirmMessage => _getString("settingsPath_logoutConfirmMessage");

  String get anglerNameLabel => _getString("angler_nameLabel");
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