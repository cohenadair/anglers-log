import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/time.dart';

import '../app_manager.dart';
import '../i18n/strings.dart';
import '../utils/string_utils.dart';

const monthDayFormat = "MMM d";
const monthDayYearFormat = "MMM d, yyyy";
const monthDayYearFormatFull = "MMMM d, yyyy";

enum DurationUnit { days, hours, minutes }

/// A representation of a [Duration] object meant to be shown to the user. Units
/// are split by largest possible. For example, the hours property is the
/// number of hours in the duration, minus the number of days.
class DisplayDuration {
  final Duration _duration;
  final bool _includesDays;
  final bool _includesHours;
  final bool _includesMinutes;

  DisplayDuration(
    this._duration, {
    bool includesDays = true,
    bool includesHours = true,
    bool includesMinutes = true,
  })  : _includesDays = includesDays,
        _includesHours = includesHours,
        _includesMinutes = includesMinutes;

  int get days => _duration.inDays;

  int get hours {
    if (_includesDays) {
      return _duration.inHours.remainder(Duration.hoursPerDay);
    } else {
      return _duration.inHours;
    }
  }

  int get minutes {
    if (_includesHours) {
      return _duration.inMinutes.remainder(Duration.minutesPerHour);
    } else {
      return _duration.inMinutes;
    }
  }

  int get seconds {
    if (_includesMinutes) {
      return _duration.inSeconds.remainder(Duration.secondsPerMinute);
    } else {
      return _duration.inSeconds;
    }
  }
}

bool isSameYear(DateTime a, DateTime b) {
  return a.year == b.year;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.month == b.month;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.day == b.day;
}

bool isSameTimeOfDay(DateTime a, DateTime b) {
  return TimeOfDay.fromDateTime(a) == TimeOfDay.fromDateTime(b);
}

/// Returns `true` if `a` is later in the day than `b`.
bool isLater(TimeOfDay a, TimeOfDay b) {
  return a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
}

/// Returns `true` if the given [DateTime] comes after `now`, to minute
/// accuracy.
bool isInFutureWithMinuteAccuracy(DateTime dateTime, DateTime now) {
  var newDateTime = dateTimeToMinuteAccuracy(dateTime);
  var newNow = dateTimeToMinuteAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns `true` if the given [DateTime] comes after `now`, to day
/// accuracy.
bool isInFutureWithDayAccuracy(DateTime dateTime, DateTime now) {
  var newDateTime = dateTimeToDayAccuracy(dateTime);
  var newNow = dateTimeToDayAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns true if the given DateTime objects are equal. Compares
/// only year, month, and day.
bool isSameDate(DateTime a, DateTime b) {
  return isSameYear(a, b) && isSameMonth(a, b) && isSameDay(a, b);
}

bool isYesterday(DateTime today, DateTime yesterday) {
  return isSameDate(yesterday, today.subtract(aDay));
}

/// Returns true of the  given DateTime objects are within one week of one
/// another.
bool isWithinOneWeek(DateTime a, DateTime b) {
  return a.difference(b).inMilliseconds.abs() <= aWeek.inMilliseconds;
}

/// Returns a [DateTime] object with the given [DateTime] and [TimeOfDay]
/// combined.  Accurate to the millisecond.
///
/// Due to the lack of granularity in [TimeOfDay], the seconds and milliseconds
/// value of the result are that of the given [DateTime].
DateTime combine(DateTime dateTime, TimeOfDay timeOfDay) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, timeOfDay.hour,
      timeOfDay.minute, dateTime.second, dateTime.millisecond);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// minutes set to 0.
DateTime dateTimeToMinuteAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
      dateTime.minute);
}

/// Returns a new [DateTime] object, with time properties more granular than
/// day set to 0.
DateTime dateTimeToDayAccuracy(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

/// Returns a [DateTime] representing the start of the week to which `now`
/// belongs.
DateTime startOfWeek(DateTime now) {
  return dateTimeToDayAccuracy(now).subtract(Duration(days: now.weekday - 1));
}

/// Returns a [DateTime] representing the start of the month to which `now`
/// belongs.
DateTime startOfMonth(DateTime now) {
  return DateTime(now.year, now.month);
}

/// Returns a [DateTime] representing the start of the year to which `now`
/// belongs.
DateTime startOfYear(DateTime now) {
  return DateTime(now.year);
}

/// Calculates week number from a date as per
/// https://en.wikipedia.org/wiki/ISO_week_date#Calculation.
int weekOfYear(DateTime date) {
  return ((dayOfYear(date) - date.weekday + 10) / DateTime.daysPerWeek).floor();
}

/// Returns the day of the year for the given [DateTime]. For example, 185.
int dayOfYear(DateTime date) {
  return int.parse(DateFormat("D").format(date));
}

/// Returns a formatted [String] for a time of day. The format depends on a
/// combination of the current locale and the user's system time format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
String formatTimeOfDay(BuildContext context, TimeOfDay time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    time,
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

String formatTimestampTime(BuildContext context, Int64 timestamp) {
  return formatTimeOfDay(
      context,
      TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt())));
}

/// Returns a formatted [DateTime] to be displayed to the user. Includes date
/// and time.
///
/// Examples:
///   - Today at 2:35 PM
///   - Yesterday at 2:35 PM
///   - Monday at 2:35 PM
///   - Jan. 8 at 2:35 PM
///   - Dec. 8, 2018 at 2:35 PM
String formatDateTime(BuildContext context, DateTime dateTime) {
  return format(Strings.of(context).dateTimeFormat, [
    formatDateAsRecent(context, dateTime),
    formatTimeOfDay(context, TimeOfDay.fromDateTime(dateTime)),
  ]);
}

String formatTimestamp(BuildContext context, int timestamp) {
  return formatDateTime(
      context, DateTime.fromMillisecondsSinceEpoch(timestamp));
}

/// Returns a [Timestamp] as a searchable [String]. This value should not be
/// shown to users, but to be used for searching through list items that include
/// timestamps.
///
/// The value returned is just a concatenation of different ways of representing
/// a date and time.
String timestampToSearchString(BuildContext context, int timestamp) {
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${formatDateTime(context, dateTime)} "
      "${DateFormat(monthDayYearFormatFull).format(dateTime)}";
}

/// Returns a formatted [DateTime] to be displayed to the user. Includes
/// date only.
///
/// Examples:
///   - Today
///   - Yesterday
///   - Monday
///   - Jan. 8
///   - Dec. 8, 2018
String formatDateAsRecent(BuildContext context, DateTime dateTime) {
  final now = AppManager.of(context).timeManager.currentDateTime;

  if (isSameDate(dateTime, now)) {
    // Today.
    return Strings.of(context).today;
  } else if (isYesterday(now, dateTime)) {
    // Yesterday.
    return Strings.of(context).yesterday;
  } else if (isWithinOneWeek(dateTime, now)) {
    // 2 days ago to 6 days ago.
    return DateFormat("EEEE").format(dateTime);
  } else if (isSameYear(dateTime, now)) {
    // Same year.
    return DateFormat(monthDayFormat).format(dateTime);
  } else {
    // Different year.
    return DateFormat(monthDayYearFormat).format(dateTime);
  }
}

/// Returns formatted text to display the duration, in the format Dd Hh Mm Ss.
///
/// Example:
///   - 0d 5h 30m 0s
String formatDuration({
  required BuildContext context,
  required int millisecondsDuration,
  bool includesDays = true,
  bool includesHours = true,
  bool includesMinutes = true,
  bool includesSeconds = true,

  /// If `true`, values equal to 0 will not be included.
  bool condensed = false,

  /// If `true`, only the largest 2 quantities will be shown.
  ///
  /// Examples:
  ///   - 1d 12h
  ///   - 12h 30m
  ///   - 30m 45s
  bool showHighestTwoOnly = false,

  /// The largest [DurationUnit] to use. For example, if equal to
  /// [DurationUnit.hours], 2 days and 3 hours will be formatted as `51h`
  /// rather than `2d 3h`. The same effect can be done by setting `includesDays`
  /// to `false`.
  ///
  /// This is primarily meant for use with a user-preference where the
  /// [DurationUnit] is read from [SharedPreferences].
  DurationUnit largestDurationUnit = DurationUnit.days,
}) {
  includesDays = includesDays && largestDurationUnit == DurationUnit.days;
  includesHours = includesHours && largestDurationUnit != DurationUnit.minutes;

  var duration = DisplayDuration(
    Duration(milliseconds: millisecondsDuration),
    includesDays: includesDays,
    includesHours: includesHours,
    includesMinutes: includesMinutes,
  );

  var result = "";

  maybeAddSpace() {
    if (result.isNotEmpty) {
      result += " ";
    }
  }

  var numberIncluded = 0;

  bool shouldAdd(int value, {required bool include}) {
    return include &&
        (!condensed || value > 0) &&
        (!showHighestTwoOnly || numberIncluded < 2);
  }

  if (shouldAdd(duration.days, include: includesDays)) {
    result += format(Strings.of(context).daysFormat, [duration.days]);
    numberIncluded++;
  }

  if (shouldAdd(duration.hours, include: includesHours)) {
    maybeAddSpace();
    result += format(Strings.of(context).hoursFormat, [duration.hours]);
    numberIncluded++;
  }

  if (shouldAdd(duration.minutes, include: includesMinutes)) {
    maybeAddSpace();
    result += format(Strings.of(context).minutesFormat, [duration.minutes]);
    numberIncluded++;
  }

  if (shouldAdd(duration.seconds, include: includesSeconds)) {
    maybeAddSpace();
    result += format(Strings.of(context).secondsFormat, [duration.seconds]);
  }

  // If there is no result and not everything is excluded, default to 0m.
  if (result.isEmpty &&
      (includesSeconds || includesMinutes || includesHours || includesDays)) {
    result += format(Strings.of(context).minutesFormat, [0]);
  }

  return result;
}
