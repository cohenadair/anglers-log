import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as quiver;

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

  var baitVariantId0 = randomId();

  var baitAttachment0 = BaitAttachment(baitId: baitId0);
  var baitAttachment1 = BaitAttachment(baitId: baitId1);
  var baitAttachment2 = BaitAttachment(baitId: baitId2);
  var baitAttachment4 = BaitAttachment(
    baitId: baitId4,
    variantId: baitVariantId0,
  );

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
      ..name = "Grub"
      ..variants.add(
        BaitVariant(
          id: baitVariantId0,
          baseId: baitId4,
          color: "Red",
        ),
      ),
  };

  var _catches = <Catch>[
    Catch()
      ..id = catchId0
      ..timestamp = Int64(10)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0),
    Catch()
      ..id = catchId1
      ..timestamp = Int64(5000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId3
      ..baits.add(baitAttachment4),
    Catch()
      ..id = catchId2
      ..timestamp = Int64(100)
      ..speciesId = speciesId0
      ..fishingSpotId = fishingSpotId4
      ..baits.add(baitAttachment0),
    Catch()
      ..id = catchId3
      ..timestamp = Int64(900)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId0
      ..baits.add(baitAttachment1),
    Catch()
      ..id = catchId4
      ..timestamp = Int64(78000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0),
    Catch()
      ..id = catchId5
      ..timestamp = Int64(100000)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment2),
    Catch()
      ..id = catchId6
      ..timestamp = Int64(800)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId2
      ..baits.add(baitAttachment1),
    Catch()
      ..id = catchId7
      ..timestamp = Int64(70)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0),
    Catch()
      ..id = catchId8
      ..timestamp = Int64(15)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment1),
    Catch()
      ..id = catchId9
      ..timestamp = Int64(6000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baits.add(baitAttachment0),
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.baitManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.baitManager.list()).thenReturn(baitMap.values.toList());
    when(appManager.baitManager.entity(any))
        .thenAnswer((invocation) => baitMap[invocation.positionalArguments[0]]);
    when(appManager.baitManager.entityExists(any)).thenReturn(true);
    when(appManager.baitManager.nameComparator)
        .thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(appManager.baitManager.attachmentComparator)
        .thenReturn((lhs, rhs) => 0);
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenAnswer((invocation) {
      var result = <String>[];
      for (var attachment in invocation.positionalArguments.first) {
        result.add(baitMap[attachment.baitId]!.name);
      }
      return result;
    });

    when(appManager.catchManager.catchesSortedByTimestamp(
      any,
      dateRange: anyNamed("dateRange"),
      baits: anyNamed("baits"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn([]);
    when(appManager.catchManager.list()).thenReturn(_catches);

    when(appManager.reportManager.list()).thenReturn([]);
    when(appManager.reportManager.listSortedByName()).thenReturn([]);
    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.nameComparator)
        .thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));

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
    when(appManager.fishingSpotManager.nameComparator)
        .thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));

    when(appManager.speciesManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(appManager.speciesManager.list())
        .thenReturn(speciesMap.values.toList());
    when(appManager.speciesManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn(speciesMap.values.toList());
    when(appManager.speciesManager.entity(any)).thenAnswer(
        (invocation) => speciesMap[invocation.positionalArguments[0]]);
    when(appManager.speciesManager.nameComparator)
        .thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
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
      baits: anyNamed("baits"),
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
    var report = Report()
      ..id = randomId()
      ..name = "Summary"
      ..description = "A description"
      ..type = Report_Type.summary;
    when(appManager.reportManager.list()).thenReturn([report]);
    when(appManager.reportManager.listSortedByName()).thenReturn([report]);
    when(appManager.reportManager.entityExists(report.id)).thenReturn(true);
    when(appManager.reportManager.entity(report.id)).thenReturn(report);

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
    var report = Report()
      ..id = randomId()
      ..name = "Comparison"
      ..description = "A description"
      ..type = Report_Type.comparison;
    when(appManager.reportManager.list()).thenReturn([report]);
    when(appManager.reportManager.listSortedByName()).thenReturn([report]);
    when(appManager.reportManager.entityExists(report.id)).thenReturn(true);
    when(appManager.reportManager.entity(report.id)).thenReturn(report);

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
    var comparisonReportManager = ReportManager(appManager.app);
    when(appManager.app.reportManager).thenReturn(comparisonReportManager);
    var reportId = randomId();
    await comparisonReportManager.addOrUpdate(Report()
      ..id = reportId
      ..name = "Comparison"
      ..type = Report_Type.comparison);

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
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Overview"), findsOneWidget);
  });

  testWidgets("If current report is updated, state is updated", (tester) async {
    var comparisonReportManager = ReportManager(appManager.app);
    when(appManager.app.reportManager).thenReturn(comparisonReportManager);
    var reportId = randomId();
    await comparisonReportManager.addOrUpdate(Report()
      ..id = reportId
      ..name = "Comparison"
      ..description = "Test description."
      ..type = Report_Type.comparison);

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
    await comparisonReportManager.addOrUpdate(Report()
      ..id = reportId
      ..name = "Comparison 2"
      ..description = "Test description 2."
      ..type = Report_Type.comparison);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison 2"), findsOneWidget);
    expect(find.text("Test description 2."), findsOneWidget);
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Test description."), findsNothing);
    expect(find.text("Overview"), findsNothing);
  });

  testWidgets("If non-current report is deleted, report stays the same",
      (tester) async {
    var reportManager = ReportManager(appManager.app);
    when(appManager.app.reportManager).thenReturn(reportManager);
    var comparisonId = randomId();
    await reportManager.addOrUpdate(Report()
      ..id = comparisonId
      ..name = "Comparison"
      ..type = Report_Type.comparison);
    var summaryId = randomId();
    await reportManager.addOrUpdate(Report()
      ..id = summaryId
      ..name = "Summary"
      ..type = Report_Type.summary);

    await tester.pumpWidget(Testable(
      (_) => StatsPage(),
      appManager: appManager,
    ));

    // Select a report.
    await tapAndSettle(tester, find.text("Overview"));
    await tapAndSettle(tester, find.text("Comparison"));

    // Simulate deleting a report that isn't selected.
    await reportManager.delete(summaryId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
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
      var report = Report()
        ..id = randomId()
        ..name = "Summary Report"
        ..type = Report_Type.summary
        ..fromDateRange = DateRange(period: DateRange_Period.allDates);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(report.id)).thenReturn(true);
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
      var report = Report()
        ..id = randomId()
        ..name = "Comparison Report"
        ..type = Report_Type.comparison
        ..fromDateRange = DateRange(period: DateRange_Period.last7Days)
        ..toDateRange = DateRange(period: DateRange_Period.allDates)
        ..baits.add(baitAttachment0)
        ..fishingSpotIds.addAll({fishingSpotId0, fishingSpotId1})
        ..speciesIds.addAll({speciesId0, speciesId1});
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
        findFirstWithText<ExpandableChart<BaitAttachment>>(tester, "Per bait")
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
        findType<ExpandableChart<BaitAttachment>>(tester, skipOffstage: false)
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
      var report = Report()
        ..id = randomId()
        ..name = "Summary Report"
        ..type = Report_Type.summary
        ..fromDateRange = DateRange(period: DateRange_Period.allDates)
        ..baits.add(baitAttachment0)
        ..fishingSpotIds.add(fishingSpotId0)
        ..speciesIds.add(speciesId0);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
        findFirstWithText<ExpandableChart<BaitAttachment>>(tester, "Per bait")
            .filters,
        {
          "Worm",
          "E",
          "Bluegill",
          "All dates",
        },
      );

      expect(
        findType<ExpandableChart<BaitAttachment>>(tester, skipOffstage: false)
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

      expect(findType<ExpandableChart<BaitAttachment>>(tester), isEmpty);
    });

    testWidgets("Catches per bait charts/baits per species showing",
        (tester) async {
      _stubCatchesByTimestamp([
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baits.add(baitAttachment0),
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baits.add(baitAttachment0),
        Catch()
          ..id = randomId()
          ..speciesId = speciesId0
          ..baits.add(baitAttachment0),
      ]);

      await tester.pumpWidget(
        Testable(
          (_) => StatsPage(),
          appManager: appManager,
        ),
      );

      expect(findType<ExpandableChart<BaitAttachment>>(tester).length, 2);
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
      var report = Report()
        ..id = randomId()
        ..name = "Comparison Report"
        ..type = Report_Type.comparison
        ..fromDateRange = DateRange(period: DateRange_Period.allDates)
        ..toDateRange = DateRange(period: DateRange_Period.last7Days);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
      var report = Report()
        ..id = randomId()
        ..name = "Summary Report"
        ..type = Report_Type.summary
        ..fromDateRange = DateRange(period: DateRange_Period.lastYear);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
      var report = Report()
        ..id = randomId()
        ..name = "Summary Report"
        ..type = Report_Type.summary
        ..fromDateRange = DateRange(period: DateRange_Period.allDates);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
      var report = Report()
        ..id = randomId()
        ..name = "Comparison Report"
        ..type = Report_Type.comparison
        ..fromDateRange = DateRange(period: DateRange_Period.last7Days)
        ..toDateRange = DateRange(period: DateRange_Period.lastMonth);
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(any)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);
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
      var report = Report()
        ..id = randomId()
        ..name = "Comparison Report"
        ..type = Report_Type.comparison
        ..fromDateRange = DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(0),
          endTimestamp: Int64(5),
        )
        ..toDateRange = DateRange(
          period: DateRange_Period.custom,
          startTimestamp: Int64(4),
          endTimestamp: Int64(500),
        );
      when(appManager.userPreferenceManager.selectedReportId)
          .thenReturn(report.id);
      when(appManager.reportManager.entity(report.id)).thenReturn(report);
      when(appManager.reportManager.entityExists(any)).thenReturn(true);

      when(appManager.catchManager.catchesSortedByTimestamp(
        any,
        dateRange: anyNamed("dateRange"),
        baits: anyNamed("baits"),
        fishingSpotIds: anyNamed("fishingSpotIds"),
        speciesIds: anyNamed("speciesIds"),
      )).thenAnswer((invocation) {
        var dateRange =
            invocation.namedArguments[const Symbol("dateRange")] as DateRange;
        if (dateRange.startMs(DateTime.now()) == 0) {
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

  testWidgets("Clicking baits per species chart opens BaitPage",
      (tester) async {
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Attachment 0");
    when(appManager.baitManager.entityExists(any)).thenReturn(true);
    when(appManager.baitManager.deleteMessage(any, any)).thenReturn("Delete");
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn("Name");

    _stubCatchesByTimestamp([
      Catch()
        ..id = randomId()
        ..speciesId = speciesId0
        ..baits.add(baitAttachment0),
    ]);

    // The widget being tapped below is off the default screen size (800x600),
    // so we set the canvas size here, otherwise the "hit test" fails. Note that
    // ensureVisible and dragUntilVisible do not seem to work for whatever
    // reason.
    var size = const Size(1024, 768);
    setCanvasSize(tester, size);

    await tester.pumpWidget(
      Testable(
        (_) => StatsPage(),
        appManager: appManager,
        mediaQueryData: MediaQueryData(size: size),
      ),
    );

    expect(find.text("Per bait"), findsNWidgets(2));

    await tapAndSettle(tester, find.text("Per bait").last);
    await tapAndSettle(tester, find.text("Attachment 0 (1)"));
    expect(find.byType(BaitPage), findsOneWidget);
  });

  testWidgets("Clicking baits per species chart opens BaitVariantPage",
      (tester) async {
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Attachment 4");
    when(appManager.baitManager.entityExists(any)).thenReturn(true);
    when(appManager.baitManager.variant(any, any))
        .thenReturn(baitMap[baitId4]!.variants.first);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn("Name");

    _stubCatchesByTimestamp([
      Catch()
        ..id = randomId()
        ..speciesId = speciesId0
        ..baits.add(baitAttachment4),
    ]);

    // The widget being tapped below is off the default screen size (800x600),
    // so we set the canvas size here, otherwise the "hit test" fails. Note that
    // ensureVisible and dragUntilVisible do not seem to work for whatever
    // reason.
    var size = const Size(1024, 768);
    setCanvasSize(tester, size);

    await tester.pumpWidget(
      Testable(
        (_) => StatsPage(),
        appManager: appManager,
        mediaQueryData: MediaQueryData(size: size),
      ),
    );

    expect(find.text("Per bait"), findsNWidgets(2));

    await tapAndSettle(tester, find.text("Per bait").last);
    await tapAndSettle(tester, find.text("Attachment 4 (1)"));
    expect(find.byType(BaitVariantPage), findsOneWidget);
  });
}
