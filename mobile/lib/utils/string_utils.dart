import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/time.dart';

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
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat
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
String formatDateTime({
  BuildContext context,
  DateTime dateTime,
  clock = const Clock(),
}) {
  return format(Strings.of(context).dateTimeFormat, [
    formatDateAsRecent(context: context, dateTime: dateTime, clock: clock),
    formatTimeOfDay(context, TimeOfDay.fromDateTime(dateTime)),
  ]);
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
}) {
  final int decimalPlaces = 6;

  return format(
    Strings.of(context).latLng, [
      lat.toStringAsFixed(decimalPlaces),
      lng.toStringAsFixed(decimalPlaces),
    ],
  );
}