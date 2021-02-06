import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/auth_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'preference_manager.dart';

/// Preferences at the app level, such as the last user ID to be signed in.
/// Preferences manages by this class are not backed up to Firebase, regardless
/// of the current user's subscription status.
class AppPreferenceManager extends PreferenceManager {
  static AppPreferenceManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).appPreferenceManager;

  static const _keyLastLoggedInUserId = "last_logged_in_user_id";

  AppPreferenceManager(AppManager appManager) : super(appManager) {
    authManager.stream.listen((_) {
      if (authManager.state == AuthState.loggedIn) {
        lastLoggedInUserId = authManager.userId;
      }
    });
  }

  @override
  String get tableName => "app_preference";

  @override
  String get firestoreDocPath => null;

  @override
  bool get enableFirestore => false;

  @override
  StreamSubscription initializeFirestore(Completer completer) => null;

  @override
  void onLocalDatabaseDeleted() {
    lastLoggedInUserId = null;
  }

  set lastLoggedInUserId(String id) => put(_keyLastLoggedInUserId, id);

  String get lastLoggedInUserId => preferences[_keyLastLoggedInUserId];
}
