import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'custom_entity_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'preference_manager.dart';

class UserPreferenceManager extends PreferenceManager {
  static UserPreferenceManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).userPreferenceManager;

  static const _keyBaitCustomEntityIds = "bait_custom_entity_ids";
  static const _keyCatchCustomEntityIds = "catch_custom_entity_ids";
  static const _keyBaitFieldIds = "bait_field_ids";
  static const _keyCatchFieldIds = "catch_field_ids";

  static const _keyRateTimerStartedAt = "rate_timer_started_at";
  static const _keyDidRateApp = "did_rate_app";
  static const _keyDidOnboard = "did_onboard";

  static const _keySelectedReportId = "selected_report_id";

  UserPreferenceManager(AppManager appManager) : super(appManager) {
    _customEntityManager
        .addListener(SimpleEntityListener(onDelete: _onDeleteCustomEntity));
  }

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  @override
  String get tableName => "user_preference";

  @override
  String get firestoreDocPath => authManager.firestoreDocPath;

  @override
  bool get enableFirestore => true;

  @override
  StreamSubscription initializeFirestore(Completer completer) {
    return firestore.doc(firestoreDocPath).snapshots().listen((snapshot) {
      var data = snapshot.data();
      if (data != null) {
        // Completely replace local data with the Firestore document.
        clearLocalData();
        for (var entry in data.entries) {
          putLocal(entry.key, entry.value);
        }
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }

  @override
  void onLocalDatabaseDeleted() {
    baitCustomEntityIds = null;
    catchCustomEntityIds = null;
    baitFieldIds = null;
    catchFieldIds = null;
    selectedReportId = null;

    // Don't want to reset all properties. Some should persist across resets.
    // For example, we don't want to show user onboarding again if they import
    // data from an archive.
    //
    // Setting these to themselves will add them to the new database.
    rateTimerStartedAt = rateTimerStartedAt;
    didRateApp = didRateApp;
    didOnboard = didOnboard;
  }

  set baitCustomEntityIds(List<Id> ids) =>
      putIdList(_keyBaitCustomEntityIds, ids);

  List<Id> get baitCustomEntityIds => idList(_keyBaitCustomEntityIds);

  set catchCustomEntityIds(List<Id> ids) =>
      putIdList(_keyCatchCustomEntityIds, ids);

  List<Id> get catchCustomEntityIds => idList(_keyCatchCustomEntityIds);

  set baitFieldIds(List<Id> ids) => putIdList(_keyBaitFieldIds, ids);

  List<Id> get baitFieldIds => idList(_keyBaitFieldIds);

  set catchFieldIds(List<Id> ids) => putIdList(_keyCatchFieldIds, ids);

  List<Id> get catchFieldIds => idList(_keyCatchFieldIds);

  set rateTimerStartedAt(int timestamp) =>
      put(_keyRateTimerStartedAt, timestamp);

  int get rateTimerStartedAt => preferences[_keyRateTimerStartedAt];

  set didRateApp(bool rated) => put(_keyDidRateApp, rated);

  bool get didRateApp => preferences[_keyDidRateApp] ?? false;

  set didOnboard(bool onboarded) => put(_keyDidOnboard, onboarded);

  bool get didOnboard => preferences[_keyDidOnboard] ?? false;

  set selectedReportId(Id id) => putId(_keySelectedReportId, id);

  Id get selectedReportId => id(_keySelectedReportId);

  void _onDeleteCustomEntity(CustomEntity entity) {
    baitCustomEntityIds = baitCustomEntityIds..remove(entity.id);
    catchCustomEntityIds = catchCustomEntityIds..remove(entity.id);
  }
}
