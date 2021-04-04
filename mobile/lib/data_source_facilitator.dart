import 'dart:async';

import 'package:flutter/material.dart';

import 'app_manager.dart';
import 'app_preference_manager.dart';
import 'auth_manager.dart';
import 'log.dart';
import 'subscription_manager.dart';

/// An abstract class that facilitates the data source used for the manager's
/// underlying data model. Which source is used depends on abstract method
/// implementations and the user's subscription status.
///
/// This class only facilitates the initialization and deleting of the
/// underlying data when a user's auth status changes. It is not designed to
/// add, modify, or delete data.
abstract class DataSourceFacilitator {
  /// Setting to true will initialize data from Firestore, overriding any local
  /// data left over from the last session. Setting to false will only use
  /// local data. For example, when saving application level preferences that
  /// don't have anything to do with the current user.
  @protected
  bool get enableFirestore;

  /// Initializes local data, usually from the SQLite database and/or memory
  /// cache.
  @protected
  Future<void> initializeLocalData();

  /// Clears the local data. This is called when a different user logs in.
  @protected
  Future<void> clearLocalData();

  /// This method, when [enableFirestore] is true, must return a
  /// [StreamSubscription], usually from a Firestore document or collection.
  /// The implementation of this method must call [completer.complete] to
  /// signify that the data is fully initialized.
  ///
  /// The Firestore listener created in this method should set local cache for
  /// the underlying data model.
  @protected
  StreamSubscription<dynamic>? initializeFirestore(Completer completer);

  /// Called when a user purchases or restores a pro subscription. This method
  /// is invoked _after_ [initializeFirestore] has finished.
  @protected
  void onUpgradeToPro();

  @protected
  final AppManager appManager;

  StreamSubscription<dynamic>? _firestoreListener;
  late Log _log;

  DataSourceFacilitator(this.appManager) {
    _log = Log("DataSourceFacilitator($runtimeType)");

    authManager.stream.listen((_) {
      if (authManager.state == AuthState.loggedOut) {
        _cancelFirestoreListener();
      }
    });

    subscriptionManager.stream.listen((_) async {
      if (shouldUseFirestore && _firestoreListener == null) {
        _log.d("User upgraded to pro, reconciling data...");
        await _initializeFirestore();
        onUpgradeToPro();
      }
    });
  }

  @protected
  AppPreferenceManager get appPreferenceManager =>
      appManager.appPreferenceManager;

  @protected
  AuthManager get authManager => appManager.authManager;

  @protected
  SubscriptionManager get subscriptionManager => appManager.subscriptionManager;

  @protected
  bool get shouldUseFirestore => subscriptionManager.isPro && enableFirestore;

  Future<void> initialize() async {
    if (appPreferenceManager.lastLoggedInUserId != authManager.userId) {
      _log.d("User changed, clearing local data");
      await clearLocalData();
    }

    _log.d("Initializing "
        "user=${subscriptionManager.isPro ? "pro" : "free"}; "
        "firestore=$enableFirestore");
    if (shouldUseFirestore) {
      return _initializeFirestore();
    } else {
      return initializeLocalData();
    }
  }

  Future<void> _initializeFirestore() async {
    await _cancelFirestoreListener();
    var completer = Completer();
    _firestoreListener = initializeFirestore(completer);
    return completer.future;
  }

  Future<void> _cancelFirestoreListener() async {
    if (_firestoreListener != null) {
      _log.d("Cancelling Firestore listener");
      await _firestoreListener!.cancel();
      _firestoreListener = null;
    }
  }
}
