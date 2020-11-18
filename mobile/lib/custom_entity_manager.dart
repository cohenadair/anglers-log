import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

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
