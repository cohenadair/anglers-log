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
  """
  CREATE TABLE custom_entity (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    type INTEGER
  );
  """,
  """
  CREATE TABLE preference (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );
  """,
  """
  CREATE TABLE custom_entity_value (
    entity_id TEXT NOT NULL,
    custom_entity_id TEXT NOT NULL,
    value TEXT NOT NULL,
    entity_type INTEGER NOT NULL,
    PRIMARY KEY (entity_id, custom_entity_id)
  );
  """,
  """
  CREATE TABLE custom_summary_report (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    entity_type INTEGER NOT NULL,
    display_date_range_id TEXT NOT NULL,
    start_timestamp INTEGER,
    end_timestamp INTEGER
  );
  """,
  """
  CREATE TABLE custom_comparison_report (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    entity_type INTEGER NOT NULL,
    from_display_date_range_id TEXT NOT NULL,
    from_start_timestamp INTEGER,
    from_end_timestamp INTEGER,
    to_display_date_range_id TEXT NOT NULL,
    to_start_timestamp INTEGER,
    to_end_timestamp INTEGER
  );
  """,
  """
  CREATE TABLE custom_report_species (
    custom_report_id TEXT NOT NULL,
    species_id TEXT NOT NULL,
    PRIMARY KEY (custom_report_id, species_id)
  );
  """,
  """
  CREATE TABLE custom_report_bait (
    custom_report_id TEXT NOT NULL,
    bait_id TEXT NOT NULL,
    PRIMARY KEY (custom_report_id, bait_id)
  );
  """,
  """
  CREATE TABLE custom_report_fishing_spot (
    custom_report_id TEXT NOT NULL,
    fishing_spot_id TEXT NOT NULL,
    PRIMARY KEY (custom_report_id, fishing_spot_id)
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