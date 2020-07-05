import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_entity.dart';
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
    _appManager.customEntityManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteCustomEntity
    ));
    _appManager.dataManager.addListener(DataListener(
      onReset: _onDatabaseReset
    ));
  }

  DataManager get _dataManager => _appManager.dataManager;

  Future<void> initialize() async {
    (await _dataManager.fetchAll(_tableName)).forEach((row) =>
        _preferences[row[_keyId]] = jsonDecode(row[_keyValue]));
  }

  set baitCustomEntityIds(List<String> ids) =>
      _putStringList(_keyBaitCustomEntityIds, ids);

  List<String> get baitCustomEntityIds => _stringList(_keyBaitCustomEntityIds);

  set catchCustomEntityIds(List<String> ids) =>
      _putStringList(_keyCatchCustomEntityIds, ids);

  List<String> get catchCustomEntityIds =>
      _stringList(_keyCatchCustomEntityIds);

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

  void _onDeleteCustomEntity(CustomEntity entity) {
    baitCustomEntityIds = baitCustomEntityIds..remove(entity.id);
    catchCustomEntityIds = catchCustomEntityIds..remove(entity.id);
  }

  void _onDatabaseReset() {
    baitCustomEntityIds = null;
    catchCustomEntityIds = null;
  }
}