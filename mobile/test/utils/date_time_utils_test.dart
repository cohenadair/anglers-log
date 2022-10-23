import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/date_time_utils.dart' as date_time_utils;
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  setUp(() {
    initializeTimeZones();
  });

  test("DisplayDuration formatHoursMinutes", () {
    expect(
      date_time_utils.DisplayDuration(const Duration(
        milliseconds: 5 * Duration.millisecondsPerHour +
            5 * Duration.millisecondsPerMinute,
      )).formatHoursMinutes(),
      "05:05",
    );
    expect(
      date_time_utils.DisplayDuration(const Duration(
        milliseconds: 15 * Duration.millisecondsPerHour +
            15 * Duration.millisecondsPerMinute,
      )).formatHoursMinutes(),
      "15:15",
    );
  });

  test("isLater", () {
    expect(
      date_time_utils.isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 8, minute: 30)),
      true,
    );
    expect(
      date_time_utils.isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 30)),
      false,
    );
    expect(
      date_time_utils.isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 45)),
      false,
    );
    expect(
      date_time_utils.isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 15)),
      true,
    );
  });

  group("isInFutureWithMinuteAccuracy", () {
    TZDateTime now() => dateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2014, 6, 16, 13, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 4, 16, 13, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 14, 13, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 11, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 12, 29, 46, 10001), now()),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2016, 4, 14, 11, 29, 44, 9999), now()),
        isTrue,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 6, 14, 11, 29, 44, 9999), now()),
        isTrue,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 16, 11, 29, 44, 9999), now()),
        isTrue,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 13, 29, 44, 9999), now()),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 12, 30, 44, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 12, 30, 45, 9999), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithMinuteAccuracy(
            dateTime(2015, 5, 15, 12, 30, 44, 9999), now()),
        isFalse,
      );
    });
  });

  group("isInFutureWithDayAccuracy", () {
    TZDateTime now() => dateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2014, 6, 16, 13, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 4, 16, 13, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 5, 14, 13, 31, 46, 10001), now()),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2016, 4, 14, 11, 29, 44, 9999), now()),
        isTrue,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 6, 14, 11, 29, 44, 9999), now()),
        isTrue,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 5, 16, 11, 29, 44, 9999), now()),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 5, 15, 11, 31, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 5, 15, 12, 29, 46, 10001), now()),
        isFalse,
      );
      expect(
        date_time_utils.isInFutureWithDayAccuracy(
            dateTime(2015, 5, 15, 13, 29, 44, 9999), now()),
        isFalse,
      );
    });
  });

  testWidgets("combine", (tester) async {
    initializeTimeZones();
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentLocation)
        .thenReturn(TimeZoneLocation.fromName("America/New_York"));

    var context = await buildContext(tester);
    expect(date_time_utils.combine(context, null, null), isNull);
    expect(
        date_time_utils.combine(
            context, null, const TimeOfDay(hour: 5, minute: 5)),
        isNotNull);
    expect(date_time_utils.combine(context, dateTime(2020), null), isNotNull);

    expect(
      date_time_utils.combine(context, dateTime(2020, 10, 26, 15, 30, 20, 1000),
          const TimeOfDay(hour: 16, minute: 45)),
      dateTime(2020, 10, 26, 16, 45, 20, 1000),
    );

    var actual = date_time_utils.combine(
        context, null, const TimeOfDay(hour: 16, minute: 45));
    var expected = dateTime(0, 1, 1, 16, 45);
    expect(actual, expected);
    expect(actual!.locationName, "America/New_York");
  });

  test("dateTimeToDayAccuracy", () {
    expect(
        date_time_utils
            .dateTimeToDayAccuracy(dateTime(2020, 10, 26, 15, 30, 20, 1000)),
        dateTime(2020, 10, 26, 0, 0, 0, 0));

    initializeTimeZones();

    expect(
      date_time_utils.dateTimeToDayAccuracy(
        dateTime(2020, 10, 26, 15, 30, 20, 1000),
        "America/Chicago",
      ),
      TZDateTime(getLocation("America/Chicago"), 2020, 10, 26, 0, 0, 0, 0),
    );
  });

  test("getStartOfWeek", () {
    expect(date_time_utils.startOfWeek(dateTime(2020, 9, 24)),
        dateTime(2020, 9, 21));
  });

  test("weekOfYear", () {
    expect(date_time_utils.weekOfYear(dateTime(2020, 2, 15)), 7);
  });

  test("dayOfYear", () {
    expect(date_time_utils.dayOfYear(dateTime(2020, 2, 15)), 46);
  });

  testWidgets("formatTimeOfDay", (tester) async {
    expect(
      date_time_utils.formatTimeOfDay(
          await buildContext(tester), const TimeOfDay(hour: 15, minute: 30)),
      "3:30 PM",
    );
    expect(
      date_time_utils.formatTimeOfDay(
          await buildContext(tester, use24Hour: true),
          const TimeOfDay(hour: 15, minute: 30)),
      "15:30",
    );
  });

  testWidgets("formatHourRange", (tester) async {
    // 11-midnight
    expect(
      date_time_utils.formatHourRange(await buildContext(tester), 23, 24),
      "11:00 PM to 12:00 AM",
    );

    // Other
    expect(
      date_time_utils.formatHourRange(await buildContext(tester), 8, 10),
      "8:00 AM to 10:00 AM",
    );
  });

  testWidgets("timestampToSearchString", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 9, 24));
    expect(
      date_time_utils.timestampToSearchString(
          await buildContext(tester, appManager: appManager),
          dateTime(2020, 9, 24).millisecondsSinceEpoch,
          null),
      "Today at 12:00 AM September 24, 2020",
    );
  });

  testWidgets("formatDateAsRecent", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 9, 24));
    var context = await buildContext(tester, appManager: appManager);

    expect(
      date_time_utils.formatDateAsRecent(
          context, TZDateTime(getLocation("America/New_York"), 2020, 9, 24)),
      "Today",
    );
    expect(
      date_time_utils.formatDateAsRecent(
          context, TZDateTime(getLocation("America/New_York"), 2020, 9, 23)),
      "Yesterday",
    );
    expect(
      date_time_utils.formatDateAsRecent(
          context, TZDateTime(getLocation("America/New_York"), 2020, 9, 22)),
      "Tuesday",
    );
    expect(
      date_time_utils.formatDateAsRecent(
        context,
        TZDateTime(getLocation("America/New_York"), 2020, 9, 22),
        abbreviated: true,
      ),
      "Tue",
    );
    expect(
      date_time_utils.formatDateAsRecent(
          context, TZDateTime(getLocation("America/New_York"), 2020, 8, 22)),
      "Aug 22",
    );
    expect(
      date_time_utils.formatDateAsRecent(
          context, TZDateTime(getLocation("America/New_York"), 2019, 8, 22)),
      "Aug 22, 2019",
    );
  });

  testWidgets("formatDateTime exclude midnight", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(dateTime(2020, 9, 24));
    var context = await buildContext(tester, appManager: appManager);

    expect(
      date_time_utils.formatDateTime(
        context,
        TZDateTime(getLocation("America/New_York"), 2020, 8, 22),
        excludeMidnight: false,
      ),
      "Aug 22 at 12:00 AM",
    );
    expect(
      date_time_utils.formatDateTime(
        context,
        TZDateTime(getLocation("America/New_York"), 2020, 8, 22),
        excludeMidnight: true,
      ),
      "Aug 22",
    );
  });

  group("Format duration", () {
    testWidgets("0 duration", (tester) async {
      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: 0,
        ),
        "0y 0d 0h 0m 0s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: 0,
          condensed: true,
        ),
        "0m",
      );
    });

    testWidgets("All units", (tester) async {
      var ms = const Duration(
        days: 385,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "1y 20d 5h 45m 30s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
        ),
        "1y 20d 5h 45m 30s",
      );
    });

    testWidgets("Years only", (tester) async {
      var ms = const Duration(
        days: 385,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "1y 20d 0h 0m 0s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 1,
        ),
        "1y",
      );
    });

    testWidgets("Days only", (tester) async {
      var ms = const Duration(
        days: 2,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 2d 0h 0m 0s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
        ),
        "2d",
      );
    });

    testWidgets("Hours only", (tester) async {
      var ms = const Duration(
        hours: 10,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 10h 0m 0s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
        ),
        "10h",
      );
    });

    testWidgets("Minutes only", (tester) async {
      var ms = const Duration(
        minutes: 20,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 0h 20m 0s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
        ),
        "20m",
      );
    });

    testWidgets("Seconds only", (tester) async {
      var ms = const Duration(
        seconds: 50,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 0h 0m 50s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
        ),
        "50s",
      );
    });

    testWidgets("Excluding days", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          includesDays: false,
        ),
        "0y 53h 45m 30s",
      );
    });

    testWidgets("Excluding hours", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          includesYears: false,
          includesDays: false,
          includesHours: false,
        ),
        "3225m 30s",
      );
    });

    testWidgets("Excluding minutes", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          includesYears: false,
          includesDays: false,
          includesHours: false,
          includesMinutes: false,
        ),
        "193530s",
      );
    });

    testWidgets("Excluding all", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          includesYears: false,
          includesDays: false,
          includesHours: false,
          includesMinutes: false,
          includesSeconds: false,
        ),
        "",
      );
    });

    testWidgets("Show highest two only", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          numberOfQuantities: 2,
        ),
        "0y 2d",
      );

      ms = const Duration(
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 2,
        ),
        "5h 45m",
      );

      ms = const Duration(
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 2,
        ),
        "45m 30s",
      );

      ms = const Duration(
        seconds: 30,
      ).inMilliseconds;

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 2,
        ),
        "30s",
      );
    });

    testWidgets("With duration unit", (tester) async {
      var ms = const Duration(
        days: 2,
        hours: 5,
        minutes: 45,
        seconds: 30,
      ).inMilliseconds;

      var context = await buildContext(tester);

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          largestDurationUnit: date_time_utils.DurationUnit.hours,
        ),
        "53h 45m 30s",
      );

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          largestDurationUnit: date_time_utils.DurationUnit.minutes,
        ),
        "3225m 30s",
      );
    });
  });

  testWidgets("isFrequencyTimerReady timer is null", (tester) async {
    var timeManager = MockTimeManager();
    when(timeManager.currentTimestamp).thenReturn(0);

    var invoked = false;
    expect(
      date_time_utils.isFrequencyTimerReady(
        timeManager: timeManager,
        timerStartedAt: null,
        setTimer: (_) => invoked = true,
        frequency: 1000,
      ),
      isFalse,
    );

    expect(invoked, isTrue);
    verify(timeManager.currentTimestamp).called(1);
  });

  testWidgets("isFrequencyTimerReady not enough time has passed",
      (tester) async {
    var timeManager = MockTimeManager();
    when(timeManager.currentTimestamp).thenReturn(1500);

    expect(
      date_time_utils.isFrequencyTimerReady(
        timeManager: timeManager,
        timerStartedAt: 1000,
        setTimer: (_) {},
        frequency: 1000,
      ),
      isFalse,
    );

    verify(timeManager.currentTimestamp).called(1);
  });

  testWidgets("isFrequencyTimerReady returns true", (tester) async {
    var timeManager = MockTimeManager();
    when(timeManager.currentTimestamp).thenReturn(10000);

    expect(
      date_time_utils.isFrequencyTimerReady(
        timeManager: timeManager,
        timerStartedAt: 1000,
        setTimer: (_) {},
        frequency: 1000,
      ),
      isTrue,
    );
  });

  test("isSameMonth", () {
    expect(
      date_time_utils.isSameYearAndMonth(
          DateTime(2022, 10, 5), DateTime(2022, 10, 6)),
      isTrue,
    );

    expect(
      date_time_utils.isSameYearAndMonth(
          DateTime(2022, 11, 5), DateTime(2022, 10, 6)),
      isFalse,
    );

    expect(
      date_time_utils.isSameYearAndMonth(
          DateTime(2021, 11, 5), DateTime(2022, 10, 6)),
      isFalse,
    );
  });
}
