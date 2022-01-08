import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

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

  /// Returns a user-facing value of [values], separated using [formatList].
  /// Each item includes [CustomEntity.name] and [CustomEntityValue.value]. If
  /// an item in [values] isn't associated with an existing [CustomEntity], it
  /// is excluded from the result.
  String customValuesDisplayValue(
      List<CustomEntityValue> values, BuildContext context) {
    var result = <String>[];
    for (var value in values) {
      var entity = this.entity(value.customEntityId);
      if (entity == null) {
        continue;
      }

      result.add("${entity.name}: "
          "${valueForCustomEntityType(entity.type, value, context)}");
    }

    return formatList(result);
  }
}
