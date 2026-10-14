import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_format.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

import 'string_utils.dart';

/// Returns a formatted date, using the full month name and an ordinal day
/// when the date isn't recent.
///
/// Examples:
///   - Today
///   - Yesterday
///   - Monday
///   - June 8th
///   - December 8th, 2018
String formatDateAsRecentOrdinal(BuildContext context, TZDateTime dateTime) {
  final now = TimeManager.get.currentDateTime;
  if (isSameDate(dateTime, now) ||
      isYesterday(now, dateTime) ||
      isWithinOneWeek(dateTime, now)) {
    return formatDateAsRecent(dateTime);
  }

  final monthDay = Strings.of(context).monthDayOrdinalFormat(
    DateFormats.localized(L10n.get.lib.dateFormatMonthFull).format(dateTime),
    dateTime.day.toString(),
  );

  return isSameYear(dateTime, now)
      ? monthDay
      : Strings.of(
          context,
        ).dateWithYearFormat(monthDay, dateTime.year.toString());
}

/// Returns a formatted time range for [start] and [end], which are expected
/// to be on the same date. The date is only shown once, and in 12-hour time,
/// the start's period is omitted when it matches the end's.
///
/// Examples:
///   - June 8th from 6:30 to 10:30 AM
///   - Today from 11:30 AM to 1:30 PM
///   - June 8th from 06:30 to 10:30
String formatSameDayDateTimeRange(
  BuildContext context,
  TZDateTime start,
  TZDateTime end,
) {
  final startTime = TimeOfDay.fromDateTime(start);
  final endTime = TimeOfDay.fromDateTime(end);

  return Strings.of(context).dateTimeRangeSameDayFormat(
    formatDateAsRecentOrdinal(context, start),
    startTime.period == endTime.period
        ? _formatTimeOfDayWithoutPeriod(context, startTime)
        : formatTimeOfDay(context, startTime),
    formatTimeOfDay(context, endTime),
  );
}

/// Returns [time] formatted without its day period (AM/PM), if the current
/// time format puts the period after the time. Otherwise, returns the
/// normally formatted time.
String _formatTimeOfDayWithoutPeriod(BuildContext context, TimeOfDay time) {
  final localizations = MaterialLocalizations.of(context);
  if (localizations.timeOfDayFormat(
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      ) !=
      TimeOfDayFormat.h_colon_mm_space_a) {
    return formatTimeOfDay(context, time);
  }

  return "${localizations.formatHour(time)}:"
      "${localizations.formatMinute(time)}";
}
