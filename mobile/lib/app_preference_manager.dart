import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'auth_manager.dart';
import 'wrappers/shared_preferences_wrapper.dart';

/// Preferences at the app level, such as the last user ID to be signed in.
/// Preferences managed by this class are not backed up to Firebase, regardless
/// of the current user's subscription status.
class AppPreferenceManager {
  static AppPreferenceManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).appPreferenceManager;

  static const _keyLastLoggedInEmail = "last_logged_in_email";

  final AppManager _appManager;
  final Map<String, dynamic> _preferences = {};

  AuthManager get _authManager => _appManager.authManager;

  SharedPreferencesWrapper get _sharedPreferences =>
      _appManager.sharedPreferencesWrapper;

  AppPreferenceManager(this._appManager);

  Future<void> initialize() async {
    _authManager.stream.listen((_) {
      if (_authManager.state == AuthState.loggedIn) {
        lastLoggedInEmail = _authManager.userEmail;
      }
    });
  }

  set lastLoggedInEmail(String? email) {
    if (isEmpty(email)) {
      _sharedPreferences.remove(_keyLastLoggedInEmail);
      _preferences.remove(_keyLastLoggedInEmail);
    } else {
      _sharedPreferences.setString(_keyLastLoggedInEmail, email!);
      _preferences[_keyLastLoggedInEmail] = email;
    }
  }

  String? get lastLoggedInEmail => _preferences[_keyLastLoggedInEmail];
}
