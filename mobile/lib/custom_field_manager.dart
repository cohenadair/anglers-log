import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'model/custom_entity.dart';

class CustomFieldManager extends NamedEntityManager<CustomEntity> {
  static CustomFieldManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customFieldManager;

  CustomFieldManager(AppManager app) : super(app);

  @override
  CustomEntity entityFromMap(Map<String, dynamic> map) =>
      CustomEntity.fromMap(map);

  @override
  String get tableName => "custom_entity";
}