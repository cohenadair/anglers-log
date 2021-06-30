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
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var now = DateTime.fromMillisecondsSinceEpoch(1600000000000);

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

  var waterClarityList = <WaterClarity>[
    WaterClarity()
      ..id = randomId()
      ..name = "Clear",
    WaterClarity()
      ..id = randomId()
      ..name = "Stained",
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
    when(appManager.timeManager.currentDateTime).thenReturn(now);

    when(appManager.reportManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.reportManager.delete(
      any,
      notify: anyNamed("notify"),
    )).thenAnswer((_) => Future.value(false));
    when(appManager.reportManager.nameExists(any)).thenReturn(false);

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

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    when(appManager.waterClarityManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.waterClarityManager.list(any)).thenReturn(waterClarityList);
    when(appManager.waterClarityManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn(waterClarityList);
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
        Report()
          ..id = randomId()
          ..name = "Summary"
          ..type = Report_Type.summary,
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

    await tester.ensureVisible(find.text("All species"));
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

    await tester.ensureVisible(find.text("All anglers"));
    await tapAndSettle(tester, find.text("All anglers"));
    expect(find.byType(AnglerListPage), findsOneWidget);
  });

  testWidgets("Water clarity picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All water clarities"));
    await tapAndSettle(tester, find.text("All water clarities"));
    expect(find.byType(WaterClarityListPage), findsOneWidget);
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

  testWidgets("Seasons picker shows picker page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All seasons"));
    await tapAndSettle(tester, find.text("All seasons"));
    expect(find.text("Select Seasons"), findsOneWidget);
  });

  testWidgets("Picking all species shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All species"));
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

    await tester.ensureVisible(find.text("All anglers"));
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

  testWidgets("Picking all water clarities shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All water clarities"));
    await tapAndSettle(tester, find.text("All water clarities"));
    expect(
      (tester.widget(find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      )) as PaddedCheckbox)
          .checked,
      isTrue,
    );

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All water clarities"), findsOneWidget);
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

  testWidgets("Picking all seasons shows single chip", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("All seasons"));
    await tapAndSettle(tester, find.text("All seasons"));
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "All").checked,
        isTrue);

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("All seasons"), findsOneWidget);
  });

  testWidgets("Add report with all fields modified", (tester) async {
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
    await tester.ensureVisible(find.text("All seasons"));
    await selectItems(tester, "All seasons", ["All", "Summer"]);
    await tester.ensureVisible(find.text("All water clarities"));
    await selectItems(tester, "All water clarities", ["All", "Stained"]);

    await tester.ensureVisible(find.text("Water Depth"));
    await tapAndSettle(tester, find.text("Water Depth"));
    await tapAndSettle(tester, find.text("Greater than (>)"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Value"), "10");
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Water Temperature"));
    await tapAndSettle(tester, find.text("Water Temperature"));
    await tapAndSettle(tester, find.text("Less than (<)"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Value"), "15");
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Length"));
    await tapAndSettle(tester, find.text("Length"));
    await tapAndSettle(tester, find.text("Equal to (=)"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Value"), "20");
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Weight"));
    await tapAndSettle(tester, find.text("Weight"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "To"), "15");
    await tapAndSettle(tester, find.byType(BackButton));

    await tester.ensureVisible(find.text("Quantity"));
    await tapAndSettle(tester, find.text("Quantity"));
    await tapAndSettle(tester, find.text("Any"));
    await tapAndSettle(tester, find.byType(BackButton));

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
    expect(find.text("Summer"), findsOneWidget);
    expect(find.text("Stained"), findsOneWidget);
    expect(find.text("> 10 m"), findsOneWidget);
    expect(find.text("< 15\u00B0C"), findsOneWidget);
    expect(find.text("= 20 cm"), findsOneWidget);
    expect(find.text("10 kg - 15 kg"), findsOneWidget);
    // TODO: Add values for atmosphere filters.
    // expect(find.text("Any"), findsOneWidget);
    expect(find.text("Any"), findsNWidgets(6));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.description, "A brief description.");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.lastMonth);
    expect(report.hasToDateRange(), isTrue);
    expect(report.toDateRange.period, DateRange_Period.thisMonth);
    expect(report.anglerIds.length, 1);
    expect(report.baitIds.length, 1);
    expect(report.speciesIds.length, 1);
    expect(report.fishingSpotIds.length, 1);
    expect(report.methodIds.length, 1);
    expect(report.waterClarityIds.length, 1);
    expect(report.periods.length, 1);
    expect(report.seasons.length, 1);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.comparison);
    expect(report.hasWaterDepthFilter(), isTrue);
    expect(report.hasWaterTemperatureFilter(), isTrue);
    expect(report.hasLengthFilter(), isTrue);
    expect(report.hasWeightFilter(), isTrue);
    expect(report.hasQuantityFilter(), isFalse);
  });

  testWidgets("Add summary report with preset date range", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Report Name");
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Summary"));
    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("Last month"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.lastMonth);
    expect(report.hasToDateRange(), isFalse);
    expect(report.anglerIds.isEmpty, isTrue);
    expect(report.baitIds.isEmpty, isTrue);
    expect(report.speciesIds.isEmpty, isTrue);
    expect(report.fishingSpotIds.isEmpty, isTrue);
    expect(report.methodIds.isEmpty, isTrue);
    expect(report.periods.isEmpty, isTrue);
    expect(report.seasons.isEmpty, isTrue);
    expect(report.waterClarityIds.isEmpty, isTrue);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.summary);
    expect(report.hasWaterDepthFilter(), isFalse);
    expect(report.hasWaterTemperatureFilter(), isFalse);
    expect(report.hasLengthFilter(), isFalse);
    expect(report.hasWeightFilter(), isFalse);
    expect(report.hasQuantityFilter(), isFalse);
  });

  testWidgets("Add report with custom date ranges", (tester) async {
    late DateRange fromDateRange;
    late DateRange toDateRange;
    await tester.pumpWidget(Testable(
      (context) {
        // Custom DisplayDateRange default to "this month".
        fromDateRange = DateRange(period: DateRange_Period.thisMonth);
        toDateRange = DateRange(period: DateRange_Period.thisMonth);
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

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.hasFromDateRange(), isTrue);
    expect(report.fromDateRange.period, DateRange_Period.custom);
    expect(report.fromDateRange.startTimestamp.toInt(),
        fromDateRange.startMs(now));
    expect(report.fromDateRange.endTimestamp.toInt(), fromDateRange.endMs(now));
    expect(report.toDateRange.period, DateRange_Period.custom);
    expect(report.toDateRange.startTimestamp.toInt(), toDateRange.startMs(now));
    expect(report.toDateRange.endTimestamp.toInt(), toDateRange.endMs(now));
    expect(report.anglerIds, isEmpty);
    expect(report.baitIds, isEmpty);
    expect(report.speciesIds, isEmpty);
    expect(report.fishingSpotIds, isEmpty);
    expect(report.methodIds, isEmpty);
    expect(report.periods, isEmpty);
    expect(report.seasons, isEmpty);
    expect(report.waterClarityIds, isEmpty);
    expect(report.hasIsFavoritesOnly(), isFalse);
    expect(report.type, Report_Type.comparison);
    expect(report.hasWaterDepthFilter(), isFalse);
    expect(report.hasWaterTemperatureFilter(), isFalse);
    expect(report.hasLengthFilter(), isFalse);
    expect(report.hasWeightFilter(), isFalse);
    expect(report.hasQuantityFilter(), isFalse);
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

    await tester.ensureVisible(find.text("All seasons"));
    await selectItems(tester, "All seasons", ["All", "All"]);

    await tester.ensureVisible(find.text("All water clarities"));
    await selectItems(tester, "All water clarities", ["All", "All"]);

    expect(find.text("All anglers"), findsOneWidget);
    expect(find.text("All species"), findsOneWidget);
    expect(find.text("All baits"), findsOneWidget);
    expect(find.text("All fishing spots"), findsOneWidget);
    expect(find.text("All fishing methods"), findsOneWidget);
    expect(find.text("All times of day"), findsOneWidget);
    expect(find.text("All seasons"), findsOneWidget);
    expect(find.text("All water clarities"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    Report report = result.captured.first;
    expect(report.name, "Report Name");
    expect(report.anglerIds, isEmpty);
    expect(report.baitIds, isEmpty);
    expect(report.speciesIds, isEmpty);
    expect(report.fishingSpotIds, isEmpty);
    expect(report.methodIds, isEmpty);
    expect(report.periods, isEmpty);
    expect(report.seasons, isEmpty);
  });

  testWidgets("Edit keeps old properties", (tester) async {
    var report = Report()
      ..id = randomId()
      ..name = "Report Name"
      ..description = "Report description"
      ..fromDateRange = DateRange(period: DateRange_Period.yesterday)
      ..toDateRange = DateRange(period: DateRange_Period.today)
      ..isFavoritesOnly = true
      ..type = Report_Type.comparison
      ..waterDepthFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 1,
          ),
        ),
      )
      ..waterTemperatureFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 80,
          ),
        ),
      )
      ..lengthFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 10,
          ),
        ),
      )
      ..weightFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 2,
          ),
        ),
      )
      ..quantityFilter = NumberFilter(
        boundary: NumberBoundary.less_than,
        from: MultiMeasurement(mainValue: Measurement(value: 50)),
      );
    report.anglerIds.addAll(anglerList.map((e) => e.id));
    report.baitIds.addAll(baitList.map((e) => e.id));
    report.fishingSpotIds.addAll(fishingSpotList.map((e) => e.id));
    report.methodIds.addAll(methodList.map((e) => e.id));
    report.speciesIds.addAll(speciesList.map((e) => e.id));
    report.waterClarityIds.addAll(waterClarityList.map((e) => e.id));
    report.periods.addAll([Period.dawn, Period.afternoon]);
    report.seasons.addAll([Season.winter, Season.summer]);

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
    expect(find.text("Winter"), findsOneWidget);
    expect(find.text("Summer"), findsOneWidget);
    expect(find.text("Clear"), findsOneWidget);
    expect(find.text("Stained"), findsOneWidget);
    expect(find.text("< 1 m"), findsOneWidget);
    expect(find.text("< 80\u00B0F"), findsOneWidget);
    expect(find.text("< 10 cm"), findsOneWidget);
    expect(find.text("< 2 kg"), findsOneWidget);
    expect(find.text("< 50"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first, report);
  });

  /// https://github.com/cohenadair/anglers-log/issues/463
  testWidgets("Editing with empty entity sets shows 'all' chip",
      (tester) async {
    var report = Report()
      ..id = randomId()
      ..name = "Report Name"
      ..description = "Report description"
      ..fromDateRange = DateRange(period: DateRange_Period.yesterday)
      ..toDateRange = DateRange(period: DateRange_Period.today);

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
    expect(find.text("All seasons"), findsOneWidget);
    expect(find.text("All water clarities"), findsOneWidget);
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
    await tapAndSettle(tester, findListItemCheckbox(tester, "Favorites Only"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first.isFavoritesOnly, isTrue);
  });

  testWidgets("Checking catch and release only sets property", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveReportPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Test");
    await tapAndSettle(tester, find.widgetWithText(InkWell, "Comparison"));
    await tapAndSettle(
        tester, findListItemCheckbox(tester, "Catch and Release Only"));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.reportManager.addOrUpdate(captureAny));
    result.called(1);

    expect(result.captured.first.isCatchAndReleaseOnly, isTrue);
  });
}
