import 'dart:async';
import 'dart:io';

import 'package:mobile/log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Log _log = Log("SQLiteOpenHelper");

final String _name = "anglerslog.db";

final List<String> _schema0 = [
  """
  CREATE TABLE fishing_spot ( 
    id BLOB PRIMARY KEY, 
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE bait_category (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE bait (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE species (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE catch (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE custom_entity (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE preference (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );
  """,
  """
  CREATE TABLE summary_report (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
  """
  CREATE TABLE comparison_report (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<List<String>> _schema = [
  _schema0,
];

final int _version = 1;

Future<String> get _databasePath async => join(await getDatabasesPath(), _name);

Future<Database> openDb() async {
  String path = await _databasePath;
  _log.d(path);
  return openDatabase(
    path,
    version: _version,
    onCreate: _onCreateDatabase,
    onUpgrade: _onUpgradeDatabase,
  );
}

/// Deletes and recreates the database from scratch.
Future<Database> resetDb() async {
  File(await _databasePath).deleteSync();
  return openDb();
}

void _onCreateDatabase(Database db, int version) {
  _schema.forEach((List<String> schema) => _executeSchema(db, schema));
}

void _onUpgradeDatabase(Database db, int oldVersion, int newVersion) {
  for (int version = oldVersion; version < newVersion; ++version) {
    if (version >= _schema.length) {
      throw ArgumentError("Invalid database version: $newVersion");
    }
    _executeSchema(db, _schema[version]);
    _log.d("Upgraded database to version ${version + 1}");
  }
}

void _executeSchema(Database db, List<String> schema) {
  schema.forEach((String query) => db.execute(query));
}