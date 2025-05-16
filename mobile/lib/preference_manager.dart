import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

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

  final _controller = StreamController<String>.broadcast();

  late Log _log;

  PreferenceManager() {
    _log = Log("PreferenceManager($runtimeType)");
  }

  /// A [Stream] that fires events when any preference updates.
  Stream<String> get stream => _controller.stream;

  Future<void> init() async {
    preferences.clear();
    for (var row in (await LocalDatabaseManager.get.fetchAll(tableName))) {
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
      LocalDatabaseManager.get
          .delete(tableName, where: "$_keyId = ?", whereArgs: [key]);
      preferences.remove(key);
    } else {
      LocalDatabaseManager.get.insertOrReplace(tableName, {
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

  @protected
  Map<Id, T> idMap<T>(String key) {
    if (!preferences.containsKey(key)) {
      return {};
    }

    return (preferences[key] as Map<String, dynamic>)
        .map((k, v) => MapEntry(Id(uuid: k), v));
  }

  @protected
  Future<void> putIdMap<T>(String key, Map<Id, T>? value) {
    if (mapEquals<Id, T>(idMap(key), value)) {
      return Future.value();
    }

    return put(key, value?.map((key, value) => MapEntry(key.uuid, value)));
  }
}
