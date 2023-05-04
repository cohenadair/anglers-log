import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'app_manager.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';

/// An abstract class for managing a collection of preferences.
abstract class PreferenceManager {
  static const _keyId = "id";
  static const _keyValue = "value";

  @protected
  String get tableName;

  @protected
  final Map<String, dynamic> preferences = {};

  @protected
  final AppManager appManager;

  final _controller = StreamController<String>.broadcast();

  late Log _log;

  PreferenceManager(this.appManager) {
    _log = Log("PreferenceManager($runtimeType)");
  }

  /// A [Stream] that fires events when any preference updates.
  Stream<String> get stream => _controller.stream;

  LocalDatabaseManager get _localDatabaseManager =>
      appManager.localDatabaseManager;

  Future<void> initialize() async {
    preferences.clear();
    for (var row in (await _localDatabaseManager.fetchAll(tableName))) {
      preferences[row[_keyId]!] = jsonDecode(row[_keyValue]);
    }
  }

  @protected
  Future<void> put(String key, dynamic value) async {
    // Note that == for List objects does not do a deep comparison. A separate
    // put method for List types should be implemented. For example,
    // putStringList and putIdList.
    if (preferences[key] == value) {
      return;
    }

    _log.d("Setting key=$key, value=$value");
    putLocal(key, value);

    _controller.add(key);
  }

  @protected
  void putLocal(String key, dynamic value) {
    if (value == null) {
      _localDatabaseManager
          .delete(tableName, where: "$_keyId = ?", whereArgs: [key]);
      preferences.remove(key);
    } else {
      _localDatabaseManager.insertOrReplace(tableName, {
        _keyId: key,
        _keyValue: jsonEncode(value),
      });
      preferences[key] = value;
    }
  }

  @protected
  void putStringList(String key, List<String>? value) {
    if (listEquals(preferences[key], value)) {
      return;
    }

    put(key, value);
  }

  @protected
  List<String> stringList(String key) {
    if (!preferences.containsKey(key)) {
      return [];
    }

    return (preferences[key] as List<dynamic>).map((e) => e as String).toList();
  }

  @protected
  Future<void> putId(String key, Id? value) => put(key, value?.uuid.toString());

  @protected
  Id? id(String key) {
    if (!preferences.containsKey(key)) {
      return null;
    }
    return safeParseId(preferences[key]);
  }

  @protected
  Future<void> putIdCollection(String key, Iterable<Id>? value) {
    if (setEquals(idList(key).toSet(), value?.toSet())) {
      return Future.value();
    }

    return put(key, value?.map((id) => id.uuid.toString()).toList());
  }

  @protected
  List<Id> idList(String key) {
    return stringList(key).map(parseId).toList();
  }
}
