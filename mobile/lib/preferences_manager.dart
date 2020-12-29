import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'data_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';

class PreferencesManager {
  static PreferencesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).preferencesManager;

  static const _tableName = "preference";
  static const _keyId = "id";
  static const _keyValue = "value";

  static const _keyBaitCustomEntityIds = "bait_custom_entity_ids";
  static const _keyCatchCustomEntityIds = "catch_custom_entity_ids";
  static const _keyBaitFieldIds = "bait_field_ids";
  static const _keyCatchFieldIds = "catch_field_ids";

  static const _keyRateTimerStartedAt = "rate_timer_started_at";
  static const _keyDidRateApp = "did_rate_app";
  static const _keyDidOnboard = "did_onboard";

  static const _keySelectedReportId = "selected_report_id";

  final AppManager _appManager;
  final Map<String, dynamic> _preferences = {};

  PreferencesManager(AppManager app) : _appManager = app {
    _appManager.customEntityManager
        .addListener(SimpleEntityListener(onDelete: _onDeleteCustomEntity));
    _appManager.dataManager
        .addListener(DataListener(onReset: _onDatabaseReset));
  }

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize() async {
    for (var row in (await _dataManager.fetchAll(_tableName))) {
      _preferences[row[_keyId]] = jsonDecode(row[_keyValue]);
    }
  }

  set baitCustomEntityIds(List<Id> ids) =>
      _putIdList(_keyBaitCustomEntityIds, ids);

  List<Id> get baitCustomEntityIds => _idList(_keyBaitCustomEntityIds);

  set catchCustomEntityIds(List<Id> ids) =>
      _putIdList(_keyCatchCustomEntityIds, ids);

  List<Id> get catchCustomEntityIds => _idList(_keyCatchCustomEntityIds);

  set baitFieldIds(List<Id> ids) => _putIdList(_keyBaitFieldIds, ids);

  List<Id> get baitFieldIds => _idList(_keyBaitFieldIds);

  set catchFieldIds(List<Id> ids) => _putIdList(_keyCatchFieldIds, ids);

  List<Id> get catchFieldIds => _idList(_keyCatchFieldIds);

  set rateTimerStartedAt(int timestamp) =>
      _put(_keyRateTimerStartedAt, timestamp);

  int get rateTimerStartedAt => _preferences[_keyRateTimerStartedAt];

  set didRateApp(bool rated) => _put(_keyDidRateApp, rated);

  bool get didRateApp => _preferences[_keyDidRateApp] ?? false;

  set didOnboard(bool onboarded) => _put(_keyDidOnboard, onboarded);

  bool get didOnboard => _preferences[_keyDidOnboard] ?? false;

  set selectedReportId(Id id) => _putId(_keySelectedReportId, id);

  Id get selectedReportId => _id(_keySelectedReportId);

  void _put(String key, dynamic value) {
    if (value == null) {
      _dataManager.delete(_tableName, where: "$_keyId = ?", whereArgs: [key]);
      _preferences.remove(key);
    } else {
      _dataManager.insertOrReplace(_tableName, {
        _keyId: key,
        _keyValue: jsonEncode(value),
      });
      _preferences[key] = value;
    }
  }

  List<String> _stringList(String key) {
    if (!_preferences.containsKey(key)) {
      return [];
    }

    return (_preferences[key] as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }

  void _putId(String key, Id value) => _put(key, value?.toString());

  Id _id(String key) {
    if (!_preferences.containsKey(key)) {
      return null;
    }
    return safeParseId(_preferences[key]);
  }

  void _putIdList(String key, List<Id> value) {
    _put(key, value == null ? null : value.map((id) => id.toString()).toList());
  }

  List<Id> _idList(String key) {
    return _stringList(key).map(parseId).toList();
  }

  void _onDeleteCustomEntity(CustomEntity entity) {
    baitCustomEntityIds = baitCustomEntityIds..remove(entity.id);
    catchCustomEntityIds = catchCustomEntityIds..remove(entity.id);
  }

  void _onDatabaseReset() {
    baitCustomEntityIds = null;
    catchCustomEntityIds = null;
    baitFieldIds = null;
    catchFieldIds = null;
    rateTimerStartedAt = null;
    didRateApp = false;
    didOnboard = false;
    selectedReportId = null;
  }
}
