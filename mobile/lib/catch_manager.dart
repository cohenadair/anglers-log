import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:provider/provider.dart';

class CatchManager extends EntityManager<Catch> {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  static CatchManager _instance;
  factory CatchManager.get(AppManager app) {
    if (_instance == null) {
      _instance = CatchManager._internal(app);
    }
    return _instance;
  }
  CatchManager._internal(AppManager app) : super(app);

  /// Returns all catches, sorted from newest to oldest.
  List<Catch> get entityListSortedByTimestamp {
    List<Catch> result = List.of(entities.values);
    result.sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp));
    return result;
  }

  @override
  Catch entityFromMap(Map<String, dynamic> map) => Catch.fromMap(map);

  @override
  String get tableName => "catch";
}