import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  List<Bait> baitList = [
    Bait()
      ..id = randomId()
      ..name = "Rapala",
    Bait()
      ..id = randomId()
      ..name = "Spoon",
  ];

  List<FishingSpot> fishingSpotList = [
    FishingSpot()
      ..id = randomId()
      ..name = "A",
    FishingSpot()
      ..id = randomId()
      ..name = "B",
  ];

  List<Species> speciesList = [
    Species()
      ..id = randomId()
      ..name = "Steelhead",
    Species()
      ..id = randomId()
      ..name = "Catfish",
  ];

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockComparisonReportManager: true,
      mockFishingSpotManager: true,
      mockSpeciesManager: true,
      mockSummaryReportManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockBaitCategoryManager.listSortedByName()).thenReturn([]);

    when(appManager.mockBaitManager.list(any)).thenReturn(baitList);
    when(appManager.mockBaitManager
        .listSortedByName(filter: anyNamed("filter"))).thenReturn(baitList);
    when(appManager.mockBaitManager.filteredList(any)).thenReturn(baitList);

    // Sunday, September 13, 2020 12:26:40 PM GMT
    when(appManager.mockTimeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(1600000000000));

    when(appManager.mockComparisonReportManager.nameExists(any))
        .thenReturn(false);

    when(appManager.mockSummaryReportManager.nameExists(any)).thenReturn(false);

    when(appManager.mockFishingSpotManager.list(any))
        .thenReturn(fishingSpotList);
    when(appManager.mockFishingSpotManager
        .listSortedByName(filter: anyNamed("filter")))
        .thenReturn(fishingSpotList);

    when(appManager.mockSpeciesManager.list(any))
        .thenReturn(speciesList);
    when(appManager.mockSpeciesManager
        .listSortedByName(filter: anyNamed("filter")))
        .thenReturn(speciesList);
  });

  Future<void> selectItems(WidgetTester tester, String startText,
      List<String> items) async
  {
    await tapAndSettle(tester, find.text(startText));
    for (String item in items) {
      await tester.tap(find.descendant(
        of: find.widgetWithText(InkWell, item),
        matching: find.byType(Checkbox),
      ));
    }
    await tapAndSettle(tester, find.text("DONE"));
  }

  testWidgets("New title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => SaveReportPage()));
    expect(find.text("New Report"), findsOneWidget);
  });

  testWidgets("Edit title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage.edit(
        SummaryReport()..id = randomId()..name = "Summary",
      ),
      appManager: appManager,
    ));
    expect(find.text("Edit Report"), findsOneWidget);
  });

  testWidgets("Type defaults to summary", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => SaveReportPage()));
    expect(find.descendant(
      of: find.widgetWithText(Row, "Summary"),
      matching: find.byIcon(Icons.radio_button_checked),
    ), findsOneWidget);
  });

  testWidgets("Date range defaults to all", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => SaveReportPage()));
    expect(find.text("All dates"), findsOneWidget);
  });

  testWidgets("Save button state updates when name changes",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    // Save button starts disabled.
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);

    // Entering valid text updates state.
    await enterTextAndSettle(tester, find.widgetWithText(TextField, "Name"),
        "Report Name");
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed,
        isNotNull);
  });

  testWidgets("Selecting type updates date range pickers", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    // Default summary only has 1 date picker.
    expect(find.byType(DateRangePickerInput), findsOneWidget);

    // Switch to comparison shows end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(2));
    expect(find.widgetWithText(DateRangePickerInput, "Compare"),
        findsOneWidget);
    expect(find.widgetWithText(DateRangePickerInput, "To"), findsOneWidget);

    // Switching back to summary removes end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(1));
    expect(find.widgetWithText(DateRangePickerInput, "Compare"), findsNothing);
    expect(find.widgetWithText(DateRangePickerInput, "To"), findsNothing);
  });

  testWidgets("Picking start date updates state", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("This week"));
    expect(find.byType(PickerPage), findsNothing);
    expect(find.text("This week"), findsOneWidget);
  });

  testWidgets("Picking end date updates state", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
    await tapAndSettle(tester, find.text("To"));
    await tapAndSettle(tester, find.text("Last week"));
    expect(find.byType(PickerPage), findsNothing);
    expect(find.text("Last week"), findsOneWidget);
  });

  testWidgets("Species picker shows picker page", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All species"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
  });

  testWidgets("Bait picker shows picker page", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All baits"));
    expect(find.byType(BaitListPage), findsOneWidget);
  });

  testWidgets("Fishing spot picker shows picker page", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);
  });

  group("Comparison report", () {
    testWidgets("Add report with preset date ranges", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(tester, find.widgetWithText(TextField, "Name"),
          "Report Name");
      await enterTextAndSettle(tester,
          find.widgetWithText(TextField, "Description"),
          "A brief description.");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
      await tapAndSettle(tester, find.text("Compare"));
      await tapAndSettle(tester, find.text("Last month"));
      await tapAndSettle(tester, find.text("To"));
      await tapAndSettle(tester, find.text("This month"));
      await selectItems(tester, "All species", ["Steelhead", "Catfish"]);
      await selectItems(tester, "All fishing spots", ["A", "B"]);
      await selectItems(tester, "All baits", ["Spoon", "Rapala"]);

      expect(find.descendant(
        of: find.widgetWithText(InkWell, "Compare"),
        matching: find.text("Last month"),
      ), findsOneWidget);
      expect(find.descendant(
        of: find.widgetWithText(InkWell, "To"),
        matching: find.text("This month"),
      ), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockComparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      ComparisonReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.description, "A brief description.");
      expect(report.fromDisplayDateRangeId, DisplayDateRange.lastMonth.id);
      expect(report.toDisplayDateRangeId, DisplayDateRange.thisMonth.id);
      expect(report.baitIds.length, 2);
      expect(report.speciesIds.length, 2);
      expect(report.fishingSpotIds.length, 2);
    });

    testWidgets("Add report with custom date ranges", (WidgetTester tester)
        async
    {
      DateRange fromDateRange;
      DateRange toDateRange;
      await tester.pumpWidget(Testable(
        (context) {
          // Custom DisplayDateRange default to "this month".
          fromDateRange = DisplayDateRange.thisMonth.value(context);
          toDateRange = DisplayDateRange.thisMonth.value(context);
          return SaveReportPage();
        },
        appManager: appManager,
      ));

      await enterTextAndSettle(tester, find.widgetWithText(TextField, "Name"),
          "Report Name");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));

      await tapAndSettle(tester, find.text("Compare"));
      // Scroll so "Custom" is visible.
      await tester.drag(find.text("Last year"), Offset(0, -400));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text("Custom"));
      await tapAndSettle(tester, find.text("OK"));

      await tapAndSettle(tester, find.text("To"));
      // Scroll so "Custom" is visible.
      await tester.drag(find.text("Last year"), Offset(0, -400));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text("Custom"));
      await tapAndSettle(tester, find.text("OK"));

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockComparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      ComparisonReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.fromDisplayDateRangeId, DisplayDateRange.custom.id);
      expect(report.fromStartTimestamp.ms, fromDateRange.startMs);
      expect(report.fromEndTimestamp.ms, fromDateRange.endMs);
      expect(report.toDisplayDateRangeId, DisplayDateRange.custom.id);
      expect(report.toStartTimestamp.ms, toDateRange.startMs);
      expect(report.toEndTimestamp.ms, toDateRange.endMs);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
    });

    testWidgets("Edit keeps old ID", (WidgetTester tester) async {
      ComparisonReport report = ComparisonReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..fromDisplayDateRangeId = DisplayDateRange.yesterday.id
        ..toDisplayDateRangeId = DisplayDateRange.today.id;
      report.baitIds.addAll(baitList.map((e) => e.id));
      report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
      report.speciesIds.addAll(speciesList.map((e) => e.id));

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      // Verify all fields are set correctly.
      expect(find.text("Report Name"), findsOneWidget);
      expect(find.text("Report description"), findsOneWidget);
      expect(find.descendant(
        of: find.widgetWithText(InkWell, "Compare"),
        matching: find.text("Yesterday"),
      ), findsOneWidget);
      expect(find.descendant(
        of: find.widgetWithText(InkWell, "To"),
        matching: find.text("Today"),
      ), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockComparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first.id, report.id);
    });
  });

  group("Summary report", () {
    testWidgets("Add report with preset date ranges", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(tester, find.widgetWithText(TextField, "Name"),
          "Report Name");
      await enterTextAndSettle(tester,
          find.widgetWithText(TextField, "Description"),
          "A brief description.");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
      await tapAndSettle(tester, find.text("All dates"));
      await tapAndSettle(tester, find.text("Last month"));
      await selectItems(tester, "All species", ["Steelhead", "Catfish"]);
      await selectItems(tester, "All fishing spots", ["A", "B"]);
      await selectItems(tester, "All baits", ["Spoon", "Rapala"]);

      expect(find.text("Last month"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockSummaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      SummaryReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.description, "A brief description.");
      expect(report.displayDateRangeId, DisplayDateRange.lastMonth.id);
      expect(report.baitIds.length, 2);
      expect(report.speciesIds.length, 2);
      expect(report.fishingSpotIds.length, 2);
    });

    testWidgets("Add report with custom date ranges", (WidgetTester tester)
        async
    {
      DateRange dateRange;
      await tester.pumpWidget(Testable(
        (context) {
          // Custom DisplayDateRange default to "this month".
          dateRange = DisplayDateRange.thisMonth.value(context);
          return SaveReportPage();
        },
        appManager: appManager,
      ));

      await enterTextAndSettle(tester, find.widgetWithText(TextField, "Name"),
          "Report Name");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));

      await tapAndSettle(tester, find.text("All dates"));
      // Scroll so "Custom" is visible.
      await tester.drag(find.text("Last year"), Offset(0, -400));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text("Custom"));
      await tapAndSettle(tester, find.text("OK"));

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockSummaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      SummaryReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.displayDateRangeId, DisplayDateRange.custom.id);
      expect(report.startTimestamp.ms, dateRange.startMs);
      expect(report.endTimestamp.ms, dateRange.endMs);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
    });

    testWidgets("Edit keeps old ID", (WidgetTester tester) async {
      SummaryReport report = SummaryReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..displayDateRangeId = DisplayDateRange.yesterday.id;
      report.baitIds.addAll(baitList.map((e) => e.id));
      report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
      report.speciesIds.addAll(speciesList.map((e) => e.id));

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      // Verify all fields are set correctly.
      expect(find.text("Report Name"), findsOneWidget);
      expect(find.text("Report description"), findsOneWidget);
      expect(find.text("Yesterday"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      VerificationResult result = verify(
          appManager.mockSummaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first.id, report.id);
    });
  });
}