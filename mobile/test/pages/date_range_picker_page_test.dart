import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/date_range_picker_page.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
    appManager.stubCurrentTime(DateTime(2020, 1, 1));
  });

  testWidgets("Initially set custom date range", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch),
          endTimestamp: Int64(dateTime(2020, 2, 1).millisecondsSinceEpoch),
          timeZone: defaultTimeZone,
        ),
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text("Jan 1, 2020 - Feb 1, 2020"), findsOneWidget);
  });

  testWidgets("Selecting date range invokes callback", (tester) async {
    late DateRange picked;
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DateRange(period: DateRange_Period.yesterday),
        onDateRangePicked: (pickedDateRange) => picked = pickedDateRange,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Today"));
    expect(picked.period, DateRange_Period.today);
  });

  testWidgets("Tapping custom date range opens date picker", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DateRange(period: DateRange_Period.yesterday),
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));

    expect(find.text("OK"), findsOneWidget);
    expect(find.text("CANCEL"), findsOneWidget);
  });

  testWidgets("Cancelling date picker doesn't update state", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DateRange(period: DateRange_Period.yesterday),
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("CANCEL"));

    expect(find.text("Custom"), findsOneWidget);
  });

  testWidgets("A day is added to end date", (tester) async {
    late DateRange picked;
    await tester.pumpWidget(Testable(
      (_) {
        return DateRangePickerPage(
          initialValue: DateRange(period: DateRange_Period.yesterday),
          onDateRangePicked: (pickedDateRange) => picked = pickedDateRange,
        );
      },
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Start Date"), "12/01/2019");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "End Date"), "12/01/2019");
    await tapAndSettle(tester, find.text("OK"));

    var expected = DateRange(
      startTimestamp: Int64(DateTime(2019, 12, 1).millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime(2019, 12, 2).millisecondsSinceEpoch),
    );
    expect(picked.startTimestamp, expected.startTimestamp);
    expect(picked.endTimestamp, expected.endTimestamp);
    expect(find.text("OK"), findsNothing);
    expect(find.text("CANCEL"), findsNothing);

    // Ensure the page wasn't popped from the stack.
    expect(find.byType(DateRangePickerPage), findsOneWidget);
  });

  testWidgets("End date is clamped to the current time", (tester) async {
    late DateRange picked;
    await tester.pumpWidget(Testable(
      (_) {
        return DateRangePickerPage(
          initialValue: DateRange(period: DateRange_Period.yesterday),
          onDateRangePicked: (pickedDateRange) => picked = pickedDateRange,
        );
      },
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("OK"));

    var expected = DateRange(
      startTimestamp: Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch),
    );
    expect(picked.startTimestamp, expected.startTimestamp);
    expect(picked.endTimestamp, expected.endTimestamp);
    expect(find.text("OK"), findsNothing);
    expect(find.text("CANCEL"), findsNothing);

    // Ensure the page wasn't popped from the stack.
    expect(find.byType(DateRangePickerPage), findsOneWidget);
  });
}
