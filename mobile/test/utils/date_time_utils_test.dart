import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    managers.lib.stubCurrentTime(DateTime(2024, 6, 20, 12));
  });

  TZDateTime dateTime(int year, int month, int day, [int hour = 0]) {
    return TZDateTime(getLocation("America/New_York"), year, month, day, hour);
  }

  String formatOrdinal(BuildContext context, int day) {
    return formatDateAsRecentOrdinal(context, dateTime(2024, 1, day));
  }

  testWidgets("formatDateAsRecentOrdinal returns today", (tester) async {
    var context = await buildContext(tester);
    expect(formatDateAsRecentOrdinal(context, dateTime(2024, 6, 20)), "Today");
  });

  testWidgets("formatDateAsRecentOrdinal returns yesterday", (tester) async {
    var context = await buildContext(tester);
    expect(
      formatDateAsRecentOrdinal(context, dateTime(2024, 6, 19)),
      "Yesterday",
    );
  });

  testWidgets("formatDateAsRecentOrdinal returns weekday within a week", (
    tester,
  ) async {
    var context = await buildContext(tester);
    expect(formatDateAsRecentOrdinal(context, dateTime(2024, 6, 17)), "Monday");
  });

  testWidgets("formatDateAsRecentOrdinal returns month and day in same year", (
    tester,
  ) async {
    var context = await buildContext(tester);
    expect(
      formatDateAsRecentOrdinal(context, dateTime(2024, 6, 8)),
      "June 8th",
    );
  });

  testWidgets("formatDateAsRecentOrdinal includes year in different year", (
    tester,
  ) async {
    var context = await buildContext(tester);
    expect(
      formatDateAsRecentOrdinal(context, dateTime(2018, 12, 8)),
      "December 8th, 2018",
    );
  });

  testWidgets("formatDateAsRecentOrdinal formats 1st", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 1), "January 1st");
  });

  testWidgets("formatDateAsRecentOrdinal formats 2nd", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 2), "January 2nd");
  });

  testWidgets("formatDateAsRecentOrdinal formats 3rd", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 3), "January 3rd");
  });

  testWidgets("formatDateAsRecentOrdinal formats 21st", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 21), "January 21st");
  });

  testWidgets("formatDateAsRecentOrdinal formats 22nd", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 22), "January 22nd");
  });

  testWidgets("formatDateAsRecentOrdinal formats 23rd", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 23), "January 23rd");
  });

  testWidgets("formatDateAsRecentOrdinal formats 31st", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 31), "January 31st");
  });

  testWidgets("formatDateAsRecentOrdinal formats other days with th", (
    tester,
  ) async {
    expect(formatOrdinal(await buildContext(tester), 4), "January 4th");
  });

  testWidgets("formatDateAsRecentOrdinal formats 11th", (tester) async {
    expect(formatOrdinal(await buildContext(tester), 11), "January 11th");
  });

  testWidgets("formatSameDayDateTimeRange omits matching start period", (
    tester,
  ) async {
    var context = await buildContext(tester);
    expect(
      formatSameDayDateTimeRange(
        context,
        dateTime(2024, 6, 8, 6),
        dateTime(2024, 6, 8, 10),
      ),
      "June 8th from 6:00 to 10:00 AM",
    );
  });

  testWidgets("formatSameDayDateTimeRange shows differing periods", (
    tester,
  ) async {
    var context = await buildContext(tester);
    expect(
      formatSameDayDateTimeRange(
        context,
        dateTime(2024, 6, 20, 11),
        dateTime(2024, 6, 20, 13),
      ),
      "Today from 11:00 AM to 1:00 PM",
    );
  });

  testWidgets("formatSameDayDateTimeRange in 24-hour format", (tester) async {
    var context = await buildContext(tester, use24Hour: true);
    expect(
      formatSameDayDateTimeRange(
        context,
        dateTime(2024, 6, 8, 6),
        dateTime(2024, 6, 8, 10),
      ),
      "June 8th from 06:00 to 10:00",
    );
  });
}
