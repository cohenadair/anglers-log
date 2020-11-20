import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class CustomEntityManager extends NamedEntityManager<CustomEntity> {
  static CustomEntityManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customEntityManager;

  CustomEntityManager(AppManager app) : super(app);

  @override
  CustomEntity entityFromBytes(List<int> bytes) =>
      CustomEntity.fromBuffer(bytes);

  @override
  Id id(CustomEntity entity) => entity.id;

  @override
  String name(CustomEntity entity) => entity.name;

  @override
  String get tableName => "custom_entity";
}
