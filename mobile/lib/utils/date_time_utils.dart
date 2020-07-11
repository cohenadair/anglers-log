import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:quiver/time.dart';

enum DurationUnit {
  days,
  hours,
  minutes
}

/// A representation of a [Duration] object meant to be shown to the user. Units
/// are split by largest possible. For example, the hours property is the
/// number of hours in the duration, minus the number of days.
class DisplayDuration {
  final Duration _duration;
  final bool _includesDays;
  final bool _includesHours;
  final bool _includesMinutes;

  DisplayDuration(this._duration, {
    bool includesDays = true,
    bool includesHours = true,
    bool includesMinutes = true,
  }) : _includesDays = includesDays,
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

class DateRange {
  final int _daysInMonth = 30;

  final DateTime startDate;
  final DateTime endDate;

  DateRange({this.startDate, this.endDate})
      : assert(startDate.isAtSameMomentAs(endDate) ||
          startDate.isBefore(endDate));

  int get startMs => startDate.millisecondsSinceEpoch;
  int get endMs => endDate.millisecondsSinceEpoch;
  int get durationMs => endMs - startMs;

  /// The number of days spanned by the [DateRange]. This is calculated by
  /// taking the total [Duration] of the [DateRange] and dividing it by
  /// [Duration.millisecondsPerDay].
  num get days => durationMs / Duration.millisecondsPerDay;

  /// The number of weeks spanned by the [DateRange]. This is calculated by
  /// taking the total [Duration] of the [DateRange] and dividing it by
  /// the number of milliseconds in a week. A week length is defined by
  /// [DateTime.daysPerWeek].
  num get weeks =>
      durationMs / (Duration.millisecondsPerDay * DateTime.daysPerWeek);

  /// The number of months spanned by the [DateRange]. This is calculated by
  /// taking the total [Duration] of the [DateRange] and dividing it by
  /// the number of milliseconds in a month. A month length is defined as 30
  /// days.
  num get months => durationMs / (Duration.millisecondsPerDay * _daysInMonth);
}

/// A pre-defined set of date ranges meant for user section. Includes ranges
/// such as "This week", "This month", "Last year", etc.
@immutable
class DisplayDateRange {
  static final allDates = DisplayDateRange._(
    id: "allDates",
    getValue: (DateTime now) => DateRange(
      startDate: DateTime.fromMicrosecondsSinceEpoch(0),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationAllDates,
  );

  static final today = DisplayDateRange._(
    id: "today",
    getValue: (DateTime now) => DateRange(
      startDate: dateTimeToDayAccuracy(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationToday,
  );

  static final yesterday = DisplayDateRange._(
    id: "yesterday",
    getValue: (DateTime now) => DateRange(
      startDate: dateTimeToDayAccuracy(now).subtract(Duration(days: 1)),
      endDate: dateTimeToDayAccuracy(now),
    ),
    getTitle: (context) => Strings.of(context).analysisDurationYesterday,
  );

  static final thisWeek = DisplayDateRange._(
    id: "thisWeek",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfWeek(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisWeek,
  );

  static final thisMonth = DisplayDateRange._(
    id: "thisMonth",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfMonth(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisMonth,
  );

  static final thisYear = DisplayDateRange._(
    id: "thisYear",
    getValue: (DateTime now) => DateRange(
      startDate: getStartOfYear(now),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationThisYear,
  );

  static final lastWeek = DisplayDateRange._(
    id: "lastWeek",
    getValue: (DateTime now) {
      DateTime endOfLastWeek = getStartOfWeek(now);
      DateTime startOfLastWeek = endOfLastWeek.subtract(Duration(
          days: DateTime.daysPerWeek),
      );
      return DateRange(startDate: startOfLastWeek, endDate: endOfLastWeek);
    },
    getTitle: (context) => Strings.of(context).analysisDurationLastWeek,
  );

  static final lastMonth = DisplayDateRange._(
    id: "lastMonth",
    getValue: (DateTime now) {
      DateTime endOfLastMonth = getStartOfMonth(now);
      int year = now.year;
      int month = now.month - 1;
      if (month < DateTime.january) {
        month = DateTime.december;
        year -= 1;
      }
      return DateRange(
        startDate: DateTime(year, month),
        endDate: endOfLastMonth,
      );
    },
    getTitle: (context) => Strings.of(context).analysisDurationLastMonth,
  );

  static final lastYear = DisplayDateRange._(
    id: "lastYear",
    getValue: (DateTime now) => DateRange(
      startDate: DateTime(now.year - 1),
      endDate: getStartOfYear(now),
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLastYear,
  );

  static final last7Days = DisplayDateRange._(
    id: "last7Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 7)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast7Days,
  );

  static final last14Days = DisplayDateRange._(
    id: "last14Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 14)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast14Days,
  );

  static final last30Days = DisplayDateRange._(
    id: "last30Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 30)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast30Days,
  );

  static final last60Days = DisplayDateRange._(
    id: "last60Days",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 60)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast60Days,
  );

  static final last12Months = DisplayDateRange._(
    id: "last12Months",
    getValue: (DateTime now) => DateRange(
      startDate: now.subtract(Duration(days: 365)),
      endDate: now,
    ),
    getTitle: (context) => Strings.of(context).analysisDurationLast12Months,
  );

  static final custom = DisplayDateRange._(
    id: "custom",
    getValue: (now) => DisplayDateRange.thisMonth.getValue(now),
    getTitle: (context) => Strings.of(context).analysisDurationCustom,
  );

  static final all = [
    allDates, today, yesterday, thisWeek, thisMonth, thisYear, lastWeek,
    lastMonth, lastYear, last7Days, last14Days, last30Days, last60Days,
    last12Months, custom,
  ];

  /// Returns the [DisplayDateRange] for the given ID, or `null` if none exists.
  static DisplayDateRange of(String id) {
    try {
      return all.firstWhere((range) => range.id == id);
    } on StateError {
      return null;
    }
  }

  final String id;
  final DateRange Function(DateTime now) getValue;
  final String Function(BuildContext context) getTitle;

  DisplayDateRange._({
    this.id, this.getValue, this.getTitle
  });

  /// Used to create a [DisplayDateRange] with custom start and end dates, but
  /// with the same ID as [DisplayDateRange.custom].
  DisplayDateRange.newCustom({
    DateRange Function(DateTime now) getValue,
    String Function(BuildContext context) getTitle,
  }) : this._(
    id: custom.id,
    getValue: getValue,
    getTitle: getTitle,
  );

  DateRange get value => getValue(DateTime.now());

  @override
  bool operator ==(other) {
    return other is DisplayDateRange && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
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
  DateTime newDateTime = dateTimeToMinuteAccuracy(dateTime);
  DateTime newNow = dateTimeToMinuteAccuracy(now);
  return newDateTime.isAfter(newNow);
}

/// Returns `true` if the given [DateTime] comes after `now`, to day
/// accuracy.
bool isInFutureWithDayAccuracy(DateTime dateTime, DateTime now) {
  DateTime newDateTime = dateTimeToDayAccuracy(dateTime);
  DateTime newNow = dateTimeToDayAccuracy(now);
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
DateTime getStartOfWeek(DateTime now) {
  return dateTimeToDayAccuracy(now).subtract(Duration(days: now.weekday - 1));
}

/// Returns a [DateTime] representing the start of the month to which `now`
/// belongs.
DateTime getStartOfMonth(DateTime now) {
  return DateTime(now.year, now.month);
}

/// Returns a [DateTime] representing the start of the year to which `now`
/// belongs.
DateTime getStartOfYear(DateTime now) {
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