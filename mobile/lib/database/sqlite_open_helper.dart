import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../log.dart';

final _log = Log("SQLiteOpenHelper");

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

final List<List<String>> _schema = [
  _schema0,
  _schema1,
  _schema2,
];

final int _version = 3;

Future<String> _databasePath(String userId) async =>
    join(await (getDatabasesPath() as FutureOr<String>), "2.0", userId, _name);

Future<Database> openDb(String userId) async {
  var path = await _databasePath(userId);

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
