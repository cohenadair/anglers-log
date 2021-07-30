import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/protobuf_utils.dart';

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

  String customValuesDisplayValue(
      List<CustomEntityValue> values, BuildContext context) {
    return values.fold<String>("", (value, item) {
      var entity = this.entity(item.customEntityId);
      if (entity == null) {
        return value;
      }

      value += "${entity.name}: "
          "${valueForCustomEntityType(entity.type, item, context)}";

      if (item != values.last) {
        value += ", ";
      }

      return value;
    });
  }
}
