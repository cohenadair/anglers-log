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
  static const _keyIsPro = "is_pro";

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
  bool get shouldUseFirestore => true;

  @override
  void onUpgradeToPro() {
    // Nothing to do. User preferences are always stored on the cloud,
    // regardless of subscription status.
  }

  Future<void> setBaitCustomEntityIds(List<Id> ids) =>
      putIdList(_keyBaitCustomEntityIds, ids);

  List<Id> get baitCustomEntityIds => idList(_keyBaitCustomEntityIds);

  Future<void> setCatchCustomEntityIds(List<Id> ids) =>
      putIdList(_keyCatchCustomEntityIds, ids);

  List<Id> get catchCustomEntityIds => idList(_keyCatchCustomEntityIds);

  Future<void> setBaitFieldIds(List<Id> ids) =>
      putIdList(_keyBaitFieldIds, ids);

  List<Id> get baitFieldIds => idList(_keyBaitFieldIds);

  Future<void> setCatchFieldIds(List<Id> ids) =>
      putIdList(_keyCatchFieldIds, ids);

  List<Id> get catchFieldIds => idList(_keyCatchFieldIds);

  Future<void> setRateTimerStartedAt(int? timestamp) =>
      put(_keyRateTimerStartedAt, timestamp);

  int? get rateTimerStartedAt => preferences[_keyRateTimerStartedAt];

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidRateApp(bool rated) => put(_keyDidRateApp, rated);

  bool get didRateApp => preferences[_keyDidRateApp] ?? false;

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDidOnboard(bool onboarded) => put(_keyDidOnboard, onboarded);

  bool get didOnboard => preferences[_keyDidOnboard] ?? false;

  Future<void> setSelectedReportId(Id? id) => putId(_keySelectedReportId, id);

  Id? get selectedReportId => id(_keySelectedReportId);

  /// Returns true if the user has been configured as pro. This will override
  /// any in-app purchase setting and can only be set in the Firebase console.
  bool get isPro => preferences[_keyIsPro] ?? false;

  Future<void> _onDeleteCustomEntity(CustomEntity entity) async {
    await setBaitCustomEntityIds(baitCustomEntityIds..remove(entity.id));
    await setCatchCustomEntityIds(catchCustomEntityIds..remove(entity.id));
  }
}
