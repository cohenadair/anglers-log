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
  String get delete => _string("delete");
  String get none => _string("none");
  String get ok => _string("ok");
  String get error => _string("error");
  String get warning => _string("warning");
  String get continueString => _string("continue");
  String get yes => _string("yes");
  String get no => _string("no");

  String get fieldTypeNumber => _string("fieldType_number");
  String get fieldTypeBoolean => _string("fieldType_boolean");
  String get fieldTypeText => _string("fieldType_text");

  String get inputRequiredMessage => _string("input_requiredMessage");
  String get inputNameLabel => _string("input_nameLabel");
  String get inputNameRequired => _string("input_nameRequired");
  String get inputDescriptionLabel => _string("input_descriptionLabel");
  String get inputInvalidNumber => _string("input_invalidNumber");

  String get loginPageLoginTitle => _string("loginPage_loginTitle");
  String get loginPageLoginButtonText => _string("loginPage_loginButtonText");
  String get loginPageLoginQuestionText => _string("loginPage_loginQuestionText");
  String get loginPageLoginActionText => _string("loginPage_loginActionText");
  String get loginPageSignUpTitle => _string("loginPage_signUpTitle");
  String get loginPageSignUpButtonText => _string("loginPage_signUpButtonText");
  String get loginPageSignUpQuestionText => _string("loginPage_signUpQuestionText");
  String get loginPageSignUpActionText => _string("loginPage_signUpActionText");
  String get loginPageEmailLabel => _string("loginPage_emailLabel");
  String get loginPageEmailRequired => _string("loginPage_emailRequired");
  String get loginPageEmailInvalidFormat => _string("loginPage_emailInvalidFormat");
  String get loginPagePasswordLabel => _string("loginPage_passwordLabel");
  String get loginPagePasswordRequired => _string("loginPage_passwordRequired");
  String get loginPagePasswordInvalidLength => _string("loginPage_passwordInvalidLength");
  String get loginPageErrorLoginUnknown => _string("loginPage_errorLoginUnknown");
  String get loginPageErrorSignUpUnknown => _string("loginPage_errorSignUpUnknown");
  String get loginPageErrorCredentials => _string("loginPage_errorCredentials");

  String get settingsPageTitle => _string("settingsPage_title");

  String get formPageAddFieldText => _string("formPage_addFieldText");
  String get formPageRemoveFieldsText => _string("formPage_removeFieldsText");
  String get formPageConfirmRemoveField => _string("formPage_confirmRemoveField");
  String get formPageConfirmRemoveFields => _string("formPage_confirmRemoveFields");
  String get formPageSelectFieldTitle => _string("formPage_selectFieldTitle");

  String get selectionPageAddCustomField => _string("selectionPage_addCustomField");

  String get addCustomFieldPageTitle => _string("addCustomFieldPage_title");

  String get anglerNameLabel => _string("angler_nameLabel");
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