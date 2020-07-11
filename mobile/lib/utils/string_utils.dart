import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

const monthDayFormat = "MMMM d";
const monthDayYearFormat = "MMMM d, yyyy";

/// A trimmed, case-insensitive string comparison.
bool isEqualTrimmedLowercase(String s1, String s2) {
  return s1.trim().toLowerCase() == s2.trim().toLowerCase();
}

/// Supported formats:
///   - %s
/// For each argument, toString() is called to replace %s.
String format(String s, List<dynamic> args) {
  int index = 0;
  return s.replaceAllMapped(RegExp(r'%s'), (Match match) =>
      args[index++].toString());
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

/// Returns a formatted [DateTime] to be displayed to the user. Includes date
/// and time.
///
/// Examples:
///   - Today at 2:35 PM
///   - Yesterday at 2:35 PM
///   - Monday at 2:35 PM
///   - Jan. 8 at 2:35 PM
///   - Dec. 8, 2018 at 2:35 PM
String formatDateTime(BuildContext context, DateTime dateTime, {
  clock = const Clock(),
}) {
  return format(Strings.of(context).dateTimeFormat, [
    formatDateAsRecent(context: context, dateTime: dateTime, clock: clock),
    formatTimeOfDay(context, TimeOfDay.fromDateTime(dateTime)),
  ]);
}

/// Returns a formatted [DateRange] to be displayed to the user.
///
/// Example:
///   Dec. 8, 2018 - Dec. 29, 2018
String formatDateRange(DateRange dateRange) {
  return DateFormat(monthDayYearFormat).format(dateRange.startDate)
      + " - "
      + DateFormat(monthDayYearFormat).format(dateRange.endDate);
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
String formatDateAsRecent({
  @required BuildContext context,
  @required DateTime dateTime,
  clock = const Clock(),
}) {
  final DateTime now = clock.now();

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

String formatLatLng({
  @required BuildContext context,
  @required double lat,
  @required double lng,
  bool includeLabels = true,
}) {
  final int decimalPlaces = 6;

  return format(
    includeLabels
        ? Strings.of(context).latLng : Strings.of(context).latLngNoLabels, [
      lat.toStringAsFixed(decimalPlaces),
      lng.toStringAsFixed(decimalPlaces),
    ],
  );
}

/// Returns formatted text to display the duration, in the format Dd Hh Mm Ss.
///
/// Example:
///   - 0d 5h 30m 0s
String formatDuration({
  BuildContext context,
  int millisecondsDuration,
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

  DisplayDuration duration = DisplayDuration(
    Duration(milliseconds: millisecondsDuration),
    includesDays: includesDays,
    includesHours: includesHours,
    includesMinutes: includesMinutes,
  );

  String result = "";

  maybeAddSpace() {
    if (result.isNotEmpty) {
      result += " ";
    }
  }

  int numberIncluded = 0;

  bool shouldAdd(bool include, int value) {
    return include
        && (!condensed || value > 0)
        && (!showHighestTwoOnly || numberIncluded < 2);
  }

  if (shouldAdd(includesDays, duration.days)) {
    result += format(Strings.of(context).daysFormat, [duration.days]);
    numberIncluded++;
  }

  if (shouldAdd(includesHours, duration.hours)) {
    maybeAddSpace();
    result += format(Strings.of(context).hoursFormat, [duration.hours]);
    numberIncluded++;
  }

  if (shouldAdd(includesMinutes, duration.minutes)) {
    maybeAddSpace();
    result += format(Strings.of(context).minutesFormat, [duration.minutes]);
    numberIncluded++;
  }

  if (shouldAdd(includesSeconds, duration.seconds)) {
    maybeAddSpace();
    result += format(Strings.of(context).secondsFormat, [duration.seconds]);
  }

  // If there is no result and not everything is excluded, default to 0m.
  if (result.isEmpty && (includesSeconds || includesMinutes || includesHours
      || includesDays))
  {
    result += format(Strings.of(context).minutesFormat, [0]);
  }

  return result;
}