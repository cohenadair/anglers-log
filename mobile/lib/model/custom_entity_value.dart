import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:quiver/strings.dart';

/// A data structure that stores a value of a particular [CustomEntity] object
/// when included in other [Entity] objects, such as a [Catch].
@immutable
class CustomEntityValue {
  /// Converts the given [keyValues] map into a list of [CustomEntityValue]
  /// objects associated with the given [entityId].
  static List<CustomEntityValue> listFromIdValueMap(String entityId,
      EntityType entityType, Map<String, dynamic> keyValues)
  {
    List<CustomEntityValue> result = [];

    for (var entry in keyValues.entries) {
      if (entry.value == null
          || (entry.value is String && isEmpty(entry.value)))
      {
        continue;
      }

      result.add(CustomEntityValue(
        entityId: entityId,
        customEntityId: entry.key,
        textValue: entry.value.toString(),
        entityType: entityType,
      ));
    }

    return result;
  }

  static const keyEntityId = "entity_id";
  static const keyCustomEntityId = "custom_entity_id";
  static const keyValue = "value";
  static const keyEntityType = "entity_type";

  final String entityId;
  final String customEntityId;
  final String textValue;
  final EntityType entityType;

  CustomEntityValue({
    @required this.entityId,
    @required this.customEntityId,
    @required this.textValue,
    @required this.entityType,
  }) : assert(isNotEmpty(entityId)),
       assert(isNotEmpty(customEntityId)),
       assert(isNotEmpty(textValue)),
       assert(entityType != null);

  CustomEntityValue.fromMap(Map<String, dynamic> map) : this(
    entityId: map[keyEntityId],
    customEntityId: map[keyCustomEntityId],
    textValue: map[keyValue],
    entityType: EntityType.values[map[keyEntityType]],
  );

  Map<String, dynamic> toMap() => {
    keyEntityId: entityId,
    keyCustomEntityId: customEntityId,
    keyValue: textValue,
    keyEntityType: entityType.index,
  };

  dynamic valueFromInputType(InputType type) {
    switch (type) {
      case InputType.text:
        // Fallthrough.
      case InputType.number: return textValue;
      case InputType.boolean: return boolValue;
    }
  }

  bool get boolValue {
    int intBool = int.tryParse(textValue);
    if (intBool == null) {
      return false;
    } else {
      return intBool == 1 ? true : false;
    }
  }

  double get numberValue {
    return double.tryParse(textValue);
  }

  @override
  String toString() => toMap().toString();
}