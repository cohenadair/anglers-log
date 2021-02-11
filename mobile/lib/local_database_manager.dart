import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'app_manager.dart';
import 'database/sqlite_open_helper.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';

enum LocalDatabaseEvent {
  reset,
}

class LocalDatabaseManager {
  static LocalDatabaseManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).localDatabaseManager;

  final _log = Log("DataManager");
  final _controller = StreamController<LocalDatabaseEvent>.broadcast();

  Database _database;
  Future<Database> Function() _openDatabase;
  Future<Database> Function() _resetDatabase;

  Future<void> initialize({
    Database database,
    Future<Database> Function() openDatabase,
    Future<Database> Function() resetDatabase,
  }) async {
    _openDatabase = openDatabase ?? openDb;
    _resetDatabase = resetDatabase ?? resetDb;
    _database = database ?? (await _openDatabase());
  }

  Stream<LocalDatabaseEvent> get stream => _controller.stream;

  /// Completely resets the database by deleting the SQLite file and recreating
  /// it from scratch. All [EntityManager] subclasses are synced with the
  /// database after it has been recreated.
  Future<void> reset() async {
    await _database.close();
    _database = await _resetDatabase();
    _controller.add(LocalDatabaseEvent.reset);
  }

  /// Commits a batch of SQL statements. See [Batch].
  Future<List<dynamic>> commitBatch(void Function(Batch) execute) async {
    var batch = _database.batch();
    execute(batch);
    return await batch.commit();
  }

  /// Returns `true` if values were successfully added.
  Future<bool> insert(String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values) > 0;
  }

  /// Returns `true` if values were successfully added or replaced.
  Future<bool> insertOrReplace(
      String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values,
            conflictAlgorithm: ConflictAlgorithm.replace) >
        0;
  }

  /// Returns `true` if at least one row was removed.
  Future<bool> delete(String table,
      {String where, List<dynamic> whereArgs}) async {
    return await _database.delete(table, where: where, whereArgs: whereArgs) >
        0;
  }

  /// Returns `true` if the row from the given table with the given ID was
  /// updated.
  Future<bool> _updateId(
      String tableName, Id id, Map<String, dynamic> values) async {
    return await _database.update(
          tableName,
          values,
          where: "id = ?",
          whereArgs: [id.uint8List],
        ) >
        0;
  }

  /// Returns true if the given ID exists in the given table; false otherwise.
  Future<bool> _idExists(String tableName, Id id) async {
    var count = Sqflite.firstIntValue(await _database.rawQuery(
        "SELECT COUNT(*) FROM $tableName WHERE id = ?", [id.uint8List]));
    return count != null && count > 0;
  }

  /// Allows a raw query to be sent to the database.
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic> args]) {
    return _database.rawQuery(sql, args);
  }

  Future<bool> rawExists(String query, [List<dynamic> args]) async {
    return Sqflite.firstIntValue(await _database.rawQuery(query, args)) > 0;
  }

  Future<bool> rawUpdate(String query, [List<dynamic> args]) async {
    return await _database.rawUpdate(query, args) > 0;
  }

  /// Inserts a new [Entity] into the given [tableName] or updates the existing
  /// [Entity] if one with the same ID already exists.
  Future<bool> insertOrUpdateEntity(
      Id entityId, Map<String, dynamic> map, String tableName) async {
    if (await _idExists(tableName, entityId)) {
      // Update if entity with ID already exists.
      if (await _updateId(tableName, entityId, map)) {
        return true;
      } else {
        _log.e("Failed to update $tableName($entityId");
      }
    } else {
      // Otherwise, create new entity.
      if (await insert(tableName, map)) {
        return true;
      } else {
        _log.e("Failed to insert $tableName($entityId)");
      }
    }
    return false;
  }

  /// Deletes a given [Entity] from the given [tableName].
  Future<bool> deleteEntity(Id entityId, String tableName) async {
    var id = entityId.uint8List;
    if (await delete(tableName, where: "id = ?", whereArgs: [id])) {
      return true;
    } else {
      _log.e("Failed to delete $tableName($id) from database");
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchAll(String tableName) async {
    return await query("SELECT * FROM $tableName");
  }

  Future<Map<String, dynamic>> fetchEntity(String tableName, String id) async {
    _log.w("fetch($tableName, $id) called");

    var result = await query("SELECT * FROM $tableName WHERE id = ?", [id]);
    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  /// Completely replaces the contents of [tableName] with [newRows].
  Future<void> replaceRows(
      String tableName, List<Map<String, dynamic>> newRows) async {
    await commitBatch((batch) {
      batch.rawQuery("DELETE FROM $tableName");
      for (var row in newRows) {
        batch.insert(tableName, row);
      }
    });
  }
}
