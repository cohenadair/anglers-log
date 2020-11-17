import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/date_range_picker_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;
  
  setUp(() {
    appManager = MockAppManager(
      mockTimeManager: true,
    );

    when(appManager.mockTimeManager.currentDateTime)
        .thenReturn(DateTime(2020, 1, 1));
  });

  testWidgets("Initially set custom date range", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DisplayDateRange.newCustomFromDateRange(DateRange(
          startDate: DateTime(2020, 1, 1),
          endDate: DateTime(2020, 2, 1),
        )),
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text("Jan 1, 2020 - Feb 1, 2020"), findsOneWidget);
  });

  testWidgets("Selecting date range invokes callback", (WidgetTester tester)
      async
  {
    DisplayDateRange picked;
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DisplayDateRange.yesterday,
        onDateRangePicked: (pickedDateRange) => picked = pickedDateRange,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Today"));
    expect(picked.id, DisplayDateRange.today.id);
  });

  testWidgets("Tapping custom date range opens date picker",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DisplayDateRange.yesterday,
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));

    expect(find.text("OK"), findsOneWidget);
    expect(find.text("CANCEL"), findsOneWidget);
  });

  testWidgets("Cancelling date picker doesn't update state",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => DateRangePickerPage(
        initialValue: DisplayDateRange.yesterday,
        onDateRangePicked: (_) {},
      ),
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("CANCEL"));

    expect(find.text("Custom"), findsOneWidget);
  });

  testWidgets("Start/end date are the same, set range of 1 day",
      (WidgetTester tester) async
  {
    BuildContext context;
    DisplayDateRange picked;
    await tester.pumpWidget(Testable(
      (buildContext) {
        context = buildContext;
        return DateRangePickerPage(
          initialValue: DisplayDateRange.yesterday,
          onDateRangePicked: (pickedDateRange) => picked = pickedDateRange,
        );
      },
      appManager: appManager,
    ));

    // Scroll so custom date range is shown.
    await tester.drag(find.text("Last year"), Offset(0, -400));
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text("Custom"));
    await tapAndSettle(tester, find.text("OK"));

    DateRange expected = DateRange(
      startDate: DateTime(2020, 1, 1),
      endDate: DateTime(2020, 1, 2),
    );
    expect(picked.value(context).startDate, expected.startDate);
    expect(picked.value(context).endDate, expected.endDate);
    expect(find.text("OK"), findsNothing);
    expect(find.text("CANCEL"), findsNothing);

    // Ensure the page wasn't popped from the stack.
    expect(find.byType(DateRangePickerPage), findsOneWidget);
  });
}