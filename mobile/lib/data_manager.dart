import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

class DataManager {
  static DataManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).dataManager;

  static final DataManager _instance = DataManager._internal();
  factory DataManager.get() => _instance;
  DataManager._internal();

  final Log _log = Log("DataManager");

  Database _database;

  Future<void> initialize(AppManager app, [Database database]) async {
    if (database == null) {
      _database = await openDb();
    } else {
      _database = database;
    }
  }

  /// Returns `true` if values were successfully added.
  Future<bool> _insert(String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values) > 0;
  }

  /// Returns `true` if at least one row was removed.
  Future<bool> _delete(String sql, [List<dynamic> args]) async {
    return await _database.rawDelete(sql, args) > 0;
  }

  /// Returns `true` if the row from the given table with the given ID was
  /// updated.
  Future<bool> _updateId(String tableName, String id,
      Map<String, dynamic> values) async
  {
    return await _database.update(
      tableName,
      values,
      where: "id = ?",
      whereArgs: [id],
    ) > 0;
  }

  /// Allows a raw query to be sent to the database.
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic> args]) {
    return _database.rawQuery(sql, args);
  }

  Future<int> count(String tableName) async {
    return Sqflite.firstIntValue(
        await _database.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  /// Returns true if the given ID exists in the given table; false otherwise.
  Future<bool> _idExists(String tableName, String id) async {
    return exists(tableName, "id", id);
  }

  Future<bool> exists(String tableName, String columnName, dynamic value) async
  {
    return Sqflite.firstIntValue(await _database
        .rawQuery("SELECT COUNT(*) FROM $tableName WHERE $columnName = ?",
            [value])) > 0;
  }

  /// Inserts a new [Entity] into the given [tableName] or updates the existing
  /// [Entity] if one with the same ID already exists.
  ///
  /// If the given [VoidStreamController] is not `null`, its `notify()` method
  /// is called if the [Entity] is successfully updated or inserted.
  void insertOrUpdateEntity(Entity entity, String tableName, {
    VoidStreamController controller,
  }) async {
    if (await _idExists(tableName, entity.id)) {
      // Update if entity with ID already exists.
      if (await _updateId(tableName, entity.id, entity.toMap())) {
        controller?.notify();
      } else {
        _log.e("Failed to update $tableName(${entity.id}");
      }
    } else {
      // Otherwise, create new entity.
      if (await _insert(tableName, entity.toMap())) {
        controller?.notify();
      } else {
        _log.e("Failed to insert $tableName(${entity.id}");
      }
    }
  }

  /// Deletes a given [Entity] from the given [tableName].
  ///
  /// If the given [VoidStreamController] is not `null`, its `notify()` method
  /// is called if the [Entity] is successfully deleted.
  void deleteEntity(Entity entity, String tableName, {
    VoidStreamController controller,
  }) async {
    if (await _delete("DELETE FROM $tableName WHERE id = ?", [entity.id])) {
      controller?.notify();
    } else {
      _log.e("Failed to delete $tableName(${entity.id} from database");
    }
  }

  /// Result is sorted alphabetically by [Entity.name].
  Future<List<Map<String, dynamic>>> fetchAllEntities(String tableName, {
    String searchText,
  }) async {
    _log.w("fetchAll($tableName, searchText: $searchText) called");

    List<Map<String, dynamic>> results;
    if (isEmpty(searchText)) {
      results = await
      query("SELECT * FROM $tableName ORDER BY name");
    } else {
      results = await search(tableName, "name", searchText);
    }

    return results;
  }

  Future<Map<String, dynamic>> fetchEntity(String tableName, String id) async {
    _log.w("fetch($tableName, $id) called");

    List<Map<String, dynamic>> result =
        await query("SELECT * FROM $tableName WHERE id = ?", [id]);
    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  /// Runs a basic search on the given table and column. The given [searchText]
  /// is used as an entire term, and split, per word, into search tokens.
  /// Returns rows whose [column] value contains [searchText] or at least one
  /// of the tokens.
  Future<List<Map<String, dynamic>>> search(String table, String column,
      String searchText) async
  {
    String query = "SELECT * FROM $table WHERE $column LIKE '%$searchText%'";
    List<String> tokens = searchText.split(" ");
    if (tokens.length > 1) {
      for (var token in tokens) {
        query += " OR $column LIKE '%$token%'";
      }
    } else {
      tokens = [];
    }
    query += " ORDER BY $column";

    return await _database.rawQuery(query, [searchText]..addAll(tokens));
  }
}