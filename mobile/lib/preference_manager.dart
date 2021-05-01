import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'data_source_facilitator.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'wrappers/firestore_wrapper.dart';

/// An abstract class for managing a collection of preferences. This class has
/// the capability to sync with Cloud Firestore, if the subclass is setup to
/// do so.
abstract class PreferenceManager extends DataSourceFacilitator {
  static const _keyId = "id";
  static const _keyValue = "value";

  @protected
  String get tableName;

  @protected
  String? get firestoreDocPath;

  @protected
  final Map<String, dynamic> preferences = {};

  late Log _log;

  PreferenceManager(AppManager appManager) : super(appManager) {
    _log = Log("PreferenceManager($runtimeType)");
  }

  @protected
  FirestoreWrapper get firestore => appManager.firestoreWrapper;

  LocalDatabaseManager get localDatabaseManager =>
      appManager.localDatabaseManager;

  @override
  Future<void> initializeLocalData() async {
    for (var row in (await localDatabaseManager.fetchAll(tableName))) {
      preferences[row[_keyId]!] = jsonDecode(row[_keyValue]);
    }
  }

  @override
  void clearMemory() {
    preferences.clear();
  }

  @override
  StreamSubscription? initializeFirestore(Completer completer) {
    assert(isNotEmpty(firestoreDocPath));

    return firestore.doc(firestoreDocPath!).snapshots().listen((snapshot) {
      var data = snapshot.data();
      if (data != null) {
        // Completely replace local data with the Firestore document. For
        // preferences, Firestore is always the source of truth.
        for (var key in List.of(preferences.keys)) {
          putLocal(key, null);
        }

        for (var entry in data.entries) {
          putLocal(entry.key, entry.value);
        }
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    });
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

    if (shouldUseFirestore) {
      await _putFirebase(key, value);
    } else {
      putLocal(key, value);
    }
  }

  @protected
  void putLocal(String key, dynamic value) {
    if (value == null) {
      localDatabaseManager
          .delete(tableName, where: "$_keyId = ?", whereArgs: [key]);
      preferences.remove(key);
    } else {
      localDatabaseManager.insertOrReplace(tableName, {
        _keyId: key,
        _keyValue: jsonEncode(value),
      });
      preferences[key] = value;
    }
  }

  Future<void> _putFirebase(String key, dynamic value) async {
    assert(isNotEmpty(firestoreDocPath));

    var map = {
      key: value,
    };
    var doc = firestore.doc(firestoreDocPath!);

    if ((await doc.get()).exists) {
      await doc.update(map);
    } else {
      await doc.set(map);
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
  Future<void> putIdList(String key, List<Id>? value) {
    if (listEquals(idList(key), value)) {
      return Future.value();
    }

    return put(key,
        value == null ? null : value.map((id) => id.uuid.toString()).toList());
  }

  @protected
  List<Id> idList(String key) {
    return stringList(key).map(parseId).toList();
  }
}
