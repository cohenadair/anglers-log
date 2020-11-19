import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:provider/provider.dart';

class PreferencesManager {
  static PreferencesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).preferencesManager;

  static const _tableName = "preference";
  static const _keyId = "id";
  static const _keyValue = "value";

  static const _keyBaitCustomEntityIds = "bait_custom_entity_ids";
  static const _keyCatchCustomEntityIds = "catch_custom_entity_ids";

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
    (await _dataManager.fetchAll(_tableName)).forEach(
        (row) => _preferences[row[_keyId]] = jsonDecode(row[_keyValue]));
  }

  set baitCustomEntityIds(List<Id> ids) =>
      _putIdList(_keyBaitCustomEntityIds, ids);

  List<Id> get baitCustomEntityIds => _idList(_keyBaitCustomEntityIds);

  set catchCustomEntityIds(List<Id> ids) =>
      _putIdList(_keyCatchCustomEntityIds, ids);

  List<Id> get catchCustomEntityIds => _idList(_keyCatchCustomEntityIds);

  void _putStringList(String key, List<String> value) {
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

  void _putIdList(String key, List<Id> value) {
    _putStringList(
        key, value == null ? null : value.map((id) => id.toString()).toList());
  }

  List<Id> _idList(String key) {
    return _stringList(key).map((str) => parseId(str)).toList();
  }

  void _onDeleteCustomEntity(CustomEntity entity) {
    baitCustomEntityIds = baitCustomEntityIds..remove(entity.id);
    catchCustomEntityIds = catchCustomEntityIds..remove(entity.id);
  }

  void _onDatabaseReset() {
    baitCustomEntityIds = null;
    catchCustomEntityIds = null;
  }
}
