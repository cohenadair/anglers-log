import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../utils/string_utils.dart';

/// Returns the number of occurrences of [customEntityId] in [entities].
int entityValuesCount<T>(List<T> entities, Id customEntityId,
    List<CustomEntityValue> Function(T) getValues) {
  var result = 0;
  for (var entity in entities) {
    var values = getValues(entity);
    if (values.isNotEmpty) {
      for (var value in values) {
        if (value.customEntityId == customEntityId) {
          result++;
        }
      }
    }
  }
  return result;
}

bool entityValuesMatchesFilter(List<CustomEntityValue> values, String? filter,
    CustomEntityManager customEntityManager) {
  if (isEmpty(filter)) {
    return true;
  }

  for (var value in values) {
    if (customEntityManager.matchesFilter(value.customEntityId, filter) ||
        (isNotEmpty(value.value) &&
            value.value.toLowerCase().contains(filter!.toLowerCase()))) {
      return true;
    }
  }

  return false;
}

/// Converts the given [keyValues] map into a list of [CustomEntityValue]
/// objects.
List<CustomEntityValue> entityValuesFromMap(Map<Id, dynamic>? keyValues) {
  if (keyValues == null) {
    return [];
  }

  var result = <CustomEntityValue>[];

  for (var entry in keyValues.entries) {
    if (entry.value == null ||
        (entry.value is String && isEmpty(entry.value))) {
      continue;
    }

    result.add(CustomEntityValue()
      ..customEntityId = entry.key
      ..value = entry.value.toString());
  }

  return result;
}

dynamic valueForCustomEntityType(
    CustomEntity_Type type, CustomEntityValue value,
    [BuildContext? context]) {
  switch (type) {
    case CustomEntity_Type.number:
    // Fallthrough.
    case CustomEntity_Type.text:
      return value.value;
    case CustomEntity_Type.boolean:
      var boolValue = parseBoolFromInt(value.value);
      if (context == null) {
        return boolValue;
      } else {
        return boolValue ? Strings.of(context).yes : Strings.of(context).no;
      }
  }
}

String nameForPeriod(BuildContext context, Period period) {
  switch (period) {
    case Period.all:
      return Strings.of(context).all;
    case Period.none:
      return Strings.of(context).none;
    case Period.dawn:
      return Strings.of(context).periodDawn;
    case Period.morning:
      return Strings.of(context).periodMorning;
    case Period.midday:
      return Strings.of(context).periodMidday;
    case Period.afternoon:
      return Strings.of(context).periodAfternoon;
    case Period.dusk:
      return Strings.of(context).periodDusk;
    case Period.night:
      return Strings.of(context).periodNight;
  }
  throw ArgumentError("Invalid input: $period");
}

Set<Period> selectablePeriods() {
  return {
    Period.dawn,
    Period.morning,
    Period.midday,
    Period.afternoon,
    Period.dusk,
    Period.night,
  };
}

List<PickerPageItem<Period>> pickerItemsForPeriod(BuildContext context) {
  return selectablePeriods().map((period) {
    return PickerPageItem<Period>(
      title: nameForPeriod(context, period),
      value: period,
    );
  }).toList();
}

Id randomId() => Id()..uuid = Uuid().v4();

/// Parses [idString] into an [Id] object. Throws an [AssertionError] if
/// [idString] is null or empty, or if [idString] isn't a valid UUID.
Id parseId(String idString) {
  assert(isNotEmpty(idString));

  var uuid = Uuid.unparse(Uuid.parse(idString));
  if (uuid == Uuid.NAMESPACE_NIL) {
    throw ArgumentError("Input String is not a valid UUID: $idString");
  }

  return Id()..uuid = uuid;
}

Id? safeParseId(String idString) {
  try {
    return parseId(idString);
  } on Exception catch (_) {
    return null;
  }
}

extension Ids on Id {
  List<int> get bytes => Uuid.parse(uuid);
  Uint8List get uint8List => Uint8List.fromList(bytes);
}

extension FishingSpots on FishingSpot {
  LatLng get latLng => LatLng(lat, lng);

  /// Returns [name] if it is not empty, otherwise returns the
  /// spot's coordinates as a string in the format provided by [formatLatLng].
  String displayName(
    BuildContext context, {
    bool includeLatLngLabels = true,
  }) {
    if (isNotEmpty(name)) {
      return name;
    }
    return formatLatLng(
      context: context,
      lat: lat,
      lng: lng,
      includeLabels: includeLatLngLabels,
    );
  }
}
