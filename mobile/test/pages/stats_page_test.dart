import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var speciesId0 = randomId();
  var speciesId1 = randomId();
  var speciesId2 = randomId();
  var speciesId3 = randomId();
  var speciesId4 = randomId();

  var fishingSpotId0 = randomId();
  var fishingSpotId1 = randomId();
  var fishingSpotId2 = randomId();
  var fishingSpotId3 = randomId();
  var fishingSpotId4 = randomId();

  var baitId0 = randomId();
  var baitId1 = randomId();
  var baitId2 = randomId();
  var baitId3 = randomId();
  var baitId4 = randomId();

  var catchId0 = randomId();
  var catchId1 = randomId();
  var catchId2 = randomId();
  var catchId3 = randomId();
  var catchId4 = randomId();
  var catchId5 = randomId();
  var catchId6 = randomId();
  var catchId7 = randomId();
  var catchId8 = randomId();
  var catchId9 = randomId();

  var speciesMap = <Id, Species>{
    speciesId0: Species()
      ..id = speciesId0
      ..name = "Bluegill",
    speciesId1: Species()
      ..id = speciesId1
      ..name = "Pike",
    speciesId2: Species()
      ..id = speciesId2
      ..name = "Catfish",
    speciesId3: Species()
      ..id = speciesId3
      ..name = "Bass",
    speciesId4: Species()
      ..id = speciesId4
      ..name = "Steelhead",
  };

  var fishingSpotMap = <Id, FishingSpot>{
    fishingSpotId0: FishingSpot()
      ..id = fishingSpotId0
      ..name = "E"
      ..lat = 0.4
      ..lng = 0.0,
    fishingSpotId1: FishingSpot()
      ..id = fishingSpotId1
      ..name = "C"
      ..lat = 0.2
      ..lng = 0.2,
    fishingSpotId2: FishingSpot()
      ..id = fishingSpotId2
      ..name = "B"
      ..lat = 0.1
      ..lng = 0.3,
    fishingSpotId3: FishingSpot()
      ..id = fishingSpotId3
      ..name = "D"
      ..lat = 0.3
      ..lng = 0.1,
    fishingSpotId4: FishingSpot()
      ..id = fishingSpotId4
      ..name = "A"
      ..lat = 0.0
      ..lng = 0.4,
  };

  var baitMap = <Id, Bait>{
    baitId0: Bait()
      ..id = baitId0
      ..name = "Worm",
    baitId1: Bait()
      ..id = baitId1
      ..name = "Bugger",
    baitId2: Bait()
      ..id = baitId2
      ..name = "Minnow",
    baitId3: Bait()
      ..id = baitId3
      ..name = "Grasshopper",
    baitId4: Bait()
      ..id = baitId4
      ..name = "Grub",
  };

  var _catches = <Catch>[
    Catch()
      ..id = catchId0
      ..timestamp = Int64(10)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId1
      ..timestamp = Int64(5000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId3
      ..baitId = baitId4,
    Catch()
      ..id = catchId2
      ..timestamp = Int64(100)
      ..speciesId = speciesId0
      ..fishingSpotId = fishingSpotId4
      ..baitId = baitId0,
    Catch()
      ..id = catchId3
      ..timestamp = Int64(900)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId0
      ..baitId = baitId1,
    Catch()
      ..id = catchId4
      ..timestamp = Int64(78000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId5
      ..timestamp = Int64(100000)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId2,
    Catch()
      ..id = catchId6
      ..timestamp = Int64(800)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId2
      ..baitId = baitId1,
    Catch()
      ..id = catchId7
      ..timestamp = Int64(70)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId8
      ..timestamp = Int64(15)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId1,
    Catch()
      ..id = catchId9
      ..timestamp = Int64(6000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.baitManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.baitManager.list()).thenReturn(baitMap.values.toList());
    when(appManager.baitManager.entity(any))
        .thenAnswer((invocation) => baitMap[invocation.positionalArguments[0]]);

    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      dateRange: anyNamed("dateRange"),
      baitIds: anyNamed("baitIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn([]);
    when(appManager.catchManager.list()).thenReturn(_catches);

    when(appManager.comparisonReportManager.list()).thenReturn([]);

    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.fishingSpotManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.fishingSpotManager.list())
        .thenReturn(fishingSpotMap.values.toList());
    when(appManager.fishingSpotManager.entity(any)).thenAnswer(
        (invocation) => fishingSpotMap[invocation.positionalArguments[0]]);

    when(appManager.speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.speciesManager.list())
        .thenReturn(speciesMap.values.toList());
    when(appManager.speciesManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(speciesMap.values.toList());
    when(appManager.speciesManager.entity(any)).thenAnswer(
        (invocation) => speciesMap[invocation.positionalArguments[0]]);

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));
    when(appManager.timeManager.msSinceEpoch).thenReturn(
        DateTime.fromMillisecondsSinceEpoch(105000).millisecondsSinceEpoch);

    when(appManager.userPreferenceManager.selectedReportId).thenReturn(null);
    when(appManager.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
  });

  void _stubCatchesByTimestamp([List<Catch>? catches]) {
    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      dateRange: anyNamed("dateRange"),
      baitIds: anyNamed("baitIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn(
      (catches ?? _catches)
        ..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)),
    );
  }

  testWidgets("Defaults to overview", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));
    expect(find.text("Overview"), findsOneWidget);
    expect(find.text("All dates"), findsOneWidget);
  });

  testWidgets("Selecting summary shows summary", (tester) async {
    var report = SummaryReport()
      ..id = randomId()
      ..name = "Summary"
      ..description = "A description";
    when(appManager.comparisonReportManager.list()).thenReturn([]);
    when(appManager.comparisonReportManager.entityExists(any))
        .thenReturn(false);
    when(appManager.summaryReportManager.list()).thenReturn([report]);
    when(appManager.summaryReportManager.entityExists(report.id))
        .thenReturn(true);
    when(appManager.summaryReportManager.entity(report.id)).thenReturn(report);

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Summary"));

    expect(find.text("Summary"), findsOneWidget);
    expect(find.text("A description"), findsOneWidget);
    expect(find.text("Overview"), findsNothing);
  });

  testWidgets("Selecting comparison shows comparison", (tester) async {
    var report = ComparisonReport()
      ..id = randomId()
      ..name = "Comparison"
      ..description = "A description";
    when(appManager.summaryReportManager.entityExists(any)).thenReturn(false);
    when(appManager.summaryReportManager.list()).thenReturn([]);
    when(appManager.comparisonReportManager.list()).thenReturn([report]);
    when(appManager.comparisonReportManager.entityExists(report.id))
        .thenReturn(true);
    when(appManager.comparisonReportManager.entity(report.id))
        .thenReturn(report);

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));

    expect(find.text("Comparison"), findsOneWidget);
    expect(find.text("A description"), findsOneWidget);
    expect(find.text("Overview"), findsNothing);
  });

  testWidgets("If current report is deleted, falls back to overview",
      (tester) async {
    var summaryReportManager = SummaryReportManager(appManager.app);
    when(appManager.app.summaryReportManager).thenReturn(summaryReportManager);

    var comparisonReportManager = ComparisonReportManager(appManager.app);
    when(appManager.app.comparisonReportManager)
        .thenReturn(comparisonReportManager);
    var reportId = randomId();
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = reportId
      ..name = "Comparison");

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.text("Comparison"), findsOneWidget);

    // Simulate deleting the report.
    await comparisonReportManager.delete(reportId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Overview"), findsOneWidget);
  });

  testWidgets("If current report is updated, state is updated", (tester) async {
    var summaryReportManager = SummaryReportManager(appManager.app);
    when(appManager.app.summaryReportManager).thenReturn(summaryReportManager);

    var comparisonReportManager = ComparisonReportManager(appManager.app);
    when(appManager.app.comparisonReportManager)
        .thenReturn(comparisonReportManager);
    var reportId = randomId();
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = reportId
      ..name = "Comparison"
      ..description = "Test description.");

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.text("Comparison"), findsOneWidget);
    expect(find.text("Test description."), findsOneWidget);

    // Simulate editing the report.
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = reportId
      ..name = "Comparison 2"
      ..description = "Test description 2.");

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.text("Comparison 2"), findsOneWidget);
    expect(find.text("Test description 2."), findsOneWidget);
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Test description."), findsNothing);
    expect(find.text("Overview"), findsNothing);
  });

  testWidgets("If non-current report is deleted, report stays the same",
      (tester) async {
    var summaryReportManager = SummaryReportManager(appManager.app);
    when(appManager.app.summaryReportManager).thenReturn(summaryReportManager);
    var summaryId = randomId();
    await summaryReportManager.addOrUpdate(SummaryReport()
      ..id = summaryId
      ..name = "Summary");

    var comparisonReportManager = ComparisonReportManager(appManager.app);
    when(appManager.app.comparisonReportManager)
        .thenReturn(comparisonReportManager);
    var comparisonId = randomId();
    await comparisonReportManager.addOrUpdate(ComparisonReport()
      ..id = comparisonId
      ..name = "Comparison");

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));

    // Simulate deleting a report that isn't selected.
    await summaryReportManager.delete(summaryId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsOneWidget);
  });

  group("Content widgets", () {
    testWidgets("No initial species", (tester) async {
      // This case is handled by "Has 0 catches" test case.
    });

    testWidgets("Valid initial species", (tester) async {
      // This case is handled by "Has > 0 catches" test case.
    });

    testWidgets("Has > 0 catches", (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Summary Report"
        ..displayDateRangeId = DisplayDateRange.allDates.id;
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.summaryReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(report.id))
          .thenReturn(true);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(false);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(find.text("No catches found"), findsNothing);
    });

    testWidgets("Has 0 catches", (tester) async {
      await tester.pumpWidget(Testable((context) {
        _stubCatchesByTimestamp([]);
        return StatsPage();
      }, appManager: appManager));
      expect(find.text("No catches found"), findsOneWidget);
    });

    testWidgets("Comparison filters don't include date", (tester) async {
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Comparison Report"
        ..fromDisplayDateRangeId = DisplayDateRange.last7Days.id
        ..toDisplayDateRangeId = DisplayDateRange.allDates.id
        ..baitIds.add(baitId0)
        ..fishingSpotIds.addAll({fishingSpotId0, fishingSpotId1})
        ..speciesIds.addAll({speciesId0, speciesId1});
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.comparisonReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(false);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(true);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(
        findFirstWithText<ExpandableChart<Species>>(tester, "Per species")
            .filters,
        {
          "Worm",
          "E",
          "C",
          "Bluegill",
          "Pike",
        },
      );

      expect(
        findFirstWithText<ExpandableChart<FishingSpot>>(
                tester, "Per fishing spot")
            .filters,
        {
          "Worm",
          "E",
          "C",
          "Bluegill",
          "Pike",
        },
      );

      expect(
        findFirstWithText<ExpandableChart<Bait>>(tester, "Per bait").filters,
        {
          "Worm",
          "E",
          "C",
          "Bluegill",
          "Pike",
        },
      );

      expect(
        findType<ExpandableChart<Bait>>(tester, skipOffstage: false)
            .where((widget) =>
                widget.viewAllDescription ==
                "Viewing number of catches per species per bait.")
            .first
            .filters,
        {
          "Worm",
          "E",
          "C",
          "Pike",
        },
      );

      expect(
        findType<ExpandableChart<FishingSpot>>(tester, skipOffstage: false)
            .where((widget) =>
                widget.viewAllDescription ==
                "Viewing number of catches per species per fishing spot.")
            .first
            .filters,
        {
          "Worm",
          "E",
          "C",
          "Pike",
        },
      );
    });

    testWidgets("Summary filters show date", (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Summary Report"
        ..displayDateRangeId = DisplayDateRange.allDates.id
        ..baitIds.add(baitId0)
        ..fishingSpotIds.add(fishingSpotId0)
        ..speciesIds.add(speciesId0);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.summaryReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(true);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(false);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(
        findFirstWithText<ExpandableChart<Species>>(tester, "Per species")
            .filters,
        {
          "Worm",
          "E",
          "Bluegill",
          "All dates",
        },
      );

      expect(
        findFirstWithText<ExpandableChart<FishingSpot>>(
                tester, "Per fishing spot")
            .filters,
        {
          "Worm",
          "E",
          "Bluegill",
          "All dates",
        },
      );

      expect(
        findFirstWithText<ExpandableChart<Bait>>(tester, "Per bait").filters,
        {
          "Worm",
          "E",
          "Bluegill",
          "All dates",
        },
      );

      expect(
        findType<ExpandableChart<Bait>>(tester, skipOffstage: false)
            .where((widget) =>
                widget.viewAllDescription ==
                "Viewing number of catches per species per bait.")
            .first
            .filters,
        {
          "Worm",
          "E",
          "Pike",
          "All dates",
        },
      );

      expect(
        findType<ExpandableChart<FishingSpot>>(tester, skipOffstage: false)
            .where((widget) =>
                widget.viewAllDescription ==
                "Viewing number of catches per species per fishing spot.")
            .first
            .filters,
        {
          "Worm",
          "E",
          "Pike",
          "All dates",
        },
      );
    });

    testWidgets("Catches per fishing spot/fishing spots per species hidden",
        (tester) async {
      _stubCatchesByTimestamp([
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
      ]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(findType<ExpandableChart<FishingSpot>>(tester), isEmpty);
    });

    testWidgets("Catches per fishing spot/fishing spots per species showing",
        (tester) async {
      _stubCatchesByTimestamp([
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..fishingSpotId = fishingSpotId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..fishingSpotId = fishingSpotId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..fishingSpotId = fishingSpotId0,
      ]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(findType<ExpandableChart<FishingSpot>>(tester).length, 2);
    });

    testWidgets("Catches per bait/bait per species hidden", (tester) async {
      _stubCatchesByTimestamp([
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0,
      ]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(findType<ExpandableChart<Bait>>(tester), isEmpty);
    });

    testWidgets("Catches per bait charts/baits per species showing",
        (tester) async {
      _stubCatchesByTimestamp([
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baitId = baitId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baitId = baitId0,
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baitId = baitId0,
      ]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(findType<ExpandableChart<Bait>>(tester).length, 2);
    });

    testWidgets("Time since last catch row is hidden when there are no catches",
        (tester) async {
      _stubCatchesByTimestamp([]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(find.text("Since last catch"), findsNothing);
    });

    testWidgets("Time since last catch row is hidden when comparing",
        (tester) async {
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Comparison Report"
        ..fromDisplayDateRangeId = DisplayDateRange.allDates.id
        ..toDisplayDateRangeId = DisplayDateRange.last7Days.id;
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.comparisonReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(false);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(true);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(find.text("Since last catch"), findsNothing);
    });

    testWidgets("Since last catch hidden when current time is excluded",
        (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Summary Report"
        ..displayDateRangeId = DisplayDateRange.lastYear.id;
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.summaryReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(true);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(false);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(find.text("Since last catch"), findsNothing);
    });

    testWidgets("Since last catch showing", (tester) async {
      var report = SummaryReport()
        ..id = randomId()
        ..name = "Summary Report"
        ..displayDateRangeId = DisplayDateRange.allDates.id;
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.summaryReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(true);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(false);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(find.text("Since last catch"), findsOneWidget);
    });

    testWidgets("Picking species updates state", (tester) async {
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      await tester.tap(find.text("Pike"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Bluegill"));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListPickerInput, "Bluegill"), findsOneWidget);
    });

    testWidgets("View catches/catches per species row for each series",
        (tester) async {
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Comparison Report"
        ..fromDisplayDateRangeId = DisplayDateRange.last7Days.id
        ..toDisplayDateRangeId = DisplayDateRange.lastMonth.id;
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.comparisonReportManager.entity(any)).thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(false);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(true);
      _stubCatchesByTimestamp();

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      // One row for viewing all catches and one row for viewing all catches
      // for the selected species.
      expect(find.widgetWithText(ListItem, "Last 7 days"), findsNWidgets(2));
      expect(find.widgetWithText(ListItem, "Last month"), findsNWidgets(2));
    });

    testWidgets("View catches row when 0 catches", (tester) async {
      // Stub a model that has catches, and one that doesn't.
      var report = ComparisonReport()
        ..id = randomId()
        ..name = "Comparison Report"
        ..fromStartTimestamp = Int64(0)
        ..toStartTimestamp = Int64(4)
        ..fromEndTimestamp = Int64(5)
        ..toEndTimestamp = Int64(500);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.comparisonReportManager.entity(report.id))
          .thenReturn(report);
      when(appManager.summaryReportManager.entityExists(any)).thenReturn(false);
      when(appManager.comparisonReportManager.entityExists(any))
          .thenReturn(true);

      when(appManager.catchManager.catchesSortedByTimestamp(
        any,
        dateRange: anyNamed("dateRange"),
        baitIds: anyNamed("baitIds"),
        fishingSpotIds: anyNamed("fishingSpotIds"),
        speciesIds: anyNamed("speciesIds"),
      )).thenAnswer((invocation) {
        var dateRange =
            invocation.namedArguments[Symbol("dateRange")] as DateRange;
        if (dateRange.startMs == 0) {
          return [];
        }
        return _catches
            .where((cat) => cat.timestamp >= 5 && cat.timestamp <= 500)
            .toList();
      });

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(
        find.widgetWithText(
          ListItem,
          "Number of catches",
        ),
        findsNWidgets(2),
      );
    });
  });
}
