import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitCategoryManager;

  static BaitCategoryManager _instance;
  factory BaitCategoryManager.get(AppManager app) {
    if (_instance == null) {
      _instance = BaitCategoryManager._internal(app);
    }
    return _instance;
  }
  BaitCategoryManager._internal(AppManager app) : super(app);

  @override
  BaitCategory entityFromMap(Map<String, dynamic> map) =>
      BaitCategory.fromMap(map);

  @override
  String get tableName => "bait_category";
}