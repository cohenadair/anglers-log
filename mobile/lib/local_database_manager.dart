import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

import 'app_manager.dart';
import 'database/sqlite_open_helper.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'wrappers/io_wrapper.dart';

class LocalDatabaseManager {
  static LocalDatabaseManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).localDatabaseManager;

  final _log = const Log("DataManager");
  final AppManager _appManager;

  late Database _database;
  var _initialized = false;

  LocalDatabaseManager(this._appManager);

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  Future<void> initialize({
    Database? database,
  }) async {
    // Use an initialized flag here because Dart doesn't have a way to check if
    // a late variable has been initialized, and null isn't a valid value for
    // _database.
    if (_initialized) {
      await _database.close();
    }
    _database = database ?? (await openDb());
    _initialized = true;
  }

  Future<void> closeAndDeleteDatabase() async {
    await _database.close();
    await deleteDb();
  }

  /// Closes and deletes the current database. Then, creates a new one, opens it,
  /// and re-initializes [AppManager].
  Future<void> resetDatabase() async {
    await closeAndDeleteDatabase();
    _database = await openDb();
    await _appManager.initialize(isStartup: false);
  }

  String databasePath() => _database.path;

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
  Future<bool> insertOrReplace(String tableName, Map<String, dynamic> values,
      [Batch? batch]) async {
    var conflict = ConflictAlgorithm.replace;

    if (batch == null) {
      return (await _database.insert(tableName, values,
              conflictAlgorithm: conflict)) >
          0;
    } else {
      batch.insert(tableName, values, conflictAlgorithm: conflict);
      return true;
    }
  }

  /// Returns `true` if at least one row was removed.
  Future<bool> delete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _database.delete(table, where: where, whereArgs: whereArgs) >
        0;
  }

  /// Allows a raw query to be sent to the database.
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? args]) {
    return _database.rawQuery(sql, args);
  }

  Future<bool> rawExists(String query, [List<dynamic>? args]) async {
    return Sqflite.firstIntValue(await _database.rawQuery(query, args))
            as FutureOr<bool>? ??
        0 > 0;
  }

  Future<bool> rawUpdate(String query, [List<dynamic>? args]) async {
    return await _database.rawUpdate(query, args) > 0;
  }

  /// Deletes a given [Entity] from the given [tableName].
  Future<bool> deleteEntity(Id entityId, String tableName,
      [Batch? batch]) async {
    // For details on the hex requirement, see
    // https://github.com/tekartik/sqflite/issues/608.
    var id = entityId.uint8List;
    var where = _ioWrapper.isAndroid ? "hex(id) = ?" : "id = ?";
    var whereArgs = [_ioWrapper.isAndroid ? hex(id) : id];

    if (batch == null) {
      if (await delete(tableName, where: where, whereArgs: whereArgs)) {
        return true;
      } else {
        _log.e(
            StackTrace.current,
            "Failed to delete $tableName(${entityId.uuid.toString()})"
            " from database");
        return false;
      }
    }

    batch.delete(tableName, where: where, whereArgs: whereArgs);
    return true;
  }

  Future<List<Map<String, dynamic>>> fetchAll(String tableName) async {
    return await query("SELECT * FROM $tableName");
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

  Future<void> commitTransaction(void Function(Batch) updateBatch) async {
    await _database.transaction((txn) async {
      var batch = txn.batch();
      updateBatch(batch);
      await batch.commit(noResult: true);
    });
  }
}
