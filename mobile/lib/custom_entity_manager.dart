import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:mobile/named_entity_manager.dart';

import 'app_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'utils/protobuf_utils.dart';

class CustomEntityManager extends NamedEntityManager<CustomEntity> {
  static CustomEntityManager of(BuildContext context) =>
      AppManager.get.customEntityManager;

  CustomEntityManager(super.app);

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
    List<CustomEntityValue> values,
    BuildContext context,
  ) {
    var result = <String>[];
    for (var value in values) {
      var entity = this.entity(value.customEntityId);
      if (entity == null) {
        continue;
      }

      result.add(
        "${entity.name}: "
        "${valueForCustomEntityType(entity.type, value, context)}",
      );
    }

    return formatList(result);
  }
}
