import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  test("isLater", () {
    expect(
      isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 8, minute: 30)),
      true,
    );
    expect(
      isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 30)),
      false,
    );
    expect(
      isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 45)),
      false,
    );
    expect(
      isLater(const TimeOfDay(hour: 10, minute: 30),
          const TimeOfDay(hour: 10, minute: 15)),
      true,
    );
  });

  group("isInFutureWithMinuteAccuracy", () {
    var now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2014, 6, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 4, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 14, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 11, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 29, 46, 10001), now),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2016, 4, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 6, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 16, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 13, 29, 44, 9999), now),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 44, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 45, 9999), now),
        isFalse,
      );
      expect(
        isInFutureWithMinuteAccuracy(
            DateTime(2015, 5, 15, 12, 30, 44, 9999), now),
        isFalse,
      );
    });
  });

  group("isInFutureWithDayAccuracy", () {
    var now = DateTime(2015, 5, 15, 12, 30, 45, 10000);

    test("Value should be in the past", () {
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2014, 6, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 4, 16, 13, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 14, 13, 31, 46, 10001), now),
        isFalse,
      );
    });

    test("Value should be in the future", () {
      expect(
        isInFutureWithDayAccuracy(DateTime(2016, 4, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 6, 14, 11, 29, 44, 9999), now),
        isTrue,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 5, 16, 11, 29, 44, 9999), now),
        isTrue,
      );
    });

    test("Values are equal, but isInFuture returns false", () {
      // Equal, since seconds and milliseconds aren't considered.
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 15, 11, 31, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(
            DateTime(2015, 5, 15, 12, 29, 46, 10001), now),
        isFalse,
      );
      expect(
        isInFutureWithDayAccuracy(DateTime(2015, 5, 15, 13, 29, 44, 9999), now),
        isFalse,
      );
    });
  });

  test("combine", () {
    expect(
      combine(DateTime(2020, 10, 26, 15, 30, 20, 1000),
          const TimeOfDay(hour: 16, minute: 45)),
      DateTime(2020, 10, 26, 16, 45, 20, 1000),
    );
  });

  test("dateTimeToDayAccuracy", () {
    expect(dateTimeToDayAccuracy(DateTime(2020, 10, 26, 15, 30, 20, 1000)),
        DateTime(2020, 10, 26, 0, 0, 0, 0));
  });

  test("getStartOfWeek", () {
    expect(startOfWeek(DateTime(2020, 9, 24)), DateTime(2020, 9, 21));
  });

  test("weekOfYear", () {
    expect(weekOfYear(DateTime(2020, 2, 15)), 7);
  });

  test("dayOfYear", () {
    expect(dayOfYear(DateTime(2020, 2, 15)), 46);
  });

  testWidgets("formatTimeOfDay", (tester) async {
    expect(
      formatTimeOfDay(
          await buildContext(tester), const TimeOfDay(hour: 15, minute: 30)),
      "3:30 PM",
    );
    expect(
      formatTimeOfDay(await buildContext(tester, use24Hour: true),
          const TimeOfDay(hour: 15, minute: 30)),
      "15:30",
    );
  });

  testWidgets("timestampToSearchString", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime(2020, 9, 24));
    expect(
      timestampToSearchString(
          await buildContext(tester, appManager: appManager),
          DateTime(2020, 9, 24).millisecondsSinceEpoch),
      "Today at 12:00 AM September 24, 2020",
    );
  });

  testWidgets("formatDateAsRecent", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime(2020, 9, 24));
    var context = await buildContext(tester, appManager: appManager);

    expect(formatDateAsRecent(context, DateTime(2020, 9, 24)), "Today");
    expect(formatDateAsRecent(context, DateTime(2020, 9, 23)), "Yesterday");
    expect(formatDateAsRecent(context, DateTime(2020, 9, 22)), "Tuesday");
    expect(
      formatDateAsRecent(
        context,
        DateTime(2020, 9, 22),
        abbreviated: true,
      ),
      "Tue",
    );
    expect(formatDateAsRecent(context, DateTime(2020, 8, 22)), "Aug 22");
    expect(formatDateAsRecent(context, DateTime(2019, 8, 22)), "Aug 22, 2019");
  });

  testWidgets("formatDateTime exclude midnight", (tester) async {
    var appManager = StubbedAppManager();
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime(2020, 9, 24));
    var context = await buildContext(tester, appManager: appManager);

    expect(
      formatDateTime(
        context,
        DateTime(2020, 8, 22),
        excludeMidnight: false,
      ),
      "Aug 22 at 12:00 AM",
    );
    expect(
      formatDateTime(
        context,
        DateTime(2020, 8, 22),
        excludeMidnight: true,
      ),
      "Aug 22",
    );
  });

  group("Format duration", () {
    testWidgets("0 duration", (tester) async {
      var context = await buildContext(tester);

      expect(
        formatDuration(
          context: context,
          millisecondsDuration: 0,
        ),
        "0y 0d 0h 0m 0s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "1y 20d 5h 45m 30s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "1y 20d 0h 0m 0s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 2d 0h 0m 0s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 10h 0m 0s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 0h 20m 0s",
      );

      expect(
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
        ),
        "0y 0d 0h 0m 50s",
      );

      expect(
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
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
        formatDuration(
          context: context,
          millisecondsDuration: ms,
          largestDurationUnit: DurationUnit.hours,
        ),
        "53h 45m 30s",
      );

      expect(
        formatDuration(
          context: context,
          millisecondsDuration: ms,
          largestDurationUnit: DurationUnit.minutes,
        ),
        "3225m 30s",
      );
    });
  });
}
