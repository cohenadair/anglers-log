import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/angler_list_page.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/pages/save_report_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var anglerList = <Angler>[
    Angler()
      ..id = randomId()
      ..name = "Cohen",
    Angler()
      ..id = randomId()
      ..name = "Someone",
  ];

  var baitList = <Bait>[
    Bait()
      ..id = randomId()
      ..name = "Rapala",
    Bait()
      ..id = randomId()
      ..name = "Spoon",
  ];

  var fishingSpotList = <FishingSpot>[
    FishingSpot()
      ..id = randomId()
      ..name = "A",
    FishingSpot()
      ..id = randomId()
      ..name = "B",
  ];

  var methodList = <Method>[
    Method()
      ..id = randomId()
      ..name = "Casting",
    Method()
      ..id = randomId()
      ..name = "Kayak",
  ];

  var speciesList = <Species>[
    Species()
      ..id = randomId()
      ..name = "Steelhead",
    Species()
      ..id = randomId()
      ..name = "Catfish",
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.anglerManager.list(any)).thenReturn(anglerList);
    when(appManager.anglerManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(anglerList);

    when(appManager.baitCategoryManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.baitCategoryManager.listSortedByName()).thenReturn([]);

    when(appManager.baitManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.baitManager.list(any)).thenReturn(baitList);
    when(appManager.baitManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(baitList);
    when(appManager.baitManager.filteredList(any)).thenReturn(baitList);

    // Sunday, September 13, 2020 12:26:40 PM GMT
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(1600000000000));

    when(appManager.comparisonReportManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.comparisonReportManager.delete(
      any,
      notify: anyNamed("notify"),
    )).thenAnswer((_) => Future.value(false));
    when(appManager.comparisonReportManager.nameExists(any)).thenReturn(false);

    when(appManager.summaryReportManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.summaryReportManager.delete(
      any,
      notify: anyNamed("notify"),
    )).thenAnswer((_) => Future.value(false));
    when(appManager.summaryReportManager.nameExists(any)).thenReturn(false);

    when(appManager.fishingSpotManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.fishingSpotManager.list(any)).thenReturn(fishingSpotList);
    when(appManager.fishingSpotManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn(fishingSpotList);

    when(appManager.methodManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.methodManager.list(any)).thenReturn(methodList);
    when(appManager.methodManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(methodList);

    when(appManager.speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.speciesManager.list(any)).thenReturn(speciesList);
    when(appManager.speciesManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(speciesList);
  });

  Future<void> selectItems(tester, String startText, List<String> items) async {
    await tester.ensureVisible(find.text(startText));
    await tapAndSettle(tester, find.text(startText));
    for (var item in items) {
      await tester.tap(find.descendant(
        of: find.widgetWithText(InkWell, item),
        matching: find.byType(Checkbox),
      ));
    }
    await tapAndSettle(tester, find.byType(BackButton));
  }

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));
    expect(find.text("New Report"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage.edit(
        SummaryReport()
          ..id = randomId()
          ..name = "Summary",
      ),
      appManager: appManager,
    ));
    expect(find.text("Edit Report"), findsOneWidget);
  });

  testWidgets("Type defaults to summary", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));
    expect(
      find.descendant(
        of: find.widgetWithText(Row, "Summary"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Date range defaults to all", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));
    expect(find.text("All dates"), findsOneWidget);
  });

  testWidgets("Save button state updates when name changes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    // Save button starts disabled.
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);

    // Entering valid text updates state.
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Report Name");
    expect(
        findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNotNull);
  });

  testWidgets("Selecting type updates date range pickers", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    // Default summary only has 1 date picker.
    expect(find.byType(DateRangePickerInput), findsOneWidget);

    // Switch to comparison shows end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(2));
    expect(
        find.widgetWithText(DateRangePickerInput, "Compare"), findsOneWidget);
    expect(find.widgetWithText(DateRangePickerInput, "To"), findsOneWidget);

    // Switching back to summary removes end date picker.
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
    expect(find.byType(DateRangePickerInput), findsNWidgets(1));
    expect(find.widgetWithText(DateRangePickerInput, "Compare"), findsNothing);
    expect(find.widgetWithText(DateRangePickerInput, "To"), findsNothing);
  });

  testWidgets("Picking start date updates state", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("This week"));
    expect(find.byType(PickerPage), findsNothing);
    expect(find.text("This week"), findsOneWidget);
  });

  testWidgets("Picking end date updates state", (tester) async {
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

  testWidgets("Species picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All species"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
  });

  testWidgets("Bait picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All baits"));
    await tapAndSettle(tester, find.text("All baits"));
    expect(find.byType(BaitListPage), findsOneWidget);
  });

  testWidgets("Fishing spot picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All fishing spots"));
    await tapAndSettle(tester, find.text("All fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);
  });

  testWidgets("Angler picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All anglers"));
    expect(find.byType(AnglerListPage), findsOneWidget);
  });

  testWidgets("Methods picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All fishing methods"));
    await tapAndSettle(tester, find.text("All fishing methods"));
    expect(find.byType(MethodListPage), findsOneWidget);
  });

  testWidgets("Periods picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All times of day"));
    await tapAndSettle(tester, find.text("All times of day"));
    expect(find.text("Select Times Of Day"), findsOneWidget);
  });

  testWidgets("Picking all species shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All species"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All species"), findsOneWidget);
  });

  testWidgets("Picking all baits shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All baits"));
    await tapAndSettle(tester, find.text("All baits"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All baits"), findsOneWidget);
  });

  testWidgets("Picking all fishing spots shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All fishing spots"));
    await tapAndSettle(tester, find.text("All fishing spots"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All fishing spots"), findsOneWidget);
  });

  testWidgets("Picking all anglers shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("All anglers"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All anglers"), findsOneWidget);
  });

  testWidgets("Picking all fishing methods shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All fishing spots"));
    await tapAndSettle(tester, find.text("All fishing spots"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All fishing spots"), findsOneWidget);
  });

  testWidgets("Picking all periods shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All times of day"));
    await tapAndSettle(tester, find.text("All times of day"));
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "All").checked,
        isTrue);

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All times of day"), findsOneWidget);
  });

  group("Comparison report", () {
    testWidgets("Add report with preset date ranges", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
      await enterTextAndSettle(
        tester,
        find.widgetWithText(TextField, "Description"),
        "A brief description.",
      );
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
      await tapAndSettle(tester, find.text("Compare"));
      await tapAndSettle(tester, find.text("Last month"));
      await tapAndSettle(tester, find.text("To"));
      await tapAndSettle(tester, find.text("This month"));
      await selectItems(tester, "All anglers", ["All", "Cohen"]);
      await selectItems(tester, "All species", ["All", "Catfish"]);
      await selectItems(tester, "All baits", ["All", "Spoon"]);
      await tester.ensureVisible(find.text("All fishing spots"));
      await selectItems(tester, "All fishing spots", ["All", "B"]);
      await tester.ensureVisible(find.text("All fishing methods"));
      await selectItems(tester, "All fishing methods", ["All", "Casting"]);
      await tester.ensureVisible(find.text("All times of day"));
      await selectItems(tester, "All times of day", ["All", "Afternoon"]);

      expect(
        find.descendant(
          of: find.widgetWithText(InkWell, "Compare"),
          matching: find.text("Last month"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(InkWell, "To"),
          matching: find.text("This month"),
        ),
        findsOneWidget,
      );
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Afternoon"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.comparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      ComparisonReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.description, "A brief description.");
      expect(report.fromDisplayDateRangeId, DisplayDateRange.lastMonth.id);
      expect(report.toDisplayDateRangeId, DisplayDateRange.thisMonth.id);
      expect(report.anglerIds.length, 1);
      expect(report.baitIds.length, 1);
      expect(report.speciesIds.length, 1);
      expect(report.fishingSpotIds.length, 1);
      expect(report.methodIds.length, 1);
      expect(report.periods.length, 1);
      expect(report.hasIsFavoritesOnly(), isFalse);
    });

    testWidgets("Add report with custom date ranges", (tester) async {
      late DateRange fromDateRange;
      late DateRange toDateRange;
      await tester.pumpWidget(Testable(
        (context) {
          // Custom DisplayDateRange default to "this month".
          fromDateRange = DisplayDateRange.thisMonth.value(context);
          toDateRange = DisplayDateRange.thisMonth.value(context);
          return SaveReportPage();
        },
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
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

      var result =
          verify(appManager.comparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      ComparisonReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.fromDisplayDateRangeId, DisplayDateRange.custom.id);
      expect(report.fromStartTimestamp.toInt(), fromDateRange.startMs);
      expect(report.fromEndTimestamp.toInt(), fromDateRange.endMs);
      expect(report.toDisplayDateRangeId, DisplayDateRange.custom.id);
      expect(report.toStartTimestamp.toInt(), toDateRange.startMs);
      expect(report.toEndTimestamp.toInt(), toDateRange.endMs);
      expect(report.anglerIds, isEmpty);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
      expect(report.methodIds, isEmpty);
      expect(report.periods, isEmpty);
      expect(report.hasIsFavoritesOnly(), isFalse);
    });

    testWidgets("Add report with all entities selected sets empty collections",
        (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
      await tapAndSettle(tester, find.text("Compare"));
      await tapAndSettle(tester, find.text("Last month"));
      await tapAndSettle(tester, find.text("To"));
      await tapAndSettle(tester, find.text("This month"));

      // Toggle none/all for good measure.
      await selectItems(tester, "All anglers", ["All", "All"]);
      await selectItems(tester, "All species", ["All", "All"]);
      await selectItems(tester, "All baits", ["All", "All"]);

      await tester.ensureVisible(find.text("All fishing spots"));
      await selectItems(tester, "All fishing spots", ["All", "All"]);

      await tester.ensureVisible(find.text("All fishing methods"));
      await selectItems(tester, "All fishing methods", ["All", "All"]);

      await tester.ensureVisible(find.text("All times of day"));
      await selectItems(tester, "All times of day", ["All", "All"]);

      expect(find.text("All anglers"), findsOneWidget);
      expect(find.text("All species"), findsOneWidget);
      expect(find.text("All baits"), findsOneWidget);
      expect(find.text("All fishing spots"), findsOneWidget);
      expect(find.text("All fishing methods"), findsOneWidget);
      expect(find.text("All times of day"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.comparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      ComparisonReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.anglerIds, isEmpty);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
      expect(report.methodIds, isEmpty);
      expect(report.periods, isEmpty);
    });

    testWidgets("Edit keeps old properties", (tester) async {
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..fromDisplayDateRangeId = DisplayDateRange.yesterday.id
        ..toDisplayDateRangeId = DisplayDateRange.today.id
        ..isFavoritesOnly = true;
      report.anglerIds.addAll(anglerList.map((e) => e.id));
      report.baitIds.addAll(baitList.map((e) => e.id));
      report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
      report.methodIds.addAll(methodList.map((e) => e.id));
      report.speciesIds.addAll(speciesList.map((e) => e.id));
      report.periods.addAll([Period.dawn, Period.afternoon]);

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      // Verify all fields are set correctly.
      expect(find.text("Report Name"), findsOneWidget);
      expect(find.text("Report description"), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(InkWell, "Compare"),
          matching: find.text("Yesterday"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(InkWell, "To"),
          matching: find.text("Today"),
        ),
        findsOneWidget,
      );
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.text("Someone"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Kayak"), findsOneWidget);
      expect(find.text("Dawn"), findsOneWidget);
      expect(find.text("Afternoon"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.comparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first, report);
    });

    /// https://github.com/cohenadair/anglers-log/issues/463
    testWidgets("Editing with empty entity sets shows 'all' chip",
        (tester) async {
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..fromDisplayDateRangeId = DisplayDateRange.yesterday.id
        ..toDisplayDateRangeId = DisplayDateRange.today.id;

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      expect(find.text("All anglers"), findsOneWidget);
      expect(find.text("All species"), findsOneWidget);
      expect(find.text("All fishing spots"), findsOneWidget);
      expect(find.text("All baits"), findsOneWidget);
      expect(find.text("All fishing methods"), findsOneWidget);
      expect(find.text("All times of day"), findsOneWidget);
    });

    testWidgets("New report without changing date ranges", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Test");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));

      // The test here is that the app doesn't crash. If the test passes, the
      // app doesn't crash.
      await tapAndSettle(tester, find.text("SAVE"));
    });

    testWidgets("Checking favorites only sets property", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Test");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
      await tapAndSettle(
          tester, findListItemCheckbox(tester, "Favorites Only"));

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.comparisonReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first.isFavoritesOnly, isTrue);
    });
  });

  group("Summary report", () {
    testWidgets("Add report with preset date ranges", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
      await enterTextAndSettle(
        tester,
        find.widgetWithText(TextField, "Description"),
        "A brief description.",
      );
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
      await tapAndSettle(tester, find.text("All dates"));
      await tapAndSettle(tester, find.text("Last month"));
      await selectItems(tester, "All anglers", ["All", "Cohen"]);
      await selectItems(tester, "All species", ["All", "Catfish"]);
      await selectItems(tester, "All baits", ["All", "Spoon"]);

      await tester.ensureVisible(find.text("All fishing spots"));
      await selectItems(tester, "All fishing spots", ["All", "B"]);

      await tester.ensureVisible(find.text("All fishing methods"));
      await selectItems(tester, "All fishing methods", ["All", "Casting"]);

      await tester.ensureVisible(find.text("All times of day"));
      await selectItems(tester, "All times of day", ["All", "Afternoon"]);

      expect(find.text("Last month"), findsOneWidget);
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Afternoon"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.summaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      SummaryReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.description, "A brief description.");
      expect(report.displayDateRangeId, DisplayDateRange.lastMonth.id);
      expect(report.anglerIds.length, 1);
      expect(report.baitIds.length, 1);
      expect(report.speciesIds.length, 1);
      expect(report.fishingSpotIds.length, 1);
      expect(report.methodIds.length, 1);
      expect(report.periods.length, 1);
      expect(report.hasIsFavoritesOnly(), isFalse);
    });

    testWidgets("Add report with custom date ranges", (tester) async {
      late DateRange dateRange;
      await tester.pumpWidget(Testable(
        (context) {
          // Custom DisplayDateRange default to "this month".
          dateRange = DisplayDateRange.thisMonth.value(context);
          return SaveReportPage();
        },
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));

      await tapAndSettle(tester, find.text("All dates"));
      // Scroll so "Custom" is visible.
      await tester.drag(find.text("Last year"), Offset(0, -400));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text("Custom"));
      await tapAndSettle(tester, find.text("OK"));

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.summaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      SummaryReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.displayDateRangeId, DisplayDateRange.custom.id);
      expect(report.startTimestamp.toInt(), dateRange.startMs);
      expect(report.endTimestamp.toInt(), dateRange.endMs);
      expect(report.anglerIds, isEmpty);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
      expect(report.methodIds, isEmpty);
      expect(report.periods, isEmpty);
      expect(report.hasIsFavoritesOnly(), isFalse);
    });

    testWidgets("Add report with all entities selected sets empty collections",
        (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Report Name");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
      await tapAndSettle(tester, find.text("All dates"));
      await tapAndSettle(tester, find.text("Last month"));

      // Toggle none/all for good measure.
      await selectItems(tester, "All anglers", ["All", "All"]);
      await selectItems(tester, "All species", ["All", "All"]);
      await selectItems(tester, "All baits", ["All", "All"]);

      await tester.ensureVisible(find.text("All fishing spots"));
      await selectItems(tester, "All fishing spots", ["All", "All"]);

      await tester.ensureVisible(find.text("All fishing methods"));
      await selectItems(tester, "All fishing methods", ["All", "All"]);

      await tester.ensureVisible(find.text("All times of day"));
      await selectItems(tester, "All times of day", ["All", "All"]);

      expect(find.text("All anglers"), findsOneWidget);
      expect(find.text("All species"), findsOneWidget);
      expect(find.text("All baits"), findsOneWidget);
      expect(find.text("All fishing spots"), findsOneWidget);
      expect(find.text("All fishing methods"), findsOneWidget);
      expect(find.text("All times of day"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.summaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      SummaryReport report = result.captured.first;
      expect(report.name, "Report Name");
      expect(report.anglerIds, isEmpty);
      expect(report.baitIds, isEmpty);
      expect(report.speciesIds, isEmpty);
      expect(report.fishingSpotIds, isEmpty);
      expect(report.methodIds, isEmpty);
      expect(report.periods, isEmpty);
      expect(report.hasIsFavoritesOnly(), isFalse);
    });

    testWidgets("Edit keeps old properties", (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..displayDateRangeId = DisplayDateRange.yesterday.id
        ..isFavoritesOnly = true;
      report.anglerIds.addAll(anglerList.map((e) => e.id));
      report.baitIds.addAll(baitList.map((e) => e.id));
      report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
      report.methodIds.addAll(methodList.map((e) => e.id));
      report.speciesIds.addAll(speciesList.map((e) => e.id));
      report.periods.addAll([Period.dawn, Period.afternoon]);

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      // Verify all fields are set correctly.
      expect(find.text("Report Name"), findsOneWidget);
      expect(find.text("Report description"), findsOneWidget);
      expect(find.text("Yesterday"), findsOneWidget);
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.text("Someone"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.text("Spoon"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Catfish"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Kayak"), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.summaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first, report);
    });

    /// https://github.com/cohenadair/anglers-log/issues/463
    testWidgets("Editing with empty entity sets shows 'all' chip",
        (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Report Name"
        ..description = "Report description"
        ..displayDateRangeId = DisplayDateRange.yesterday.id;

      await tester.pumpWidget(Testable(
        (_) => SaveReportPage.edit(report),
        appManager: appManager,
      ));

      expect(find.text("All anglers"), findsOneWidget);
      expect(find.text("All species"), findsOneWidget);
      expect(find.text("All fishing spots"), findsOneWidget);
      expect(find.text("All baits"), findsOneWidget);
      expect(find.text("All fishing methods"), findsOneWidget);
      expect(find.text("All times of day"), findsOneWidget);
    });

    testWidgets("Checking favorites only sets property", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveReportPage(),
        appManager: appManager,
      ));

      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Name"), "Test");
      await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
      await tapAndSettle(
          tester, findListItemCheckbox(tester, "Favorites Only"));

      await tapAndSettle(tester, find.text("SAVE"));

      var result =
          verify(appManager.summaryReportManager.addOrUpdate(captureAny));
      result.called(1);

      expect(result.captured.first.isFavoritesOnly, isTrue);
    });
  });
}
