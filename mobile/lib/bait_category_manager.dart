import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

class BaitCategoryManager extends NamedEntityManager<BaitCategory> {
  static BaitCategoryManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitCategoryManager;

  BaitCategoryManager(AppManager app) : super(app);

  @override
  BaitCategory entityFromMap(Map<String, dynamic> map) =>
      BaitCategory.fromMap(map);

  @override
  String get tableName => "bait_category";
}