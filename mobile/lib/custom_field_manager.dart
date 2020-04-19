import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'model/custom_entity.dart';

class CustomFieldManager extends NamedEntityManager<CustomEntity> {
  static CustomFieldManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customFieldManager;

  static CustomFieldManager _instance;
  factory CustomFieldManager.get(AppManager app) {
    if (_instance == null) {
      _instance = CustomFieldManager._internal(app);
    }
    return _instance;
  }
  CustomFieldManager._internal(AppManager app) : super(app);

  @override
  CustomEntity entityFromMap(Map<String, dynamic> map) =>
      CustomEntity.fromMap(map);

  @override
  String get tableName => "custom_entity";
}