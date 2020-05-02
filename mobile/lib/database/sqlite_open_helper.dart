import 'dart:async';

import 'package:mobile/log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final Log _log = Log("SQLiteOpenHelper");

final String _name = "anglerslog.db";

final List<String> _schema0 = [
  """
  CREATE TABLE fishing_spot ( 
    id TEXT PRIMARY KEY, 
    lat DOUBLE NOT NULL, 
    lng DOUBLE NOT NULL, 
    name TEXT DEFAULT NULL,
    CONSTRAINT unique_coordinates UNIQUE (lat, lng)
  );
  """,
  """
  CREATE TABLE bait_category (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
  );
  """,
  """
  CREATE TABLE bait (
    id TEXT PRIMARY KEY,
    base_id TEXT,
    category_id TEXT,
    name TEXT,
    photo_id TEXT,
    color TEXT,
    model TEXT,
    size TEXT,
    type INTEGER,
    min_dive_depth double,
    max_dive_depth double,
    description TEXT
  );
  """,
  """
  CREATE TABLE species (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
  );
  """,
  """
  CREATE TABLE catch (
    id TEXT PRIMARY KEY,
    timestamp INTEGER NOT NULL,
    fishing_spot_id TEXT,
    bait_id TEXT,
    species_id TEXT
  );
  """,
  """
  CREATE TABLE entity_image (
    entity_id TEXT NOT NULL,
    image_name TEXT NOT NULL,
    PRIMARY KEY (entity_id, image_name)
  );
  """,
];

final List<List<String>> _schema = [
  _schema0,
];

final int _version = 1;

Future<Database> openDb() async {
  String path = join(await getDatabasesPath(), _name);
  _log.d(path.toString());
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
    _log.d("Upgraded database to version ${version + 1}");
  }
}

void _executeSchema(Database db, List<String> schema) {
  schema.forEach((String query) => db.execute(query));
}