import 'package:flutter/cupertino.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:quiver/strings.dart';

int entityValuesCount<T>(List<T> entities, Id customEntityId,
    List<CustomEntityValue> Function(T) getValues)
{
  int result = 0;
  for (T entity in entities) {
    List<CustomEntityValue> values = getValues(entity) ?? [];
    if (values.isNotEmpty) {
      for (CustomEntityValue value in values) {
        if (Id(value.customEntityId) == customEntityId) {
          result++;
        }
      }
    }
  }
  return result;
}

bool entityValuesMatchesFilter(List<CustomEntityValue> values, String filter,
    CustomEntityManager customEntityManager)
{
  values = values ?? [];
  if (values.isEmpty) {
    return false;
  }

  for (CustomEntityValue value in values) {
    if (customEntityManager.matchesFilter(Id(value.customEntityId), filter)
        || isEmpty(value.value)
        || value.value.toLowerCase().contains(filter.toLowerCase()))
    {
      return true;
    }
  }

  return false;
}

/// Converts the given [keyValues] map into a list of [CustomEntityValue]
/// objects.
List<CustomEntityValue> entityValuesFromMap(Map<Id, dynamic> keyValues) {
  List<CustomEntityValue> result = [];

  for (var entry in keyValues.entries) {
    if (entry.value == null
        || (entry.value is String && isEmpty(entry.value)))
    {
      continue;
    }

    result.add(CustomEntityValue()
      ..customEntityId = entry.key.bytes
      ..value = entry.value.toString());
  }

  return result;
}

dynamic valueForCustomEntityType(CustomEntity_Type type,
    CustomEntityValue value, [BuildContext context])
{
  var value;
  switch (type) {
    case CustomEntity_Type.NUMBER:
    // Fallthrough.
    case CustomEntity_Type.TEXT:
      return value.value;
    case CustomEntity_Type.BOOL:
      bool boolValue = parseBool(value.value);
      if (context == null) {
        return boolValue;
      } else {
        return boolValue ? Strings.of(context).yes : Strings.of(context).no;
      }
  }
}

extension Timestamps on Timestamp {
  static Timestamp fromMillis(int millisSinceEpoch) => Timestamp.fromDateTime(
      DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch));

  int compareTo(Timestamp other) => toDateTime().compareTo(other.toDateTime());

  int get ms => toDateTime().millisecondsSinceEpoch;
}