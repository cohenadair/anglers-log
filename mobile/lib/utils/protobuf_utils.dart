import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/fraction.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../time_manager.dart';
import '../utils/string_utils.dart';
import 'date_time_utils.dart';
import 'number_utils.dart';

final _log = Log("ProtobufUtils");

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

bool filterMatchesEntityValues(List<CustomEntityValue> values, String? filter,
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
      title: period.displayName(context),
      value: period,
    );
  }).toList();
}

Set<Season> selectableSeasons() {
  return {
    Season.winter,
    Season.spring,
    Season.summer,
    Season.autumn,
  };
}

List<PickerPageItem<Season>> pickerItemsForSeason(BuildContext context) {
  return selectableSeasons().map((season) {
    return PickerPageItem<Season>(
      title: season.displayName(context),
      value: season,
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
  if (!(item is GeneratedMessage)) {
    return list.indexOf(item);
  }

  for (var i = 0; i < list.length; i++) {
    // For non-GeneratedMessage objects in list, use ==.
    if (!(list[i] is GeneratedMessage)) {
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

extension GeneratedMessages on GeneratedMessage {
  T copyAndUpdate<T extends GeneratedMessage>(void Function(T) updates) {
    return (deepCopy().freeze() as T).rebuild(updates);
  }
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
}

extension Measurements on Measurement {
  String displayValue(BuildContext context) {
    var unitString = "";
    if (hasUnit()) {
      unitString = "${unit.hasPreSpace ? " " : ""}"
          "${unit.shorthandDisplayName(context)}";
    }
    return "$stringValue$unitString";
  }

  String get stringValue => "${value.roundIfWhole() ?? value}";

  /// Updates [unit] to the new system. This method _does not_ convert values
  /// between units.
  Measurement toSystem(MeasurementSystem system) {
    if (unit.measurementSystem != system) {
      return copyAndUpdate<Measurement>((updates) {
        updates.unit = unit.oppositeUnit;
      });
    }
    return deepCopy();
  }

  bool _unitsMatch(Measurement other) {
    if (hasUnit() && other.hasUnit() && unit != other.unit) {
      _log.w("Can't compare different units: $unit vs. ${other.unit}");
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
  bool get isSet => hasMainValue() || hasFractionValue();

  String displayValue(BuildContext context) {
    // Inches require a different format than other measurements due to the
    // fraction not having its own unit. The different format only applies
    // when a fraction is set.
    var fraction = Fraction.fromValue(fractionValue.value);
    if (mainValue.hasUnit() &&
        mainValue.unit == Unit.inches &&
        fraction != Fraction.zero) {
      var unit = mainValue.unit.shorthandDisplayName(context);
      return "${mainValue.stringValue} ${fraction.symbol} $unit";
    }

    var isFractionSet = hasFractionValue() &&
        fractionValue.hasValue() &&
        fractionValue.value > 0;
    return mainValue.displayValue(context) +
        (isFractionSet ? " ${fractionValue.displayValue(context)}" : "");
  }

  /// Updates [mainValue] and [fractionValue] to the new system.
  /// This method _does not_ convert values between units.
  MultiMeasurement toSystem(MeasurementSystem newSystem) {
    return copyAndUpdate<MultiMeasurement>((updates) {
      updates
        ..system = newSystem
        ..mainValue = mainValue.toSystem(newSystem)
        ..fractionValue = fractionValue.toSystem(newSystem);
    });
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

    if (lhs.system != rhs.system) {
      _log.w(
          "Can't compare different systems: ${lhs.system} vs. ${rhs.system}");
      return false;
    }

    return comparator(lhs.mainValue, rhs.mainValue);
  }

  MultiMeasurement _toDecimalIfNeeded() {
    if (system != MeasurementSystem.imperial_whole) {
      return this;
    }

    var result = deepCopy();
    result.system = MeasurementSystem.imperial_decimal;

    if (result.hasFractionValue() && result.fractionValue.hasValue()) {
      result.mainValue.value = result.mainValue.value +
          result.fractionValue.unit.toDecimal(result.fractionValue.value);
    }

    return result;
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

  bool containsMeasurement(Measurement measurement) {
    var multiMeasurement = MultiMeasurement();

    if (measurement.hasUnit()) {
      multiMeasurement.system = measurement.unit.measurementSystem;
    }

    if (measurement.hasValue()) {
      multiMeasurement.mainValue = measurement;
    }

    return containsMultiMeasurement(multiMeasurement);
  }

  bool containsInt(int value) {
    return containsMeasurement(Measurement(
      value: value.toDouble(),
    ));
  }
}

extension Periods on Period {
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
      case Period.dusk:
        return Strings.of(context).periodDusk;
      case Period.night:
        return Strings.of(context).periodNight;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension Seasons on Season {
  static Season? from(DateTime dateTime, double? lat) {
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
        return true;
      case Unit.celsius:
      case Unit.fahrenheit:
        return false;
    }
    throw ArgumentError("Invalid input: $this");
  }

  MeasurementSystem get measurementSystem {
    switch (this) {
      case Unit.feet:
      case Unit.inches:
      case Unit.pounds:
      case Unit.ounces:
      case Unit.fahrenheit:
        return MeasurementSystem.imperial_whole;
      case Unit.meters:
      case Unit.centimeters:
      case Unit.kilograms:
      case Unit.celsius:
        return MeasurementSystem.metric;
    }
    throw ArgumentError("Invalid input: $this");
  }

  Unit get oppositeUnit {
    switch (this) {
      case Unit.feet:
        return Unit.meters;
      case Unit.inches:
        return Unit.centimeters;
      case Unit.pounds:
      case Unit.ounces:
        return Unit.kilograms;
      case Unit.fahrenheit:
        return Unit.celsius;
      case Unit.meters:
        return Unit.feet;
      case Unit.centimeters:
        return Unit.inches;
      case Unit.kilograms:
        return Unit.pounds;
      case Unit.celsius:
        return Unit.fahrenheit;
    }
    throw ArgumentError("Invalid input: $this");
  }

  double toDecimal(double value) {
    switch (this) {
      case Unit.inches:
        return value / _inchesPerFoot;
      case Unit.ounces:
        return value / _ouncesPerPound;
      case Unit.feet:
      case Unit.pounds:
      case Unit.fahrenheit:
      case Unit.meters:
      case Unit.centimeters:
      case Unit.kilograms:
      case Unit.celsius:
        _log.w("Unit.toDecimal called with non-decimal unit: $this");
        return value;
    }
    throw ArgumentError("Invalid input: $this");
  }
}

extension DateRanges on DateRange {
  int startMs(DateTime now) => startDate(now).millisecondsSinceEpoch;

  int endMs(DateTime now) => endDate(now).millisecondsSinceEpoch;

  int durationMs(DateTime now) => endMs(now) - startMs(now);

  DateTime startDate(DateTime now) {
    if (hasStartTimestamp()) {
      return DateTime.fromMillisecondsSinceEpoch(startTimestamp.toInt());
    }

    switch (period) {
      case DateRange_Period.allDates:
        return DateTime.fromMicrosecondsSinceEpoch(0);
      case DateRange_Period.today:
        return dateTimeToDayAccuracy(now);
      case DateRange_Period.yesterday:
        return dateTimeToDayAccuracy(now).subtract(Duration(days: 1));
      case DateRange_Period.thisWeek:
        return startOfWeek(now);
      case DateRange_Period.thisMonth:
      case DateRange_Period.custom: // Default custom to this month.
        return startOfMonth(now);
      case DateRange_Period.thisYear:
        return startOfYear(now);
      case DateRange_Period.lastWeek:
        return startOfWeek(now).subtract(Duration(days: DateTime.daysPerWeek));
      case DateRange_Period.lastMonth:
        var year = now.year;
        var month = now.month - 1;
        if (month < DateTime.january) {
          month = DateTime.december;
          year -= 1;
        }
        return DateTime(year, month);
      case DateRange_Period.lastYear:
        return DateTime(now.year - 1);
      case DateRange_Period.last7Days:
        return now.subtract(Duration(days: 7));
      case DateRange_Period.last14Days:
        return now.subtract(Duration(days: 14));
      case DateRange_Period.last30Days:
        return now.subtract(Duration(days: 30));
      case DateRange_Period.last60Days:
        return now.subtract(Duration(days: 60));
      case DateRange_Period.last12Months:
        return now.subtract(Duration(days: 365));
    }
    throw ArgumentError("Invalid input: $period");
  }

  DateTime endDate(DateTime now) {
    if (hasEndTimestamp()) {
      return DateTime.fromMillisecondsSinceEpoch(endTimestamp.toInt());
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
    var now = TimeManager.of(context).currentDateTime;

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

  bool contains(int timestamp, DateTime now) =>
      timestamp >= startMs(now) && timestamp <= endMs(now);
}
