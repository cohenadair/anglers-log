import "dart:math" as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/utils/bool_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/fraction.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/map_utils.dart' as map_utils;
import '../utils/string_utils.dart';
import '../widgets/multi_measurement_input.dart';
import 'catch_utils.dart';
import 'date_time_utils.dart';
import 'number_utils.dart';

const _log = Log("ProtobufUtils");

// TODO: Move these CustomEntityValue functions to CustomEntityManager.

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

bool filterMatchesEntityValues(
  List<CustomEntityValue> values,
  BuildContext context,
  String? filter,
  CustomEntityManager customEntityManager,
) {
  if (isEmpty(filter)) {
    return true;
  }

  for (var value in values) {
    if (customEntityManager.matchesFilter(
            value.customEntityId, context, filter) ||
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
      var boolValue = compareAsciiLowerCase(value.value, "true") == 0;
      return context == null ? boolValue : boolValue.displayValue(context);
  }
}

Id randomId() => Id()..uuid = const Uuid().v4();

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

/// Returns true if [item] exists in [items], where if [item] is of type
/// [GeneratedMessage], only the [id] property is checked. For more details
/// see [indexOfEntityIdOrOther].
bool containsEntityIdOrOther(Iterable iterable, dynamic item) {
  return indexOfEntityIdOrOther(iterable.toList(), item) >= 0;
}

/// Returns the index of [item] in [items], or -1 if it doesn't exist.
///
/// All protobuf entity objects include an [id] property. Protobuf doesn't have
/// inheritance, though, so we can't use a parent or abstract class with an [id]
/// property. Instead, we explicitly access the [id] property of [item]. If
/// [item] doesn't have an [id] property, [List.indexOf] is returned.
///
/// Note that all protobuf objects override [==] such that deep comparisons
/// work. This method is different in that it only compares objects' [id]
/// property. It is useful for matching items whose fields may have changed,
/// such as being edited by the user.
///
/// This method will throw an exception if [item] is of type [GeneratedMessage],
/// but does not have an [id] property.
int indexOfEntityIdOrOther(List<dynamic> list, dynamic item) {
  if (item is! GeneratedMessage) {
    return list.indexOf(item);
  }

  for (var i = 0; i < list.length; i++) {
    // For non-GeneratedMessage objects in list, use ==.
    if (list[i] is! GeneratedMessage) {
      if (list[i] == item) {
        return i;
      }
      continue;
    }

    if (list[i].id == (item as dynamic).id) {
      return i;
    }
  }

  return -1;
}

Set<T> _selectable<T>(List<T> values, List<T> excludeValues) {
  return Set.of(values)..removeWhere((value) => excludeValues.contains(value));
}

List<PickerPageItem<T>> _pickerItems<T>(
  BuildContext context,
  List<T> values,
  List<T> excludeValues,
  String Function(BuildContext, T) displayName, {
  bool sort = true,
}) {
  var modifiedList = _selectable(values, excludeValues).toList();

  if (sort) {
    modifiedList.sort((rhs, lhs) =>
        displayName(context, rhs).compareTo(displayName(context, lhs)));
  }

  return modifiedList.map((value) {
    return PickerPageItem<T>(
      title: displayName(context, value),
      value: value,
    );
  }).toList();
}

extension Atmospheres on Atmosphere {
  TZDateTime sunriseDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(sunriseTimestamp.toInt(), timeZone);

  TZDateTime sunsetDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(sunsetTimestamp.toInt(), timeZone);

  String displaySunriseTimestamp(BuildContext context) =>
      formatTimeMillis(context, sunriseTimestamp, timeZone);

  String displaySunsetTimestamp(BuildContext context) =>
      formatTimeMillis(context, sunsetTimestamp, timeZone);

  bool matchesFilter(BuildContext context, String? filter) {
    if (isEmpty(filter)) {
      return false;
    }

    var searchString = "";

    if (hasTemperature()) {
      searchString += " ${temperature.displayValue(context)}";
      searchString += " ${temperature.filterString(context)}";
    }

    if (hasWindSpeed()) {
      searchString += " ${windSpeed.displayValue(context)}";
      searchString += " ${windSpeed.filterString(context)}";
    }

    if (hasPressure()) {
      searchString += " ${pressure.displayValue(context)}";
      searchString += " ${pressure.filterString(context)}";
    }

    if (hasVisibility()) {
      searchString += " ${visibility.displayValue(context)}";
      searchString += " ${visibility.filterString(context)}";
    }

    if (skyConditions.isNotEmpty) {
      searchString += " ${skyConditions.join(" ")}";
    }

    if (hasWindDirection()) {
      searchString += " ${windDirection.filterString(context)}";
      searchString += " ${Strings.of(context).keywordsWindDirection}";
    }

    if (hasHumidity()) {
      searchString += " ${humidity.filterString(context)}";
      searchString += " ${Strings.of(context).keywordsAirHumidity}";
    }

    if (hasMoonPhase()) {
      searchString += " ${moonPhase.displayName(context)}";
      searchString += " ${Strings.of(context).keywordsMoon}";
    }

    if (hasSunsetTimestamp()) {
      searchString += " ${Strings.of(context).keywordsSunset}";
    }

    if (hasSunriseTimestamp()) {
      searchString += " ${Strings.of(context).keywordsSunrise}";
    }

    return containsTrimmedLowerCase(searchString, filter!);
  }

  bool hasDeprecations() {
    return hasTemperatureDeprecated() ||
        hasWindSpeedDeprecated() ||
        hasPressureDeprecated() ||
        hasHumidityDeprecated() ||
        hasVisibilityDeprecated();
  }

  void clearDeprecations(UserPreferenceManager userPreferenceManager) {
    if (hasTemperatureDeprecated()) {
      temperature = MultiMeasurement(
        system: userPreferenceManager.airTemperatureSystem,
        mainValue: temperatureDeprecated,
      );
      clearTemperatureDeprecated();
    }

    if (hasWindSpeedDeprecated()) {
      windSpeed = MultiMeasurement(
        system: userPreferenceManager.windSpeedSystem,
        mainValue: windSpeedDeprecated,
      );
      clearWindSpeedDeprecated();
    }

    if (hasPressureDeprecated()) {
      pressure = MultiMeasurement(
        system: userPreferenceManager.airPressureSystem,
        mainValue: pressureDeprecated,
      );
      clearPressureDeprecated();
    }

    if (hasHumidityDeprecated()) {
      humidity = MultiMeasurement(
        mainValue: humidityDeprecated,
      );
      clearHumidityDeprecated();
    }

    if (hasVisibilityDeprecated()) {
      visibility = MultiMeasurement(
        system: userPreferenceManager.airVisibilitySystem,
        mainValue: visibilityDeprecated,
      );
      clearVisibilityDeprecated();
    }
  }
}

extension Baits on Bait {
  BaitAttachment toAttachment() => BaitAttachment(baitId: id);
}

extension BaitAttachments on BaitAttachment {
  static BaitAttachment fromPbMapKey(String key) {
    var ids = key.split(".");
    for (var id in ids) {
      if (safeParseId(id) == null) {
        _log.w("Invalid protobuf map key: $key");
        return BaitAttachment();
      }
    }

    if (ids.length == 1) {
      return BaitAttachment(baitId: Id(uuid: ids[0]));
    } else if (ids.length == 2) {
      return BaitAttachment(
        baitId: Id(uuid: ids[0]),
        variantId: Id(uuid: ids[1]),
      );
    }

    _log.w("Invalid protobuf map key: $key");
    return BaitAttachment();
  }

  String toPbMapKey() =>
      "${baitId.uuid}${hasVariantId() ? ".${variantId.uuid}" : ""}";
}

extension BaitTypes on Bait_Type {
  String displayName(BuildContext context) {
    switch (this) {
      case Bait_Type.artificial:
        return Strings.of(context).baitTypeArtificial;
      case Bait_Type.real:
        return Strings.of(context).baitTypeReal;
      case Bait_Type.live:
        return Strings.of(context).baitTypeLive;
    }
    throw ArgumentError("Invalid input: $this");
  }

  String filterString(BuildContext context) => displayName(context);
}

extension BaitVariants on BaitVariant {
  BaitAttachment toAttachment() =>
      BaitAttachment(baitId: baseId, variantId: id);

  String? diveDepthDisplayValue(BuildContext context) {
    if (hasMinDiveDepth() && hasMaxDiveDepth()) {
      return "${minDiveDepth.displayValue(context)} - "
          "${maxDiveDepth.displayValue(context)}";
    } else if (hasMinDiveDepth()) {
      return minDiveDepth.displayValue(context);
    } else if (hasMaxDiveDepth()) {
      return maxDiveDepth.displayValue(context);
    } else {
      return null;
    }
  }
}

extension Catches on Catch {
  TZDateTime dateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(timestamp.toInt(), timeZone);

  String displayTimestamp(BuildContext context) =>
      formatTimestamp(context, timestamp.toInt(), timeZone);

  String dateTimeSearchString(BuildContext context) =>
      timestampToSearchString(context, timestamp.toInt(), timeZone);
}

extension Ids on Id {
  static bool isValid(Id? id) => id != null && isNotEmpty(id.uuid);

  static bool isNotValid(Id? id) => !isValid(id);

  List<int> get bytes => Uuid.parse(uuid);

  Uint8List get uint8List => Uint8List.fromList(bytes);
}

extension IdList on List<Id> {
  Iterable<String> toUuids() => map((e) => e.uuid);
}

extension FishingSpots on FishingSpot {
  LatLng get latLng => LatLng(lat, lng);
}

extension MeasurementSystems on MeasurementSystem {
  String displayName(BuildContext context) {
    switch (this) {
      case MeasurementSystem.imperial_whole:
        return Strings.of(context).measurementSystemImperial;
      case MeasurementSystem.imperial_decimal:
        return Strings.of(context).measurementSystemImperialDecimal;
      case MeasurementSystem.metric:
        return Strings.of(context).measurementSystemMetric;
    }
    throw ArgumentError("Invalid input: $this");
  }

  bool get isMetric => this == MeasurementSystem.metric;

  bool get isImperialWhole => this == MeasurementSystem.imperial_whole;

  Unit get lengthUnit => isMetric ? Unit.centimeters : Unit.inches;

  Unit get weightUnit => isMetric ? Unit.kilograms : Unit.pounds;

  Unit get heightUnit => isMetric ? Unit.meters : Unit.feet;
}

extension Measurements on Measurement {
  String displayValue(BuildContext context, [int? decimalPlaces]) {
    var unitString = "";
    if (hasUnit()) {
      unitString = "${unit.hasPreSpace ? " " : ""}"
          "${unit.shorthandDisplayName(context)}";
    }
    return unit.showsFirst
        ? "$unitString${stringValue(decimalPlaces)}"
        : "${stringValue(decimalPlaces)}$unitString";
  }

  String stringValue([int? decimalPlaces]) =>
      value.displayValue(decimalPlaces: decimalPlaces);

  String filterString(BuildContext context) =>
      "${displayValue(context)} ${unit.filterString(context)}";

  bool _unitsMatch(Measurement other) {
    if (hasUnit() && other.hasUnit() && unit != other.unit) {
      // This can legitimately happen if the user creates entities, then changes
      // units later.
      return false;
    }
    return true;
  }

  bool operator >(Measurement other) =>
      _unitsMatch(other) && value > other.value;

  bool operator >=(Measurement other) =>
      _unitsMatch(other) && value >= other.value;

  bool operator <(Measurement other) =>
      _unitsMatch(other) && value < other.value;

  bool operator <=(Measurement other) =>
      _unitsMatch(other) && value <= other.value;
}

extension MultiMeasurements on MultiMeasurement {
  /// Returns a [MultiMeasurement] object representing the average of
  /// [measurements] in the given unit. All items in [measurements] that aren't
  /// of the same unit will be converted.
  static MultiMeasurement? average(List<MultiMeasurement> measurements,
      MeasurementSystem system, Unit unit) {
    var values = _decimalValues(measurements, unit);
    return values.isEmpty
        ? null
        : unit.toMultiMeasurement(values.average, system);
  }

  /// Returns a [MultiMeasurement] object representing the maximum value of
  /// [measurements] in the given unit and system.
  static MultiMeasurement? max(List<MultiMeasurement> measurements,
      MeasurementSystem system, Unit unit) {
    var values = _decimalValues(measurements, unit);
    return values.isEmpty
        ? null
        : unit.toMultiMeasurement(values.reduce(math.max), system);
  }

  /// Returns a [MultiMeasurement] object representing the total value of
  /// [measurements] in the given unit.
  static MultiMeasurement? sum(List<MultiMeasurement> measurements,
      MeasurementSystem system, Unit unit) {
    var values = _decimalValues(measurements, unit);
    return values.isEmpty
        ? null
        : unit.toMultiMeasurement(
            values.reduce((total, e) => total += e), system);
  }

  /// Converts a collection of [MultiMeasurement] objects to a double, in
  /// [unit].
  static Iterable<double> _decimalValues(
      Iterable<MultiMeasurement> measurements, Unit unit) {
    if (measurements.isEmpty) {
      return [];
    }

    // Convert all values into decimals of the correct unit.
    var values = <double>[];
    for (var measurement in measurements) {
      var value = measurement._toDecimalIfNeeded();
      if (value.hasMainValue() && value.mainValue.hasValue()) {
        values
            .add(unit.convertFrom(value.mainValue.unit, value.mainValue.value));
      }
    }

    return values;
  }

  bool get isSet => hasMainValue() || hasFractionValue();

  /// Returns the user-visible value for the [MultiMeasurement].
  ///
  /// If [resultFormat] is not empty, it is returned with the value inserted.
  /// This method assumes [resultFormat] has one %s replacement.
  ///
  /// If [ifZero] is not empty, [ifZero] is returned if the calculated result
  /// == "0" (i.e. an empty protobuf object, or object without a unit).
  String displayValue(
    BuildContext context, {
    String? resultFormat,
    String? ifZero,
    bool includeFraction = true,
    int? mainDecimalPlaces,
  }) {
    String formatResult(String result) {
      if (isNotEmpty(resultFormat)) {
        result = format(resultFormat!, [result]);
      }

      // It's possible the main value is actually negative; in which case, an
      // additional dash is not needed.
      if (isNegative && !result.startsWith("-")) {
        result = "-$result";
      }

      return result;
    }

    // Inches require a different format than other measurements due to the
    // fraction not having its own unit. The different format only applies
    // when a fraction is set.
    var fraction = Fraction.fromValue(fractionValue.value);
    if (mainValue.hasUnit() &&
        mainValue.unit == Unit.inches &&
        fraction != Fraction.zero) {
      var unit = mainValue.unit.shorthandDisplayName(context);
      return formatResult(
          "${mainValue.stringValue()} ${fraction.symbol} $unit");
    }

    var result = "";
    if (hasMainValue()) {
      result += mainValue.displayValue(context, mainDecimalPlaces);
    }

    if (includeFraction &&
        hasFractionValue() &&
        fractionValue.hasValue() &&
        fractionValue.value > 0) {
      result +=
          "${hasMainValue() ? " " : ""}${fractionValue.displayValue(context)}";
    }

    if (isNotEmpty(ifZero) && (result == "0" || result.isEmpty)) {
      return formatResult(ifZero!);
    }

    return formatResult(result);
  }

  String filterString(BuildContext context) {
    var result = "";
    if (hasMainValue()) {
      result += " ${mainValue.filterString(context)}";
    }
    if (hasFractionValue()) {
      result += " ${fractionValue.filterString(context)}";
    }
    return result.trim();
  }

  /// Converts this [MultiMeasurement] to the given [MeasurementSystem] with
  /// [mainUnit]. All values are converted to their target units.
  MultiMeasurement convertToSystem(MeasurementSystem system, Unit mainUnit) {
    var decimal = _toDecimalIfNeeded();
    var converted =
        mainUnit.convertFrom(decimal.mainValue.unit, decimal.mainValue.value);
    return mainUnit.toMultiMeasurement(converted, system);
  }

  /// Converts this [MultiMeasurement] to the given [MultiMeasurement] system
  /// and units. Values are remained unchanged; however, whole fraction values
  /// (i.e. ounces) are converted to decimal and added to the main value where
  /// required.
  MultiMeasurement convertUnitsOnly(MultiMeasurement fromMeasurement) {
    var decimal = _toDecimalIfNeeded();
    return fromMeasurement.mainValue.unit
        .toMultiMeasurement(decimal.mainValue.value, fromMeasurement.system);
  }

  bool _compare(
    MultiMeasurement other, {
    bool checkEquals = false,
    required bool Function(Measurement, Measurement) comparator,
  }) {
    // Convert values to decimal for easy comparison.
    var lhs = _toDecimalIfNeeded();
    var rhs = other._toDecimalIfNeeded();

    if (checkEquals && lhs == rhs) {
      return true;
    }

    // Note that unit comparison is done in Measurement operator overrides, so
    // there's no need to do it here.
    return comparator(lhs.mainValue, rhs.mainValue);
  }

  MultiMeasurement _toDecimalIfNeeded() {
    if (system != MeasurementSystem.imperial_whole) {
      return this;
    }

    var result = deepCopy();
    result.system = MeasurementSystem.imperial_decimal;

    if (result.hasFractionValue() && result.fractionValue.hasValue()) {
      // Protobuf default values are immutable. Ensure a mutable version is
      // available, and has the correct unit.
      if (!result.hasMainValue()) {
        result.mainValue = Measurement();
        var mainUnit = result.fractionValue.unit.mainUnit;
        if (mainUnit != null) {
          result.mainValue.unit = mainUnit;
        }
      }

      result.mainValue.value = result.mainValue.value +
          result.fractionValue.unit.toDecimal(result.fractionValue.value);
      result.clearFractionValue();
    }

    return result;
  }

  int compareTo(MultiMeasurement other) {
    if (this < other) {
      return -1;
    } else if (this == other) {
      return 0;
    } else {
      return 1;
    }
  }

  bool operator <(MultiMeasurement other) {
    return _compare(
      other,
      comparator: (lhs, rhs) => lhs < rhs,
    );
  }

  bool operator <=(MultiMeasurement other) {
    return _compare(
      other,
      checkEquals: true,
      comparator: (lhs, rhs) => lhs <= rhs,
    );
  }

  bool operator >(MultiMeasurement other) {
    return _compare(
      other,
      comparator: (lhs, rhs) => lhs > rhs,
    );
  }

  bool operator >=(MultiMeasurement other) {
    return _compare(
      other,
      checkEquals: true,
      comparator: (lhs, rhs) => lhs >= rhs,
    );
  }
}

extension NumberBoundaries on NumberBoundary {
  String displayName(BuildContext context) {
    switch (this) {
      case NumberBoundary.number_boundary_any:
        return Strings.of(context).numberBoundaryAny;
      case NumberBoundary.less_than:
        return Strings.of(context).numberBoundaryLessThan;
      case NumberBoundary.less_than_or_equal_to:
        return Strings.of(context).numberBoundaryLessThanOrEqualTo;
      case NumberBoundary.equal_to:
        return Strings.of(context).numberBoundaryEqualTo;
      case NumberBoundary.greater_than:
        return Strings.of(context).numberBoundaryGreaterThan;
      case NumberBoundary.greater_than_or_equal_to:
        return Strings.of(context).numberBoundaryGreaterThanOrEqualTo;
      case NumberBoundary.range:
        return Strings.of(context).numberBoundaryRange;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension NumberFilters on NumberFilter {
  bool get isSet =>
      hasBoundary() && ((hasFrom() && from.isSet) || (hasTo() && to.isSet));

  String displayValue(BuildContext context) {
    String? result;
    switch (boundary) {
      case NumberBoundary.number_boundary_any:
        return Strings.of(context).numberBoundaryAny;
      case NumberBoundary.less_than:
        result = Strings.of(context).numberBoundaryLessThanValue;
        break;
      case NumberBoundary.less_than_or_equal_to:
        result = Strings.of(context).numberBoundaryLessThanOrEqualToValue;
        break;
      case NumberBoundary.equal_to:
        result = Strings.of(context).numberBoundaryEqualToValue;
        break;
      case NumberBoundary.greater_than:
        result = Strings.of(context).numberBoundaryGreaterThanValue;
        break;
      case NumberBoundary.greater_than_or_equal_to:
        result = Strings.of(context).numberBoundaryGreaterThanOrEqualToValue;
        break;
      case NumberBoundary.range:
        if (hasFrom() && hasTo()) {
          return format(Strings.of(context).numberBoundaryRangeValue,
              [from.displayValue(context), to.displayValue(context)]);
        } else {
          _log.w("Invalid range; missing start or end value");
          return Strings.of(context).numberBoundaryAny;
        }
    }

    if (isNotEmpty(result) && hasFrom()) {
      return format(result!, [from.displayValue(context)]);
    } else {
      _log.w("Invalid start value for boundary: $boundary");
      return Strings.of(context).numberBoundaryAny;
    }
  }

  bool containsMultiMeasurement(MultiMeasurement measurement) {
    switch (boundary) {
      case NumberBoundary.number_boundary_any:
        return true;
      case NumberBoundary.less_than:
        return measurement < from;
      case NumberBoundary.less_than_or_equal_to:
        return measurement <= from;
      case NumberBoundary.equal_to:
        return measurement == from;
      case NumberBoundary.greater_than:
        return measurement > from;
      case NumberBoundary.greater_than_or_equal_to:
        return measurement >= from;
      case NumberBoundary.range:
        return measurement >= from && measurement <= to;
    }
    return false;
  }

  bool containsMeasurement(Measurement measurement, MeasurementSystem? system) {
    var multiMeasurement = MultiMeasurement();

    if (system != null) {
      multiMeasurement.system = system;
    }

    if (measurement.hasValue()) {
      multiMeasurement.mainValue = measurement;
    }

    return containsMultiMeasurement(multiMeasurement);
  }

  bool containsInt(int value) {
    return containsMeasurement(Measurement(value: value.toDouble()), null);
  }
}

extension Periods on Period {
  static Set<Period> selectable() {
    return _selectable<Period>([
      // Don't use Period.values here because we need to maintain order.
      Period.dawn,
      Period.morning,
      Period.midday,
      Period.afternoon,
      Period.evening,
      Period.dusk,
      Period.night,
    ], []);
  }

  static Set<int> selectableValues() {
    return selectable().map((e) => e.value).toSet();
  }

  static List<PickerPageItem<Period>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      Periods.selectable().toList(),
      [],
      (context, period) => period.displayName(context),
      sort: false,
    );
  }

  static int Function(Period, Period) nameComparator(BuildContext context) {
    return (lhs, rhs) => ignoreCaseAlphabeticalComparator(
        lhs.displayName(context), rhs.displayName(context));
  }

  String displayName(BuildContext context) {
    switch (this) {
      case Period.period_all:
        return Strings.of(context).all;
      case Period.period_none:
        return Strings.of(context).none;
      case Period.dawn:
        return Strings.of(context).periodDawn;
      case Period.morning:
        return Strings.of(context).periodMorning;
      case Period.midday:
        return Strings.of(context).periodMidday;
      case Period.afternoon:
        return Strings.of(context).periodAfternoon;
      case Period.evening:
        return Strings.of(context).periodEvening;
      case Period.dusk:
        return Strings.of(context).periodDusk;
      case Period.night:
        return Strings.of(context).periodNight;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension PeriodList on List<Period> {
  Iterable<int> values() => map((e) => e.value);
}

extension Seasons on Season {
  /// Returns a [Season] from the given date and latitude. The Meteorological
  /// definition is used to calculate seasons:
  ///   - https://en.wikipedia.org/wiki/Season#Meteorological
  static Season? from(TZDateTime dateTime, double? lat) {
    if (lat == null) {
      return null;
    }

    var isNorth = lat > 0;
    var winterSummer = [12, 1, 2];
    var springAutumn = [3, 4, 5];
    var summerWinter = [6, 7, 8];
    var autumnSpring = [9, 10, 11];

    if (winterSummer.contains(dateTime.month)) {
      return isNorth ? Season.winter : Season.summer;
    } else if (springAutumn.contains(dateTime.month)) {
      return isNorth ? Season.spring : Season.autumn;
    } else if (summerWinter.contains(dateTime.month)) {
      return isNorth ? Season.summer : Season.winter;
    } else if (autumnSpring.contains(dateTime.month)) {
      return isNorth ? Season.autumn : Season.spring;
    } else {
      _log.w("Unknown month: ${dateTime.month}");
    }

    return null;
  }

  static Set<Season> selectable() {
    return _selectable<Season>(
        Season.values, [Season.season_none, Season.season_all]);
  }

  static Set<int> selectableValues() {
    return selectable().map((e) => e.value).toSet();
  }

  static List<PickerPageItem<Season>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      Seasons.selectable().toList(),
      [],
      (context, season) => season.displayName(context),
      sort: false,
    );
  }

  static int Function(Season, Season) nameComparator(BuildContext context) {
    return (lhs, rhs) => ignoreCaseAlphabeticalComparator(
        lhs.displayName(context), rhs.displayName(context));
  }

  String displayName(BuildContext context) {
    switch (this) {
      case Season.season_all:
        return Strings.of(context).all;
      case Season.season_none:
        return Strings.of(context).none;
      case Season.winter:
        return Strings.of(context).seasonWinter;
      case Season.spring:
        return Strings.of(context).seasonSpring;
      case Season.summer:
        return Strings.of(context).seasonSummer;
      case Season.autumn:
        return Strings.of(context).seasonAutumn;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension SeasonList on List<Season> {
  Iterable<int> values() => map((e) => e.value);
}

extension Units on Unit {
  static const _inchesPerFoot = 12.0;
  static const _ouncesPerPound = 16.0;

  String shorthandDisplayName(BuildContext context) {
    switch (this) {
      case Unit.feet:
        return Strings.of(context).unitFeet;
      case Unit.inches:
        return Strings.of(context).unitInches;
      case Unit.pounds:
        return Strings.of(context).unitPounds;
      case Unit.ounces:
        return Strings.of(context).unitOunces;
      case Unit.fahrenheit:
        return Strings.of(context).unitFahrenheit;
      case Unit.meters:
        return Strings.of(context).unitMeters;
      case Unit.centimeters:
        return Strings.of(context).unitCentimeters;
      case Unit.kilograms:
        return Strings.of(context).unitKilograms;
      case Unit.celsius:
        return Strings.of(context).unitCelsius;
      case Unit.miles_per_hour:
        return Strings.of(context).unitMilesPerHour;
      case Unit.kilometers_per_hour:
        return Strings.of(context).unitKilometersPerHour;
      case Unit.millibars:
        return Strings.of(context).unitMillibars;
      case Unit.pounds_per_square_inch:
        return Strings.of(context).unitPoundsPerSquareInch;
      case Unit.miles:
        return Strings.of(context).unitMiles;
      case Unit.kilometers:
        return Strings.of(context).unitKilometers;
      case Unit.percent:
        return Strings.of(context).unitPercent;
      case Unit.inch_of_mercury:
        return Strings.of(context).unitInchOfMercury;
      case Unit.x:
        return Strings.of(context).unitX;
      case Unit.aught:
        return Strings.of(context).unitAught;
      case Unit.pound_test:
        return Strings.of(context).unitPoundTest;
      case Unit.hashtag:
        return Strings.of(context).unitHashtag;
    }
    throw ArgumentError("Invalid input: $this");
  }

  String filterString(BuildContext context) {
    switch (this) {
      case Unit.feet:
        return Strings.of(context).keywordsDepthImperial;
      case Unit.inches:
        return Strings.of(context).keywordsLengthImperial;
      case Unit.pounds:
        return Strings.of(context).keywordsWeightImperial;
      case Unit.ounces:
        return Strings.of(context).keywordsWeightImperial;
      case Unit.fahrenheit:
        return Strings.of(context).keywordsTemperatureImperial;
      case Unit.meters:
        return Strings.of(context).keywordsDepthMetric;
      case Unit.centimeters:
        return Strings.of(context).keywordsLengthMetric;
      case Unit.kilograms:
        return Strings.of(context).keywordsWeightMetric;
      case Unit.celsius:
        return Strings.of(context).keywordsTemperatureMetric;
      case Unit.miles_per_hour:
        return Strings.of(context).keywordsSpeedImperial;
      case Unit.kilometers_per_hour:
        return Strings.of(context).keywordsSpeedMetric;
      case Unit.millibars:
        return Strings.of(context).keywordsAirPressureMetric;
      case Unit.pounds_per_square_inch:
        return Strings.of(context).keywordsAirPressureImperial;
      case Unit.miles:
        return Strings.of(context).keywordsAirVisibilityImperial;
      case Unit.kilometers:
        return Strings.of(context).keywordsAirVisibilityMetric;
      case Unit.percent:
        return Strings.of(context).keywordsPercent;
      case Unit.inch_of_mercury:
        return Strings.of(context).keywordsInchOfMercury;
      case Unit.x:
        return Strings.of(context).keywordsX;
      case Unit.aught:
        return Strings.of(context).keywordsAught;
      case Unit.pound_test:
        return Strings.of(context).keywordsPoundTest;
      case Unit.hashtag:
        return Strings.of(context).keywordsHashtag;
    }
    throw ArgumentError("Invalid input: $this");
  }

  /// True if this unit should include a space before the unit and after the
  /// value.
  bool get hasPreSpace {
    switch (this) {
      case Unit.feet:
      case Unit.inches:
      case Unit.pounds:
      case Unit.ounces:
      case Unit.meters:
      case Unit.centimeters:
      case Unit.kilograms:
      case Unit.miles_per_hour:
      case Unit.kilometers_per_hour:
      case Unit.millibars:
      case Unit.pounds_per_square_inch:
      case Unit.miles:
      case Unit.kilometers:
      case Unit.inch_of_mercury:
      case Unit.pound_test:
        return true;
      case Unit.celsius:
      case Unit.fahrenheit:
      case Unit.percent:
      case Unit.x:
      case Unit.aught:
      case Unit.hashtag:
        return false;
    }
    throw ArgumentError("Invalid input: $this");
  }

  /// True if this unit should be shown before the number value; false
  /// otherwise.
  bool get showsFirst {
    switch (this) {
      case Unit.feet:
      case Unit.inches:
      case Unit.pounds:
      case Unit.ounces:
      case Unit.meters:
      case Unit.centimeters:
      case Unit.kilograms:
      case Unit.miles_per_hour:
      case Unit.kilometers_per_hour:
      case Unit.millibars:
      case Unit.pounds_per_square_inch:
      case Unit.miles:
      case Unit.kilometers:
      case Unit.inch_of_mercury:
      case Unit.pound_test:
      case Unit.celsius:
      case Unit.fahrenheit:
      case Unit.percent:
      case Unit.x:
      case Unit.aught:
        return false;
      case Unit.hashtag:
        return true;
    }
    throw ArgumentError("Invalid input: $this");
  }

  bool canConvertToUnit(Unit unit) {
    switch (this) {
      case Unit.feet:
        return unit == Unit.meters;
      case Unit.inches:
        return unit == Unit.centimeters;
      case Unit.pounds:
      case Unit.ounces:
        return unit == Unit.kilograms;
      case Unit.fahrenheit:
        return unit == Unit.celsius;
      case Unit.meters:
        return unit == Unit.feet;
      case Unit.centimeters:
        return unit == Unit.inches;
      case Unit.kilograms:
        return unit == Unit.ounces || unit == Unit.pounds;
      case Unit.celsius:
        return unit == Unit.fahrenheit;
      case Unit.miles_per_hour:
        return unit == Unit.kilometers_per_hour;
      case Unit.kilometers_per_hour:
        return unit == Unit.miles_per_hour;
      case Unit.millibars:
        return unit == Unit.pounds_per_square_inch ||
            unit == Unit.inch_of_mercury;
      case Unit.pounds_per_square_inch:
        return unit == Unit.millibars || unit == Unit.inch_of_mercury;
      case Unit.inch_of_mercury:
        return unit == Unit.millibars || unit == Unit.pounds_per_square_inch;
      case Unit.miles:
        return unit == Unit.kilometers;
      case Unit.kilometers:
        return unit == Unit.miles;
      case Unit.percent:
        return unit == Unit.percent;
      // Units that can't be converted at all.
      case Unit.x:
      case Unit.aught:
      case Unit.pound_test:
      case Unit.hashtag:
        return false;
    }
    throw ArgumentError("Invalid input: $this");
  }

  double toDecimal(double value) {
    switch (this) {
      case Unit.inches:
        return value / _inchesPerFoot;
      case Unit.ounces:
        return value / _ouncesPerPound;
      // None of these units need to be converted to a decimal value; return
      // the raw value.
      case Unit.feet:
      case Unit.pounds:
      case Unit.fahrenheit:
      case Unit.meters:
      case Unit.centimeters:
      case Unit.kilograms:
      case Unit.celsius:
      case Unit.miles_per_hour:
      case Unit.kilometers_per_hour:
      case Unit.millibars:
      case Unit.pounds_per_square_inch:
      case Unit.miles:
      case Unit.kilometers:
      case Unit.percent:
      case Unit.inch_of_mercury:
      case Unit.x:
      case Unit.aught:
      case Unit.pound_test:
      case Unit.hashtag:
        return value;
    }
    throw ArgumentError("Invalid input: $this");
  }

  /// Returns a [MultiMeasurement] instance for this [Unit] with the given
  /// value. If a fractional unit exists for this [Unit], it will be used, and
  /// the resulting [MultiMeasurement.fractionValue] will be set.
  MultiMeasurement toMultiMeasurement(double value, MeasurementSystem system) {
    var result = MultiMeasurement(system: system);

    // Imperial whole is the only whole value that may have fractional values
    // (feet/inches, and pounds/ounces, for example).
    if (system == MeasurementSystem.imperial_whole) {
      var avgWhole = value.floorToDouble();
      if (value < 0) {
        avgWhole = value.ceilToDouble();

        // Handles the case where the overall value is between -1 and 0.
        result.isNegative = true;
      }

      result.mainValue = Measurement(
        unit: this,
        value: avgWhole,
      );

      var modDivisor = math.max(1, avgWhole);
      if (this == Unit.inches) {
        result.fractionValue = Measurement(
          value: Fraction.fromValue(value.abs() % modDivisor).value,
        );
      } else if (fractionalUnit == null) {
        _log.w("Unit doesn't have a fractional unit: $this");
      } else if (fractionalUnit == Unit.ounces) {
        _calculateFractionValue(result, value, modDivisor, _ouncesPerPound);
      } else if (fractionalUnit == Unit.inches) {
        _calculateFractionValue(result, value, modDivisor, _inchesPerFoot);
      }
    } else {
      result.mainValue = Measurement(
        unit: this,
        value: value,
      );
    }

    return result;
  }

  void _calculateFractionValue(MultiMeasurement measurement, double value,
      num modDivisor, double fractionalUnitsPerWhole) {
    var fractionValue =
        ((value.abs() % modDivisor) * fractionalUnitsPerWhole).roundToDouble();

    // If rounding causes the value to equal 1 full whole value, reset fraction
    // value to 0 and increment main value by 1.
    if (fractionValue == fractionalUnitsPerWhole) {
      measurement.mainValue.value += 1;
    } else {
      measurement.fractionValue = Measurement(
        unit: fractionalUnit,
        value: fractionValue,
      );
    }
  }

  /// Converts [value] to this [Unit]. The given [Unit] must be the
  /// [oppositeUnit] of the caller, otherwise [value] is returned unchanged.
  double convertFrom(Unit unit, double value) {
    if (unit == this) {
      return value;
    }

    if (!canConvertToUnit(unit)) {
      _log.w("Can't convert $unit to $this");
      return value;
    }

    switch (this) {
      // Fahrenheit to celsius.
      case Unit.celsius:
        return (value - 32) * (5 / 9);
      // Celsius to Fahrenheit.
      case Unit.fahrenheit:
        return value * (9 / 5) + 32;
      // Miles to kilometers.
      case Unit.kilometers_per_hour:
      case Unit.kilometers:
        return value * 1.609344;
      // Kilometers to miles
      case Unit.miles_per_hour:
      case Unit.miles:
        return value / 1.609344;
      // Millibars to pounds per square inch and inch of mercury.
      case Unit.pounds_per_square_inch:
        return value * (unit == Unit.millibars ? 0.0145038 : 0.491154);
      case Unit.inch_of_mercury:
        return value * (unit == Unit.millibars ? 0.02953 : 2.03602);
      case Unit.millibars:
        return value *
            (unit == Unit.pounds_per_square_inch ? 68.9476 : 33.8639);
      // Inches to centimeters.
      case Unit.centimeters:
        return value * 2.54;
      // Centimeters to inches.
      case Unit.inches:
        return value * 0.393701;
      // Meters to feet.
      case Unit.meters:
        return value * 0.3048;
      // Feet to meters.
      case Unit.feet:
        return value * 3.28084;
      // Pounds and ounces to kilograms.
      case Unit.kilograms:
        return value * (unit == Unit.pounds ? 0.453592 : 0.0283495);
      // Kilograms to pounds.
      case Unit.pounds:
        return value * 2.20462;
      // Kilograms to ounces.
      case Unit.ounces:
        return value * 35.274;
      default:
        _log.w("Unsupported conversion for $this");
        return value;
    }
  }

  Unit? get fractionalUnit {
    switch (this) {
      case Unit.feet:
        return Unit.inches;
      case Unit.pounds:
        return Unit.ounces;
      default:
        return null;
    }
  }

  Unit? get mainUnit {
    switch (this) {
      case Unit.inches:
        return Unit.feet;
      case Unit.ounces:
        return Unit.pounds;
      default:
        return null;
    }
  }
}

extension DateRanges on DateRange {
  int startMs(TZDateTime now) => startDate(now).millisecondsSinceEpoch;

  int endMs(TZDateTime now) => endDate(now).millisecondsSinceEpoch;

  int durationMs(TZDateTime now) => endMs(now) - startMs(now);

  TZDateTime startDate(TZDateTime now) {
    if (hasStartTimestamp()) {
      return dateTime(startTimestamp.toInt(), timeZone);
    }

    switch (period) {
      case DateRange_Period.allDates:
        return dateTime(0, timeZone);
      case DateRange_Period.today:
        return dateTimeToDayAccuracy(now);
      case DateRange_Period.yesterday:
        return dateTimeToDayAccuracy(now).subtract(const Duration(days: 1));
      case DateRange_Period.thisWeek:
        return startOfWeek(now);
      case DateRange_Period.thisMonth:
      case DateRange_Period.custom: // Default custom to this month.
        return startOfMonth(now);
      case DateRange_Period.thisYear:
        return startOfYear(now);
      case DateRange_Period.lastWeek:
        return startOfWeek(now)
            .subtract(const Duration(days: DateTime.daysPerWeek));
      case DateRange_Period.lastMonth:
        var year = now.year;
        var month = now.month - 1;
        if (month < DateTime.january) {
          month = DateTime.december;
          year -= 1;
        }
        return TZDateTime(now.location, year, month);
      case DateRange_Period.lastYear:
        return TZDateTime(now.location, now.year - 1);
      case DateRange_Period.last7Days:
        return now.subtract(const Duration(days: 7));
      case DateRange_Period.last14Days:
        return now.subtract(const Duration(days: 14));
      case DateRange_Period.last30Days:
        return now.subtract(const Duration(days: 30));
      case DateRange_Period.last60Days:
        return now.subtract(const Duration(days: 60));
      case DateRange_Period.last12Months:
        return now.subtract(const Duration(days: 365));
    }
    throw ArgumentError("Invalid input: $period");
  }

  TZDateTime endDate(TZDateTime now) {
    if (hasEndTimestamp()) {
      return dateTime(endTimestamp.toInt(), timeZone);
    }

    switch (period) {
      case DateRange_Period.allDates:
      case DateRange_Period.today:
      case DateRange_Period.thisWeek:
      case DateRange_Period.thisMonth:
      case DateRange_Period.custom: // Default custom to this month.
      case DateRange_Period.thisYear:
      case DateRange_Period.last7Days:
      case DateRange_Period.last14Days:
      case DateRange_Period.last30Days:
      case DateRange_Period.last60Days:
      case DateRange_Period.last12Months:
        return now;
      case DateRange_Period.yesterday:
        return dateTimeToDayAccuracy(now);
      case DateRange_Period.lastWeek:
        return startOfWeek(now);
      case DateRange_Period.lastMonth:
        return startOfMonth(now);
      case DateRange_Period.lastYear:
        return startOfYear(now);
    }
    throw ArgumentError("Invalid input: $period");
  }

  String displayName(BuildContext context) {
    var now = TimeManager.of(context).now(timeZone);

    if (hasStartTimestamp() && hasEndTimestamp()) {
      var formatter = DateFormat(monthDayYearFormat);
      return "${formatter.format(startDate(now))} - "
          "${formatter.format(endDate(now))}";
    }

    switch (period) {
      case DateRange_Period.allDates:
        return Strings.of(context).analysisDurationAllDates;
      case DateRange_Period.today:
        return Strings.of(context).analysisDurationToday;
      case DateRange_Period.yesterday:
        return Strings.of(context).analysisDurationYesterday;
      case DateRange_Period.thisWeek:
        return Strings.of(context).analysisDurationThisWeek;
      case DateRange_Period.thisMonth:
        return Strings.of(context).analysisDurationThisMonth;
      case DateRange_Period.thisYear:
        return Strings.of(context).analysisDurationThisYear;
      case DateRange_Period.last7Days:
        return Strings.of(context).analysisDurationLast7Days;
      case DateRange_Period.last14Days:
        return Strings.of(context).analysisDurationLast14Days;
      case DateRange_Period.last30Days:
        return Strings.of(context).analysisDurationLast30Days;
      case DateRange_Period.last60Days:
        return Strings.of(context).analysisDurationLast60Days;
      case DateRange_Period.last12Months:
        return Strings.of(context).analysisDurationLast12Months;
      case DateRange_Period.lastWeek:
        return Strings.of(context).analysisDurationLastWeek;
      case DateRange_Period.lastMonth:
        return Strings.of(context).analysisDurationLastMonth;
      case DateRange_Period.lastYear:
        return Strings.of(context).analysisDurationLastYear;
      case DateRange_Period.custom:
        return Strings.of(context).analysisDurationCustom;
    }
    throw ArgumentError("Invalid input: $period");
  }

  bool contains(int timestamp, TZDateTime now) =>
      timestamp >= startMs(now) && timestamp <= endMs(now);
}

extension MoonPhases on MoonPhase {
  static Set<MoonPhase> selectable() {
    return _selectable<MoonPhase>(MoonPhase.values,
        [MoonPhase.moon_phase_none, MoonPhase.moon_phase_all]);
  }

  static Set<int> selectableValues() {
    return selectable().map((e) => e.value).toSet();
  }

  static List<PickerPageItem<MoonPhase>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      MoonPhases.selectable().toList(),
      [],
      (context, phase) => phase.displayName(context),
      sort: false,
    );
  }

  /// Converts a Visual Crossing moon phase value to a [MoonPhase].
  /// See https://www.visualcrossing.com/resources/documentation/weather-data/weather-data-documentation/.
  static MoonPhase fromDouble(double value) {
    if (value == 0) {
      return MoonPhase.new_;
    }
    if (value < 0.25) {
      return MoonPhase.waxing_crescent;
    } else if (value == 0.25) {
      return MoonPhase.first_quarter;
    } else if (value < 0.5) {
      return MoonPhase.waxing_gibbous;
    } else if (value == 0.5) {
      return MoonPhase.full;
    } else if (value < 0.75) {
      return MoonPhase.waning_gibbous;
    } else if (value == 0.75) {
      return MoonPhase.last_quarter;
    } else if (value <= 1) {
      return MoonPhase.waning_crescent;
    } else {
      return MoonPhase.moon_phase_none;
    }
  }

  static int Function(MoonPhase, MoonPhase) nameComparator(
      BuildContext context) {
    return (lhs, rhs) => ignoreCaseAlphabeticalComparator(
        lhs.displayName(context), rhs.displayName(context));
  }

  String displayName(BuildContext context) {
    switch (this) {
      case MoonPhase.moon_phase_all:
        return Strings.of(context).all;
      case MoonPhase.moon_phase_none:
        return Strings.of(context).none;
      case MoonPhase.new_:
        return Strings.of(context).moonPhaseNew;
      case MoonPhase.waxing_crescent:
        return Strings.of(context).moonPhaseWaxingCrescent;
      case MoonPhase.first_quarter:
        return Strings.of(context).moonPhaseFirstQuarter;
      case MoonPhase.waxing_gibbous:
        return Strings.of(context).moonPhaseWaxingGibbous;
      case MoonPhase.full:
        return Strings.of(context).moonPhaseFull;
      case MoonPhase.waning_gibbous:
        return Strings.of(context).moonPhaseWaningGibbous;
      case MoonPhase.last_quarter:
        return Strings.of(context).moonPhaseLastQuarter;
      case MoonPhase.waning_crescent:
        return Strings.of(context).moonPhaseWaningCrescent;
    }
    throw ArgumentError("Invalid input: $this");
  }

  String chipName(BuildContext context) {
    return format(Strings.of(context).moonPhaseChip, [displayName(context)]);
  }
}

extension MoonPhaseList on List<MoonPhase> {
  Iterable<int> values() => map((e) => e.value);
}

extension Directions on Direction {
  static Set<Direction> selectable() {
    return _selectable<Direction>(
        Direction.values, [Direction.direction_none, Direction.direction_all]);
  }

  static List<PickerPageItem<Direction>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      Directions.selectable().toList(),
      [],
      (context, direction) => direction.displayName(context),
      sort: false,
    );
  }

  static Direction fromDegrees(double degrees) {
    var closest = Direction.north;
    var minDifference = 360.0;

    for (var direction in Directions.selectable()) {
      var diff = (direction.toDegrees() - degrees).abs();
      if (diff < minDifference) {
        minDifference = diff;
        closest = direction;
      }
    }

    // North is at both 0 and 360 degrees. Do the additional 360 degrees check
    // here.
    var diff = 360 - degrees;
    if (diff < minDifference) {
      closest = Direction.north;
    }

    return closest;
  }

  String displayName(BuildContext context) {
    switch (this) {
      case Direction.direction_all:
        return Strings.of(context).all;
      case Direction.direction_none:
        return Strings.of(context).none;
      case Direction.north:
        return Strings.of(context).directionNorth;
      case Direction.north_east:
        return Strings.of(context).directionNorthEast;
      case Direction.east:
        return Strings.of(context).directionEast;
      case Direction.south_east:
        return Strings.of(context).directionSouthEast;
      case Direction.south:
        return Strings.of(context).directionSouth;
      case Direction.south_west:
        return Strings.of(context).directionSouthWest;
      case Direction.west:
        return Strings.of(context).directionWest;
      case Direction.north_west:
        return Strings.of(context).directionNorthWest;
    }
    throw ArgumentError("Invalid input: $this");
  }

  String chipName(BuildContext context) {
    return format(
        Strings.of(context).directionWindChip, [displayName(context)]);
  }

  String filterString(BuildContext context) {
    switch (this) {
      case Direction.direction_all:
      case Direction.direction_none:
        return "";
      case Direction.north:
        return Strings.of(context).keywordsNorth;
      case Direction.north_east:
        return Strings.of(context).keywordsNorthEast;
      case Direction.east:
        return Strings.of(context).keywordsEast;
      case Direction.south_east:
        return Strings.of(context).keywordsSouthEast;
      case Direction.south:
        return Strings.of(context).keywordsSouth;
      case Direction.south_west:
        return Strings.of(context).keywordsSouthWest;
      case Direction.west:
        return Strings.of(context).keywordsWest;
      case Direction.north_west:
        return Strings.of(context).keywordsNorthWest;
    }
    throw ArgumentError("Invalid input: $this");
  }

  double toDegrees() {
    switch (this) {
      case Direction.direction_all:
      case Direction.direction_none:
        throw ArgumentError("Invalid input: $this");
      case Direction.north:
        return 0.0;
      case Direction.north_east:
        return 45.0;
      case Direction.east:
        return 90.0;
      case Direction.south_east:
        return 135.0;
      case Direction.south:
        return 180.0;
      case Direction.south_west:
        return 225.0;
      case Direction.west:
        return 270.0;
      case Direction.north_west:
        return 315.0;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension Reports on Report {
  String? displayName(BuildContext context) {
    if (id == reportIdCatchSummary) {
      return Strings.of(context).statsPageCatchSummary;
    } else if (id == reportIdSpeciesSummary) {
      return Strings.of(context).statsPageSpeciesSummary;
    } else if (id == reportIdAnglerSummary) {
      return Strings.of(context).statsPageAnglerSummary;
    } else if (id == reportIdBaitSummary) {
      return Strings.of(context).statsPageBaitSummary;
    } else if (id == reportIdBodyOfWaterSummary) {
      return Strings.of(context).statsPageBodyOfWaterSummary;
    } else if (id == reportIdFishingSpotSummary) {
      return Strings.of(context).statsPageFishingSpotSummary;
    } else if (id == reportIdMethodSummary) {
      return Strings.of(context).statsPageMethodSummary;
    } else if (id == reportIdMoonPhaseSummary) {
      return Strings.of(context).statsPageMoonPhaseSummary;
    } else if (id == reportIdPeriodSummary) {
      return Strings.of(context).statsPagePeriodSummary;
    } else if (id == reportIdSeasonSummary) {
      return Strings.of(context).statsPageSeasonSummary;
    } else if (id == reportIdTideTypeSummary) {
      return Strings.of(context).statsPageTideSummary;
    } else if (id == reportIdWaterClaritySummary) {
      return Strings.of(context).statsPageWaterClaritySummary;
    } else if (id == reportIdPersonalBests) {
      return Strings.of(context).statsPagePersonalBests;
    } else if (id == reportIdTripSummary) {
      return Strings.of(context).tripSummaryTitle;
    } else if (id == reportIdGearSummary) {
      return Strings.of(context).statsPageGearSummary;
    } else {
      return null;
    }
  }

  bool get isCustom => hasType();
}

extension SkyConditions on SkyCondition {
  static Set<SkyCondition> selectable() {
    return _selectable<SkyCondition>(SkyCondition.values,
        [SkyCondition.sky_condition_none, SkyCondition.sky_condition_all]);
  }

  static List<PickerPageItem<SkyCondition>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      SkyConditions.selectable().toList(),
      [],
      (context, condition) => condition.displayName(context),
    );
  }

  static String displayNameForList(
      BuildContext context, List<SkyCondition> conditions) {
    return conditions.map((c) => c.displayName(context)).join(", ");
  }

  /// Converts a Visual Crossing conditions type to a [SkyCondition].
  /// See https://github.com/visualcrossing/WeatherApi/blob/master/lang/en.txt.
  static Set<SkyCondition> fromTypes(String types) {
    var result = <SkyCondition>{};
    var typeList = types.split(",");

    for (var type in typeList) {
      switch (type.trim()) {
        case "type_1":
        case "type_31":
        case "type_32":
        case "type_33":
        case "type_34":
        case "type_35":
        case "type_36":
          result.add(SkyCondition.snow);
          break;
        case "type_2":
        case "type_3":
        case "type_4":
        case "type_5":
        case "type_6":
          result.add(SkyCondition.drizzle);
          break;
        case "type_7":
        case "type_39":
          result.add(SkyCondition.dust);
          break;
        case "type_8":
        case "type_12":
          result.add(SkyCondition.fog);
          break;
        case "type_9":
        case "type_10":
        case "type_11":
        case "type_13":
        case "type_14":
        case "type_20":
        case "type_21":
        case "type_22":
        case "type_23":
        case "type_24":
        case "type_25":
        case "type_26":
          result.add(SkyCondition.rain);
          break;
        case "type_15":
          result.add(SkyCondition.tornado);
          break;
        case "type_16":
        case "type_40":
          result.add(SkyCondition.hail);
          break;
        case "type_17":
          result.add(SkyCondition.ice);
          break;
        case "type_18":
        case "type_37":
        case "type_38":
          result.add(SkyCondition.storm);
          break;
        case "type_19":
          result.add(SkyCondition.mist);
          break;
        case "type_30":
          result.add(SkyCondition.smoke);
          break;
        case "type_41":
          result.add(SkyCondition.overcast);
          break;
        case "type_27":
        case "type_28":
        case "type_42":
          result.add(SkyCondition.cloudy);
          break;
        case "type_43":
          result.add(SkyCondition.clear);
          break;
        default:
          _log.w("Unknown conditions type: $type");
          break;
      }
    }

    return result;
  }

  String displayName(BuildContext context) {
    switch (this) {
      case SkyCondition.sky_condition_all:
        return Strings.of(context).all;
      case SkyCondition.sky_condition_none:
        return Strings.of(context).none;
      case SkyCondition.snow:
        return Strings.of(context).skyConditionSnow;
      case SkyCondition.drizzle:
        return Strings.of(context).skyConditionDrizzle;
      case SkyCondition.dust:
        return Strings.of(context).skyConditionDust;
      case SkyCondition.fog:
        return Strings.of(context).skyConditionFog;
      case SkyCondition.rain:
        return Strings.of(context).skyConditionRain;
      case SkyCondition.tornado:
        return Strings.of(context).skyConditionTornado;
      case SkyCondition.hail:
        return Strings.of(context).skyConditionHail;
      case SkyCondition.ice:
        return Strings.of(context).skyConditionIce;
      case SkyCondition.storm:
        return Strings.of(context).skyConditionStorm;
      case SkyCondition.mist:
        return Strings.of(context).skyConditionMist;
      case SkyCondition.smoke:
        return Strings.of(context).skyConditionSmoke;
      case SkyCondition.overcast:
        return Strings.of(context).skyConditionOvercast;
      case SkyCondition.cloudy:
        return Strings.of(context).skyConditionCloudy;
      case SkyCondition.clear:
        return Strings.of(context).skyConditionClear;
      case SkyCondition.sunny:
        return Strings.of(context).skyConditionSunny;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension TideTypes on TideType {
  static Set<TideType> selectable() {
    return _selectable<TideType>(
        TideType.values, [TideType.tide_type_none, TideType.tide_type_all]);
  }

  static Set<int> selectableValues() {
    return selectable().map((e) => e.value).toSet();
  }

  static List<PickerPageItem<TideType>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      TideTypes.selectable().toList(),
      [],
      (context, type) => type.displayName(context),
      sort: false,
    );
  }

  static int Function(TideType, TideType) nameComparator(BuildContext context) {
    return (lhs, rhs) => ignoreCaseAlphabeticalComparator(
        lhs.displayName(context), rhs.displayName(context));
  }

  String displayName(BuildContext context) {
    switch (this) {
      case TideType.tide_type_none:
        return Strings.of(context).none;
      case TideType.tide_type_all:
        return Strings.of(context).all;
      case TideType.low:
        return Strings.of(context).tideTypeLow;
      case TideType.outgoing:
        return Strings.of(context).tideTypeOutgoing;
      case TideType.high:
        return Strings.of(context).tideTypeHigh;
      case TideType.slack:
        return Strings.of(context).tideTypeSlack;
      case TideType.incoming:
        return Strings.of(context).tideTypeIncoming;
    }
    throw ArgumentError("Invalid input: $this");
  }

  String chipName(BuildContext context) {
    switch (this) {
      case TideType.tide_type_none:
        return Strings.of(context).none;
      case TideType.tide_type_all:
        return Strings.of(context).all;
      case TideType.low:
        return Strings.of(context).tideLow;
      case TideType.outgoing:
        return Strings.of(context).tideOutgoing;
      case TideType.high:
        return Strings.of(context).tideHigh;
      case TideType.slack:
        return Strings.of(context).tideSlack;
      case TideType.incoming:
        return Strings.of(context).tideIncoming;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension TideTypeList on List<TideType> {
  Iterable<int> values() => map((e) => e.value);
}

extension Tides on Tide {
  // Industry standard.
  static int get displayDecimalPlaces => 3;

  bool get isValid =>
      hasType() ||
      hasHeight() ||
      hasFirstLowTimestamp() ||
      hasFirstHighTimestamp() ||
      hasSecondLowTimestamp() ||
      hasSecondHighTimestamp() ||
      daysHeights.isNotEmpty;

  TZDateTime firstLowDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(firstLowTimestamp.toInt(), timeZone);

  TZDateTime firstHighDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(firstHighTimestamp.toInt(), timeZone);

  TZDateTime secondLowDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(secondLowTimestamp.toInt(), timeZone);

  TZDateTime secondHighDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(secondHighTimestamp.toInt(), timeZone);

  String currentDisplayValue(
    BuildContext context, {
    bool useChipName = false,
  }) {
    var result = "";

    if (hasType()) {
      result +=
          useChipName ? type.chipName(context) : type.displayName(context);
    }

    if (hasHeight() && height.hasValue() && height.hasTimestamp()) {
      if (hasType()) {
        result += ", ";
      }

      var measurement = MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: height.value,
        ),
      );

      var mainUnit = MultiMeasurementInputSpec.tideHeight(context).mainUnit;
      if (mainUnit != null) {
        measurement = measurement.convertToSystem(
            UserPreferenceManager.of(context).tideHeightSystem, mainUnit);
      }

      result += format(Strings.of(context).tideTimeAndHeight, [
        measurement.displayValue(
          context,
          mainDecimalPlaces: displayDecimalPlaces,
        ),
        formatTimeMillis(context, height.timestamp, timeZone)
      ]);
    }

    return result;
  }

  String extremesDisplayValue(BuildContext context) {
    var result = "";

    if (!hasFirstLowTimestamp() && !hasFirstHighTimestamp()) {
      return result;
    }

    if (hasFirstLowTimestamp()) {
      result += format(Strings.of(context).tideInputLowTimeValue, [
        formatTimeMillis(context, firstLowTimestamp, timeZone),
      ]);

      if (hasSecondLowTimestamp()) {
        result +=
            ", ${formatTimeMillis(context, secondLowTimestamp, timeZone)}";
      }

      if (hasFirstHighTimestamp()) {
        result += "; ";
      }
    }

    if (hasFirstHighTimestamp()) {
      result += format(Strings.of(context).tideInputHighTimeValue, [
        formatTimeMillis(context, firstHighTimestamp, timeZone),
      ]);
    }

    if (hasSecondHighTimestamp()) {
      result += ", ${formatTimeMillis(context, secondHighTimestamp, timeZone)}";
    }

    return result;
  }
}

extension Trips on Trip {
  int get duration => endTimestamp.toInt() - startTimestamp.toInt();

  TZDateTime startDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(startTimestamp.toInt(), timeZone);

  TZDateTime endDateTime(BuildContext context) =>
      TimeManager.of(context).dateTime(endTimestamp.toInt(), timeZone);

  String elapsedDisplayValue(BuildContext context) {
    var startDateTime = this.startDateTime(context);
    var endDateTime = this.endDateTime(context);

    var startStr = formatDateTime(
      context,
      startDateTime,
      abbreviated: !startDateTime.isMidnight,
      excludeMidnight: true,
    );

    var endStr = formatDateTime(
      context,
      endDateTime,
      abbreviated: !endDateTime.isMidnight,
      excludeMidnight: true,
    );

    return format(Strings.of(context).dateRangeFormat, [startStr, endStr]);
  }

  /// Increments the value of [entityId] in [perEntity] by [catchQuantity]. If
  /// [entityId] does not exist in [perEntity], a new [Trip_CatchesPerEntity]
  /// is added.
  static void incCatchesPerEntity(
    List<Trip_CatchesPerEntity> perEntity,
    Id entityId,
    Catch cat,
  ) {
    if (Ids.isNotValid(entityId)) {
      return;
    }

    var existing = perEntity.firstWhereOrNull((e) => e.entityId == entityId);

    if (existing == null) {
      perEntity.add(Trip_CatchesPerEntity(
        entityId: entityId,
        value: catchQuantity(cat),
      ));
    } else {
      existing.value += catchQuantity(cat);
    }
  }

  void incCatchesPerAngler(Catch cat) =>
      incCatchesPerEntity(catchesPerAngler, cat.anglerId, cat);

  void incCatchesPerFishingSpot(Catch cat) =>
      incCatchesPerEntity(catchesPerFishingSpot, cat.fishingSpotId, cat);

  void incCatchesPerSpecies(Catch cat) =>
      incCatchesPerEntity(catchesPerSpecies, cat.speciesId, cat);

  /// Increments the values of a catch's baits in [perBait] by [catchQuantity].
  /// If the bait does not exist in [perBait], a new [Trip_CatchesPerBait] is
  /// added.
  static void incCatchesPerBait(List<Trip_CatchesPerBait> perBait, Catch cat) {
    if (cat.baits.isEmpty) {
      return;
    }

    for (var attachment in cat.baits) {
      var existing =
          perBait.firstWhereOrNull((e) => e.attachment == attachment);

      if (existing == null) {
        perBait.add(Trip_CatchesPerBait(
          attachment: attachment,
          value: catchQuantity(cat),
        ));
      } else {
        existing.value += catchQuantity(cat);
      }
    }
  }
}

extension GpsTrails on GpsTrail {
  bool get isFinished => hasStartTimestamp() && hasEndTimestamp();

  bool get isInProgress => !hasEndTimestamp();

  LatLngBounds? get mapBounds =>
      map_utils.mapBounds(points.map((e) => e.latLng));

  LatLng? get center => mapBounds?.center;

  String displayTimestamp(BuildContext context) =>
      formatTimestamp(context, startTimestamp.toInt(), timeZone);

  String startDisplayValue(BuildContext context) =>
      formatTimestamp(context, startTimestamp.toInt(), timeZone);

  String? elapsedDisplayValue(BuildContext context) {
    if (!isFinished) {
      return null;
    }

    return format(Strings.of(context).dateRangeFormat, [
      startDisplayValue(context),
      formatTimestamp(context, endTimestamp.toInt(), timeZone),
    ]);
  }
}

extension GpsTrailPoints on GpsTrailPoint {
  LatLng get latLng => LatLng(lat, lng);
}

extension RodActions on RodAction {
  static List<PickerPageItem<RodAction>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      RodAction.values,
      [RodAction.rod_action_none, RodAction.rod_action_all],
      (context, action) => action.displayName(context),
      sort: false,
    );
  }

  String displayName(BuildContext context) {
    switch (this) {
      case RodAction.rod_action_all:
        return Strings.of(context).all;
      case RodAction.rod_action_none:
        return Strings.of(context).none;
      case RodAction.fast:
        return Strings.of(context).gearActionFast;
      case RodAction.moderate:
        return Strings.of(context).gearActionModerate;
      case RodAction.moderate_fast:
        return Strings.of(context).gearActionModerateFast;
      case RodAction.slow:
        return Strings.of(context).gearActionSlow;
      case RodAction.x_fast:
        return Strings.of(context).gearActionXFast;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension RodPowers on RodPower {
  static List<PickerPageItem<RodPower>> pickerItems(BuildContext context) {
    return _pickerItems(
      context,
      RodPower.values,
      [RodPower.rod_power_none, RodPower.rod_power_all],
      (context, power) => power.displayName(context),
      sort: false,
    );
  }

  String displayName(BuildContext context) {
    switch (this) {
      case RodPower.rod_power_all:
        return Strings.of(context).all;
      case RodPower.rod_power_none:
        return Strings.of(context).none;
      case RodPower.heavy:
        return Strings.of(context).gearPowerHeavy;
      case RodPower.light:
        return Strings.of(context).gearPowerLight;
      case RodPower.medium:
        return Strings.of(context).gearPowerMedium;
      case RodPower.medium_heavy:
        return Strings.of(context).gearPowerMediumHeavy;
      case RodPower.medium_light:
        return Strings.of(context).gearPowerMediumLight;
      case RodPower.ultralight:
        return Strings.of(context).gearPowerUltralight;
      case RodPower.x_heavy:
        return Strings.of(context).gearPowerXHeavy;
      case RodPower.xx_heavy:
        return Strings.of(context).gearPowerXxHeavy;
      case RodPower.xxx_heavy:
        return Strings.of(context).gearPowerXxxHeavy;
    }
    throw ArgumentError("Invalid input: $this");
  }
}
