import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../log.dart';

const _log = Log("SQLiteOpenHelper");

const String _name = "anglerslog.db";

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
  CREATE TABLE user_preference (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );
  """,
  """
  CREATE TABLE app_preference (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );
  """,
  """
  CREATE TABLE custom_report (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema1 = [
  """
  CREATE TABLE angler (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema2 = [
  """
  CREATE TABLE method (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema3 = [
  """
  CREATE TABLE water_clarity (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema4 = [
  """
  CREATE TABLE body_of_water (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema5 = [
  """
  CREATE TABLE trip (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema6 = [
  """
  CREATE TABLE gps_trail (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<String> _schema7 = [
  """
  CREATE TABLE gear (
    id BLOB PRIMARY KEY,
    bytes BLOB NOT NULL
  );
  """,
];

final List<List<String>> _schema = [
  _schema0,
  _schema1,
  _schema2,
  _schema3,
  _schema4,
  _schema5,
  _schema6,
  _schema7,
];

const int _version = 8;

Future<String> _databasePath() async =>
    join(await getDatabasesPath(), "2.0", _name);

Future<Database> openDb() async {
  var path = await _databasePath();

  if (await File(path).exists()) {
    _log.d("Database exists: $path");
  } else {
    _log.d("Database does not exist: $path");
  }

  return openDatabase(
    path,
    version: _version,
    onCreate: _onCreateDatabase,
    onUpgrade: _onUpgradeDatabase,
  );
}

Future<void> deleteDb() async {
  var file = File(await _databasePath());
  if (await file.exists()) {
    _log.d("Deleting database");
    await file.delete();
  }
}

void _onCreateDatabase(Database db, int version) {
  for (var schema in _schema) {
    _executeSchema(db, schema);
  }
}

void _onUpgradeDatabase(Database db, int oldVersion, int newVersion) {
  for (var version = oldVersion; version < newVersion; ++version) {
    if (version >= _schema.length) {
      throw ArgumentError("Invalid database version: $newVersion");
    }
    _executeSchema(db, _schema[version]);
    _log.d("Upgraded database to version ${version + 1}");
  }
}

void _executeSchema(Database db, List<String> schema) {
  for (var query in schema) {
    db.execute(query);
  }
}
