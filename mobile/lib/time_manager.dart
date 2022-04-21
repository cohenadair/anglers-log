import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import 'app_manager.dart';
import 'log.dart';
import 'utils/date_time_utils.dart';
import 'utils/string_utils.dart';

class TimeManager {
  static TimeManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).timeManager;

  final _log = const Log("TimeManager");

  TZDateTime get currentDateTime => TZDateTime.now(currentLocation.value);

  TimeZoneLocation get currentLocation => _currentLocation;

  TimeOfDay get currentTime => TimeOfDay.now();

  int get currentTimestamp => currentDateTime.millisecondsSinceEpoch;

  String get currentTimeZone => currentLocation.name;

  List<TimeZoneLocation> _availableLocations = [];
  late TimeZoneLocation _currentLocation;

  Future<void> initialize() async {
    initializeTimeZones();

    // Filter out all time zones that aren't available on the current device.
    var nativeTimeZones = await FlutterNativeTimezone.getAvailableTimezones();
    _availableLocations = timeZoneDatabase.locations.values
        .where((loc) => nativeTimeZones.contains(loc.name))
        .map((loc) => TimeZoneLocation(loc))
        .toList()
      ..sort((lhs, rhs) =>
          lhs.currentTimeZone.offset.compareTo(rhs.currentTimeZone.offset));

    _currentLocation = TimeZoneLocation.fromName(
        await FlutterNativeTimezone.getLocalTimezone());

    _log.d("Available time zone locations: ${_availableLocations.length}");
  }

  List<TimeZoneLocation> filteredLocations(
    String? query, {
    TimeZoneLocation? exclude,
  }) {
    return _availableLocations
        .where((loc) => loc != exclude && loc.matchesFilter(query))
        .toList();
  }

  /// Returns a [TZDateTime] from the given timestamp and time zone. If
  /// [timeZone] is empty, the current time zone is used.
  TZDateTime dateTime(int timestamp, [String? timeZone]) {
    if (isEmpty(timeZone)) {
      timeZone = currentTimeZone;
    }
    return TZDateTime.fromMillisecondsSinceEpoch(
        getLocation(timeZone!), timestamp);
  }

  /// Returns the current [TZDateTime] at the given time zone, or the
  /// current time zone if [timeZone] is invalid.
  TZDateTime now(String? timeZone) {
    if (isEmpty(timeZone)) {
      return currentDateTime;
    }
    return TZDateTime.now(getLocation(timeZone!));
  }
}

@immutable
class TimeZoneLocation {
  final Location _value;

  const TimeZoneLocation(this._value);

  TimeZoneLocation.fromName(String name) : this(getLocation(name));

  TimeZone get currentTimeZone => _value.currentTimeZone;

  String get name => _value.name;

  String get displayName => name.replaceAll("_", " ");

  String get displayNameUtc => "$displayName ($displayUtc)";

  String get displayUtc {
    var currentOffset = currentTimeZone.offset.abs();
    var offset = "UTC";
    if (currentTimeZone.offset != 0) {
      offset += currentTimeZone.offset < 0 ? "-" : "+";
      offset += DisplayDuration(Duration(milliseconds: currentOffset))
          .formatHoursMinutes();
    }
    return offset;
  }

  Location get value => _value;

  bool matchesFilter(String? filter) {
    if (isEmpty(filter)) {
      return true;
    }

    var searchableText =
        "$displayName ${_value.zones.map((e) => e.abbreviation).join(" ")}";
    return containsTrimmedLowerCase(searchableText, filter!);
  }

  @override
  bool operator ==(Object other) =>
      other is TimeZoneLocation && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
