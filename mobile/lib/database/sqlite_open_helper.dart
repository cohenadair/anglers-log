import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String _name = "anglerslog.db";
final int _version = 1;

final List<String> _schema0 = [
  """
  CREATE TABLE fishing_spot (
    id TEXT PRIMARY KEY,
    lat DOUBLE UNIQUE NOT NULL,
    lng DOUBLE UNIQUE NOT NULL,
    name TEXT DEFAULT NULL
  );
  """,
];

final List<List<String>> _schema = [
  _schema0,
];

Future<Database> openDb() async {
  String path = join(await getDatabasesPath(), _name);
  print(path.toString());
  return openDatabase(
    path,
    version: _version,
    onCreate: _onCreateDatabase,
    onUpgrade: _onUpgradeDatabase,
  );
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
  }
}

void _executeSchema(Database db, List<String> schema) {
  schema.forEach((String query) => db.execute(query));
}