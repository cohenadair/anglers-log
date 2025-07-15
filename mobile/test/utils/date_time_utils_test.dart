import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_time_utils.dart' as date_time_utils;

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  test("DisplayDuration formatHoursMinutes", () {
    expect(
      date_time_utils.DisplayDuration(
        const Duration(
          milliseconds:
              5 * Duration.millisecondsPerHour +
              5 * Duration.millisecondsPerMinute,
        ),
      ).formatHoursMinutes(),
      "05:05",
    );
    expect(
      date_time_utils.DisplayDuration(
        const Duration(
          milliseconds:
              15 * Duration.millisecondsPerHour +
              15 * Duration.millisecondsPerMinute,
        ),
      ).formatHoursMinutes(),
      "15:15",
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
      var ms = const Duration(days: 385).inMilliseconds;

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
      var ms = const Duration(days: 2).inMilliseconds;

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
      var ms = const Duration(hours: 10).inMilliseconds;

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
      var ms = const Duration(minutes: 20).inMilliseconds;

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
      var ms = const Duration(seconds: 50).inMilliseconds;

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

      ms = const Duration(hours: 5, minutes: 45, seconds: 30).inMilliseconds;

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 2,
        ),
        "5h 45m",
      );

      ms = const Duration(minutes: 45, seconds: 30).inMilliseconds;

      expect(
        date_time_utils.formatDuration(
          context: context,
          millisecondsDuration: ms,
          condensed: true,
          numberOfQuantities: 2,
        ),
        "45m 30s",
      );

      ms = const Duration(seconds: 30).inMilliseconds;

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
}
