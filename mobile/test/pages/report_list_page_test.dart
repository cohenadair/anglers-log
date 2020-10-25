import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/report_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  List<SummaryReport> summaries = [
    SummaryReport()
      ..id = randomId()
      ..name = "Summary 1",
    SummaryReport()
      ..id = randomId()
      ..name = "Summary 2",
  ];

  List<ComparisonReport> comparisons = [
    ComparisonReport()
      ..id = randomId()
      ..name = "Comparison 1",
    ComparisonReport()
      ..id = randomId()
      ..name = "Comparison 2",
  ];

  setUp(() {
    appManager = MockAppManager(
      mockComparisonReportManager: true,
      mockSummaryReportManager: true,
    );

    when(appManager.mockComparisonReportManager.list()).thenReturn(comparisons);
    when(appManager.mockSummaryReportManager.list()).thenReturn(summaries);
  });

  testWidgets("Current item is selected", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        currentItem: comparisons.first,
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    expect(find.descendant(
      of: find.widgetWithText(ManageableListItem, "Comparison 1"),
      matching: find.byIcon(Icons.check),
    ), findsOneWidget);
  });

  testWidgets("Callback is invoked", (WidgetTester tester) async {
    dynamic pickedReport;
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        currentItem: comparisons.first,
        onPicked: (_, report) {
          pickedReport = report;
          return true;
        },
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Summary 1"));

    expect(pickedReport, isNotNull);
    expect(pickedReport is SummaryReport, isTrue);
    expect(pickedReport.name, "Summary 1");
  });

  testWidgets("Different item types are displayed correctly",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    expect(find.text("Overview"), findsOneWidget);
    expect(find.text("Custom Reports"), findsOneWidget);
    expect(find.text("Comparison 1"), findsOneWidget);
    expect(find.text("Comparison 2"), findsOneWidget);
    expect(find.text("Summary 1"), findsOneWidget);
    expect(find.text("Summary 2"), findsOneWidget);
  });

  testWidgets("Delete SummaryReport", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.descendant(
      of: find.widgetWithText(ManageableListItem, "Summary 1"),
      matching: find.byIcon(Icons.delete),
    ));
    await tapAndSettle(tester, find.text("DELETE"));

    verify(appManager.mockSummaryReportManager.delete(summaries.first.id))
        .called(1);
  });

  testWidgets("Delete ComparisonReport", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.descendant(
      of: find.widgetWithText(ManageableListItem, "Comparison 1"),
      matching: find.byIcon(Icons.delete),
    ));
    await tapAndSettle(tester, find.text("DELETE"));

    verify(appManager.mockComparisonReportManager.delete(comparisons.first.id))
        .called(1);
  });

  testWidgets("Overview report cannot be deleted", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("EDIT"));

    expect((tester.firstWidget<SizeTransition>(find.descendant(
      of: find.widgetWithText(ManageableListItem, "Overview"),
      matching: find.byType(SizeTransition),
    )).listenable as Animation<double>).value, 0.0);
  });

  testWidgets("Note shown when custom reports is empty", (WidgetTester tester)
      async
  {
    when(appManager.mockComparisonReportManager.list()).thenReturn([]);
    when(appManager.mockSummaryReportManager.list()).thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconNoteLabel), findsOneWidget);
  });

  testWidgets("Custom reports are sorted alphabetically", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => ReportListPage.picker(
        onPicked: (_, __) => true,
      ),
      appManager: appManager,
    ));

    Finder textWidgets = find.descendant(
      of: find.byType(ManageableListItem),
      matching: find.byType(Text),
    );
    expect((textWidgets.at(0).evaluate().single.widget as Text).data,
        "Overview");
    expect((textWidgets.at(1).evaluate().single.widget as Text).data,
        "Comparison 1");
    expect((textWidgets.at(2).evaluate().single.widget as Text).data,
        "Comparison 2");
    expect((textWidgets.at(3).evaluate().single.widget as Text).data,
        "Summary 1");
    expect((textWidgets.at(4).evaluate().single.widget as Text).data,
        "Summary 2");
  });
}