import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DataManager {
  static DataManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).dataManager;

  static final DataManager _instance = DataManager._internal();
  factory DataManager.get() => _instance;
  DataManager._internal();

  Database _database;

  Future<void> initialize(AppManager app, [Database database]) async {
    if (database == null) {
      _database = await openDb();
    } else {
      _database = database;
    }
  }

  /// Returns `true` if values were successfully added.
  Future<bool> insert(String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values) > 0;
  }

  /// Returns `true` if at least one row was removed.
  Future<bool> delete(String sql, [List<dynamic> args]) async {
    return await _database.rawDelete(sql, args) > 0;
  }

  /// Returns `true` if the row from the given table with the given ID was
  /// updated.
  Future<bool> updateId(String tableName, String id,
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

  Future<bool> exists(String sql, [List<dynamic> args]) async {
    return Sqflite.firstIntValue(await _database.rawQuery(sql, args)) == 1;
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