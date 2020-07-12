import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';

import '../test_utils.dart';

void main() {
  group("IsInFutureWithMinuteAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2014, 6, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 4, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 14, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 11, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 12, 29, 46, 10001), now), isFalse);
    });

    test("Value should be in the future", () {
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2016, 4, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 6, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 16, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 13, 29, 44, 9999), now), isTrue);
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 12, 30, 44, 10001), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 12, 30, 45, 9999), now), isFalse);
      expect(isInFutureWithMinuteAccuracy(
          DateTime(2015, 5, 15, 12, 30, 44, 9999), now), isFalse);
    });
  });

  group("IsInFutureWithDayAccuracy", () {
    DateTime now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(isInFutureWithDayAccuracy(
          DateTime(2014, 6, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 4, 16, 13, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 5, 14, 13, 31, 46, 10001), now), isFalse);
    });

    test("Value should be in the future", () {
      expect(isInFutureWithDayAccuracy(
          DateTime(2016, 4, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 6, 14, 11, 29, 44, 9999), now), isTrue);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 5, 16, 11, 29, 44, 9999), now), isTrue);
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 5, 15, 11, 31, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 5, 15, 12, 29, 46, 10001), now), isFalse);
      expect(isInFutureWithDayAccuracy(
          DateTime(2015, 5, 15, 13, 29, 44, 9999), now), isFalse);
    });
  });

  group("DateTime", () {
    test("Days calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.days, equals(31));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 10),
      );

      expect(range.days, equals(9));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.days, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1, 15, 30),
      );

      expect(range.days, equals(0.6458333333333334));
    });

    test("Weeks calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.weeks, equals(4.428571428571429));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 3, 10),
      );

      expect(range.weeks, equals(9.714285714285714));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.weeks, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 4),
      );

      expect(range.weeks, equals(0.42857142857142855));
    });

    test("Months calculated correctly", () {
      DateRange range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 2, 1),
      );

      expect(range.months, equals(1.0333333333333334));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 3, 10),
      );

      expect(range.months, equals(2.2666666666666666));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 1),
      );

      expect(range.months, equals(0));

      range = DateRange(
        startDate: DateTime(2019, 1, 1),
        endDate: DateTime(2019, 1, 20),
      );

      expect(range.months, equals(0.6333333333333333));
    });
  });

  assertStatsDateRange({
    @required DisplayDateRange dateRange,
    @required DateTime now,
    @required DateTime expectedStart,
    DateTime expectedEnd,
  }) {
    DateRange range = dateRange.getValue(now);
    expect(range.startDate, equals(expectedStart));
    expect(range.endDate, equals(expectedEnd ?? now));
  }

  group("StatsDateRange.today", () {
    test("Today", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.today,
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 15),
      );
    });
  });

  group("StatsDateRange.yesterday", () {
    test("Yesterday", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.yesterday,
        now: DateTime(2019, 1, 15, 15, 30),
        expectedStart: DateTime(2019, 1, 14),
        expectedEnd: DateTime(2019, 1, 15),
      );
    });
  });

  group("StatsDateRange.thisWeek", () {
    test("This week - year overlap", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("This week - within the same month", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("This week - same day as week start", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("This week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisWeek,
        now: DateTime(2019, 3, 10, 15, 30),
        expectedStart: DateTime(2019, 3, 4, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisMonth", () {
    test("This month - first day", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 2, 1, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("This month - last day", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 3, 31, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 2, 28, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
      );

      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 4, 30, 15, 30),
        expectedStart: DateTime(2019, 4, 1, 0, 0, 0),
      );
    });

    test("This month - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 5, 1, 0, 0, 0),
      );
    });

    test("This month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.thisYear", () {
    test("This year - first day", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisYear,
        now: DateTime(2019, 1, 1, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - last day", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisYear,
        now: DateTime(2019, 12, 31, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - somewhere in the middle", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisYear,
        now: DateTime(2019, 5, 17, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("This year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.thisYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastWeek", () {
    test("Last week - year overlap", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastWeek,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 24, 0, 0, 0),
        expectedEnd: DateTime(2018, 12, 31, 0, 0, 0),
      );
    });

    test("Last week - within the same month", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastWeek,
        now: DateTime(2019, 2, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 4, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 11, 0, 0, 0),
      );
    });

    test("Last week - same day as week start", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastWeek,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 28, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 4, 0, 0, 0),
      );
    });

    test("Last week - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastWeek,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 3, 23, 0, 0),
        expectedEnd: DateTime(2019, 3, 11, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastMonth", () {
    test("Last month - year overlap", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastMonth,
        now: DateTime(2019, 1, 3, 15, 30),
        expectedStart: DateTime(2018, 12, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last month - within same year", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastMonth,
        now: DateTime(2019, 2, 4, 15, 30),
        expectedStart: DateTime(2019, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 2, 1, 0, 0, 0),
      );
    });

    test("Last month - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastMonth,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 3, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.lastYear", () {
    test("Last year - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastYear,
        now: DateTime(2019, 12, 26, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });

    test("Last year - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.lastYear,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 1, 1, 0, 0, 0),
        expectedEnd: DateTime(2019, 1, 1, 0, 0, 0),
      );
    });
  });

  group("StatsDateRange.last7Days", () {
    test("Last 7 days - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last7Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 13, 15, 30, 0),
      );
    });

    test("Last 7 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last7Days,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 3, 6, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last14Days", () {
    test("Last 14 days - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last14Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 2, 6, 15, 30, 0),
      );
    });

    test("Last 14 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last14Days,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 27, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last30Days", () {
    test("Last 30 days - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last30Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2019, 1, 21, 15, 30, 0),
      );
    });

    test("Last 30 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last30Days,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 2, 11, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last60Days", () {
    test("Last 60 days - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last60Days,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 12, 22, 15, 30, 0),
      );
    });

    test("Last 60 days - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last60Days,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2019, 1, 12, 14, 30, 0),
      );
    });
  });

  group("StatsDateRange.last12Months", () {
    test("Last 12 months - normal case", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last12Months,
        now: DateTime(2019, 2, 20, 15, 30),
        expectedStart: DateTime(2018, 2, 20, 15, 30),
      );
    });

    test("Last 12 months - daylight savings change", () {
      assertStatsDateRange(
        dateRange: DisplayDateRange.last12Months,
        now: DateTime(2019, 3, 13, 15, 30),
        expectedStart: DateTime(2018, 3, 13, 15, 30),
      );
    });
  });

  group("Format duration", () {
    testWidgets("0 duration", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: 0,
      ), "0d 0h 0m 0s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: 0,
        condensed: true,
      ), "0m");
    });

    testWidgets("All units", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
      ), "2d 5h 45m 30s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
      ), "2d 5h 45m 30s");
    });

    testWidgets("Days only", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
      ), "2d 0h 0m 0s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
      ), "2d");
    });

    testWidgets("Hours only", (WidgetTester tester) async {
      int ms = Duration(
        hours: 10,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
      ), "0d 10h 0m 0s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
      ), "10h");
    });

    testWidgets("Minutes only", (WidgetTester tester) async {
      int ms = Duration(
        minutes: 20,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
      ), "0d 0h 20m 0s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
      ), "20m");
    });

    testWidgets("Seconds only", (WidgetTester tester) async {
      int ms = Duration(
        seconds: 50,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
      ), "0d 0h 0m 50s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
      ), "50s");
    });

    testWidgets("Excluding days", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        includesDays: false,
      ), "53h 45m 30s");
    });

    testWidgets("Excluding hours", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        includesDays: false,
        includesHours: false,
      ), "3225m 30s");
    });

    testWidgets("Excluding minutes", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        includesDays: false,
        includesHours: false,
        includesMinutes: false,
      ), "193530s");
    });

    testWidgets("Excluding all", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        includesDays: false,
        includesHours: false,
        includesMinutes: false,
        includesSeconds: false,
      ), "");
    });

    testWidgets("Show highest two only", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        showHighestTwoOnly: true,
      ), "2d 5h");

      ms = Duration(
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
        showHighestTwoOnly: true,
      ), "5h 45m");

      ms = Duration(
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
        showHighestTwoOnly: true,
      ), "45m 30s");

      ms = Duration(
        seconds: 30,
      ).inMilliseconds;

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        condensed: true,
        showHighestTwoOnly: true,
      ), "30s");
    });

    testWidgets("With duration unit", (WidgetTester tester) async {
      int ms = Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      BuildContext context = await buildContext(tester);

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        largestDurationUnit: DurationUnit.hours,
      ), "53h 45m 30s");

      expect(formatDuration(
        context: context,
        millisecondsDuration: ms,
        largestDurationUnit: DurationUnit.minutes,
      ), "3225m 30s");
    });
  });
}