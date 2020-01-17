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
}