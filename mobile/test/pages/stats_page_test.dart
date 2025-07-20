import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mobile/widgets/personal_bests_report.dart';
import 'package:mobile/widgets/trip_summary.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as quiver;

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

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
        BaitVariant(id: baitVariantId0, baseId: baitId4, color: "Red"),
      ),
  };

  var catches = <Catch>[
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

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.anglerManager.list()).thenReturn([]);
    when(managers.anglerManager.uuidMapEntries()).thenReturn({});

    when(
      managers.baitManager.name(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(managers.baitManager.list()).thenReturn(baitMap.values.toList());
    when(
      managers.baitManager.entity(any),
    ).thenAnswer((invocation) => baitMap[invocation.positionalArguments[0]]);
    when(managers.baitManager.entityExists(any)).thenReturn(true);
    when(
      managers.baitManager.displayNameComparator(any),
    ).thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(managers.baitManager.attachmentComparator).thenReturn((lhs, rhs) => 0);
    when(managers.baitManager.attachmentsDisplayValues(any, any)).thenAnswer((
      invocation,
    ) {
      var result = <String>[];
      for (var attachment in invocation.positionalArguments[1]) {
        result.add(baitMap[attachment.baitId]!.name);
      }
      return result;
    });
    when(
      managers.baitManager.attachmentDisplayValue(
        any,
        any,
        showAllVariantsLabel: anyNamed("showAllVariantsLabel"),
      ),
    ).thenAnswer(
      (invocation) => baitMap[invocation.positionalArguments[1].baitId]!.name,
    );
    when(managers.baitManager.uuidMapEntries()).thenReturn(
      baitMap.map((key, value) => MapEntry(key.uuid, value)).entries,
    );

    when(managers.bodyOfWaterManager.list()).thenReturn([]);
    when(managers.bodyOfWaterManager.uuidMapEntries()).thenReturn({});

    when(
      managers.catchManager.catches(any, opt: anyNamed("opt")),
    ).thenReturn([]);
    when(managers.catchManager.list()).thenReturn(catches);
    when(managers.catchManager.hasEntities).thenReturn(false);
    when(managers.catchManager.totalQuantity(any)).thenReturn(catches.length);
    when(
      managers.catchManager.uuidMapEntries(),
    ).thenReturn({for (var cat in catches) cat.id.uuid: cat}.entries);

    when(managers.reportManager.list()).thenReturn([]);
    when(managers.reportManager.listSortedByDisplayName(any)).thenReturn([]);
    when(managers.reportManager.entityExists(any)).thenReturn(false);
    when(
      managers.reportManager.displayNameComparator(any),
    ).thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(
      managers.reportManager.defaultReports,
    ).thenReturn([Report(id: reportIdPersonalBests)]);
    when(
      managers.reportManager.defaultReport,
    ).thenReturn(Report(id: reportIdPersonalBests));
    when(managers.reportManager.displayName(any, any)).thenAnswer((invocation) {
      var context = invocation.positionalArguments[0] as BuildContext;
      var report = invocation.positionalArguments[1] as Report;
      return report.displayName(context) ?? report.name;
    });

    when(
      managers.localDatabaseManager.deleteEntity(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.fishingSpotManager.name(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn(fishingSpotMap.values.toList());
    when(managers.fishingSpotManager.entity(any)).thenAnswer(
      (invocation) => fishingSpotMap[invocation.positionalArguments[0]],
    );
    when(
      managers.fishingSpotManager.displayNameComparator(any),
    ).thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(
      managers.fishingSpotManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(managers.fishingSpotManager.uuidMapEntries()).thenReturn(
      fishingSpotMap.map((key, value) => MapEntry(key.uuid, value)).entries,
    );

    when(managers.methodManager.list()).thenReturn([]);
    when(managers.methodManager.uuidMapEntries()).thenReturn({});

    when(managers.gearManager.list()).thenReturn([]);
    when(managers.gearManager.uuidMapEntries()).thenReturn({});

    when(
      managers.speciesManager.name(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.name);
    when(managers.speciesManager.list()).thenReturn(speciesMap.values.toList());
    when(
      managers.speciesManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(speciesMap.values.toList());
    when(
      managers.speciesManager.entity(any),
    ).thenAnswer((invocation) => speciesMap[invocation.positionalArguments[0]]);
    when(managers.speciesManager.entityExists(any)).thenAnswer(
      (invocation) => speciesMap[invocation.positionalArguments[0]] != null,
    );
    when(
      managers.speciesManager.displayNameComparator(any),
    ).thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(
      managers.speciesManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(managers.speciesManager.uuidMapEntries()).thenReturn(
      speciesMap.map((key, value) => MapEntry(key.uuid, value)).entries,
    );

    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(
      managers.lib.timeManager.currentDateTime,
    ).thenReturn(dateTimestamp(105000));
    when(
      managers.lib.timeManager.currentTimestamp,
    ).thenReturn(dateTimestamp(105000).millisecondsSinceEpoch);

    when(managers.tripManager.list()).thenReturn([]);
    when(
      managers.tripManager.trips(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([]);
    when(managers.tripManager.uuidMapEntries()).thenReturn({});

    when(managers.waterClarityManager.list()).thenReturn([]);
    when(managers.waterClarityManager.uuidMapEntries()).thenReturn({});

    when(managers.gearManager.uuidMapEntries()).thenReturn({});

    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.selectedReportId).thenReturn(null);
    when(
      managers.userPreferenceManager.setSelectedReportId(any),
    ).thenAnswer((_) => Future.value());
    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(false);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingMoonPhases).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingPeriods).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingTides).thenReturn(false);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(false);
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airVisibilitySystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.windSpeedSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.statsDateRange).thenReturn(null);
    when(
      managers.userPreferenceManager.setStatsDateRange(any),
    ).thenAnswer((_) => Future.value());

    when(managers.isolatesWrapper.computeIntList(any, any)).thenAnswer((
      invocation,
    ) {
      return Future.value(
        invocation.positionalArguments.first(invocation.positionalArguments[1]),
      );
    });
  });

  void stubCatchesByTimestamp([List<Catch>? overrideCatches]) {
    var newCatches = overrideCatches ?? catches;
    when(managers.catchManager.catches(any, opt: anyNamed("opt"))).thenReturn(
      newCatches..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)),
    );
    when(managers.catchManager.hasEntities).thenReturn(newCatches.isNotEmpty);
  }

  void stubSingleReport(Report report) {
    when(managers.reportManager.list()).thenReturn([report]);
    when(
      managers.reportManager.listSortedByDisplayName(any),
    ).thenReturn([report]);
    when(managers.reportManager.entityExists(report.id)).thenReturn(true);
    when(managers.reportManager.entity(report.id)).thenReturn(report);
  }

  void verifyReportSelection(
    WidgetTester tester,
    Id reportId,
    String reportName, {
    bool isVisible = true,
  }) async {
    stubCatchesByTimestamp();
    stubSingleReport(Report(id: reportId));

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text(reportName));

    expect(
      find.byKey(ValueKey(reportId)),
      isVisible ? findsOneWidget : findsNothing,
    );
  }

  testWidgets("Selecting summary shows summary", (tester) async {
    stubCatchesByTimestamp();
    stubSingleReport(
      Report()
        ..id = randomId()
        ..name = "Summary"
        ..description = "A description"
        ..type = Report_Type.summary,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Summary"));

    expect(find.text("Summary"), findsOneWidget);
    expect(find.text("A description"), findsOneWidget);
    expect(find.text("Personal Bests"), findsNothing);
  });

  testWidgets("Selecting comparison shows comparison", (tester) async {
    stubCatchesByTimestamp();
    stubSingleReport(
      Report()
        ..id = randomId()
        ..name = "Comparison"
        ..description = "A description"
        ..type = Report_Type.comparison,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Comparison"));

    expect(find.text("Comparison"), findsOneWidget);
    expect(find.text("A description"), findsOneWidget);
    expect(find.text("Personal Bests"), findsNothing);
  });

  testWidgets("If current report is deleted, falls back to default", (
    tester,
  ) async {
    var reportManager = ReportManager(managers.app);
    when(managers.app.reportManager).thenReturn(reportManager);
    var reportId = randomId();
    await reportManager.addOrUpdate(
      Report()
        ..id = reportId
        ..name = "Comparison"
        ..type = Report_Type.comparison,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    // Select a report.
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tester.ensureVisible(find.text("Comparison"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.text("Comparison"), findsOneWidget);

    // Simulate deleting the report.
    await reportManager.delete(reportId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Personal Bests"), findsOneWidget);
  });

  testWidgets("If current report is updated, state is updated", (tester) async {
    var comparisonReportManager = ReportManager(managers.app);
    when(managers.app.reportManager).thenReturn(comparisonReportManager);
    var reportId = randomId();
    await comparisonReportManager.addOrUpdate(
      Report()
        ..id = reportId
        ..name = "Comparison"
        ..description = "Test description."
        ..type = Report_Type.comparison,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    // Select a report.
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.text("Comparison"), findsOneWidget);
    expect(find.text("Test description."), findsOneWidget);

    // Simulate editing the report.
    await comparisonReportManager.addOrUpdate(
      Report()
        ..id = reportId
        ..name = "Comparison 2"
        ..description = "Test description 2."
        ..type = Report_Type.comparison,
    );

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison 2"), findsOneWidget);
    expect(find.text("Test description 2."), findsOneWidget);
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Test description."), findsNothing);
    expect(find.text("Personal Bests"), findsNothing);
  });

  testWidgets("If non-current report is deleted, report stays the same", (
    tester,
  ) async {
    var reportManager = ReportManager(managers.app);
    when(managers.app.reportManager).thenReturn(reportManager);
    var comparisonId = randomId();
    await reportManager.addOrUpdate(
      Report()
        ..id = comparisonId
        ..name = "Comparison"
        ..type = Report_Type.comparison,
    );
    var summaryId = randomId();
    await reportManager.addOrUpdate(
      Report()
        ..id = summaryId
        ..name = "Summary"
        ..type = Report_Type.summary,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    // Select a report.
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Comparison"));

    // Simulate deleting a report that isn't selected.
    await reportManager.delete(summaryId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsOneWidget);
  });

  testWidgets("No rebuild when the same report is picked", (tester) async {
    stubSingleReport(
      Report()
        ..id = randomId()
        ..name = "Summary"
        ..description = "A description"
        ..type = Report_Type.summary,
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    verify(managers.reportManager.entity(any)).called(1);

    // Different report rebuilds widget.
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Summary"));
    verify(managers.reportManager.entity(any)).called(1);

    // Same report does not rebuild.
    await tapAndSettle(tester, find.text("Summary"));
    await tapAndSettle(tester, find.text("Summary"));
    verifyNever(managers.reportManager.entity(any));
  });

  testWidgets("Description header is hidden", (tester) async {
    await tester.pumpWidget(Testable((_) => StatsPage()));

    // Slivers that aren't visible aren't rendered, so verify the box adapter
    // containing the description is not rendered.
    expect(find.byType(SliverToBoxAdapter), findsNothing);
  });

  testWidgets("No catches shows empty watermark", (tester) async {
    await tester.pumpWidget(Testable((_) => StatsPage()));
    expect(find.text("Empty Log"), findsOneWidget);
  });

  testWidgets("Greater than 0 catches shows current report", (tester) async {
    stubCatchesByTimestamp();
    await tester.pumpWidget(Testable((_) => StatsPage()));
    expect(find.text("Empty Log"), findsNothing);
    expect(find.text("All dates"), findsOneWidget);
  });

  testWidgets("Catch summary is shown", (tester) async {
    verifyReportSelection(tester, reportIdCatchSummary, "Catch Summary");
  });

  testWidgets("Species summary is shown", (tester) async {
    verifyReportSelection(tester, reportIdSpeciesSummary, "Species Summary");
  });

  testWidgets("Gear summary is shown", (tester) async {
    when(managers.gearManager.hasEntities).thenReturn(true);
    verifyReportSelection(tester, reportIdGearSummary, "Gear Summary");
  });

  testWidgets("Gear summary is empty", (tester) async {
    when(managers.gearManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdGearSummary,
      "Gear Summary",
      isVisible: false,
    );
  });

  testWidgets("Angler summary is shown", (tester) async {
    when(managers.anglerManager.hasEntities).thenReturn(true);
    verifyReportSelection(tester, reportIdAnglerSummary, "Angler Summary");
  });

  testWidgets("Angler summary is empty", (tester) async {
    when(managers.anglerManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdAnglerSummary,
      "Angler Summary",
      isVisible: false,
    );
  });

  testWidgets("Bait summary is shown", (tester) async {
    when(managers.baitManager.hasEntities).thenReturn(true);
    verifyReportSelection(tester, reportIdBaitSummary, "Bait Summary");
  });

  testWidgets("Bait summary is empty", (tester) async {
    when(managers.baitManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdBaitSummary,
      "Bait Summary",
      isVisible: false,
    );
  });

  testWidgets("Body of water summary is shown", (tester) async {
    when(managers.bodyOfWaterManager.hasEntities).thenReturn(true);
    verifyReportSelection(
      tester,
      reportIdBodyOfWaterSummary,
      "Body of Water Summary",
    );
  });

  testWidgets("Body of water summary is empty", (tester) async {
    when(managers.bodyOfWaterManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdBodyOfWaterSummary,
      "Body of Water Summary",
      isVisible: false,
    );
  });

  testWidgets("Fishing spot summary is shown", (tester) async {
    when(managers.fishingSpotManager.hasEntities).thenReturn(true);
    verifyReportSelection(
      tester,
      reportIdFishingSpotSummary,
      "Fishing Spot Summary",
    );
  });

  testWidgets("Fishing spot summary is empty", (tester) async {
    when(managers.fishingSpotManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdFishingSpotSummary,
      "Fishing Spot Summary",
      isVisible: false,
    );
  });

  testWidgets("Fishing method summary is shown", (tester) async {
    when(managers.methodManager.hasEntities).thenReturn(true);
    verifyReportSelection(
      tester,
      reportIdMethodSummary,
      "Fishing Method Summary",
    );
  });

  testWidgets("Fishing method summary is empty", (tester) async {
    when(managers.methodManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdMethodSummary,
      "Fishing Method Summary",
      isVisible: false,
    );
  });

  testWidgets("Moon phase summary is shown", (tester) async {
    verifyReportSelection(
      tester,
      reportIdMoonPhaseSummary,
      "Moon Phase Summary",
    );
  });

  testWidgets("Period summary is shown", (tester) async {
    verifyReportSelection(tester, reportIdPeriodSummary, "Time of Day Summary");
  });

  testWidgets("Season summary is shown", (tester) async {
    verifyReportSelection(tester, reportIdSeasonSummary, "Season Summary");
  });

  testWidgets("Tide type summary is shown", (tester) async {
    verifyReportSelection(tester, reportIdTideTypeSummary, "Tide Summary");
  });

  testWidgets("Water clarity summary is shown", (tester) async {
    when(managers.waterClarityManager.hasEntities).thenReturn(true);
    verifyReportSelection(
      tester,
      reportIdWaterClaritySummary,
      "Water Clarity Summary",
    );
  });

  testWidgets("Water clarity summary is empty", (tester) async {
    when(managers.waterClarityManager.hasEntities).thenReturn(false);
    verifyReportSelection(
      tester,
      reportIdWaterClaritySummary,
      "Water Clarity Summary",
      isVisible: false,
    );
  });

  testWidgets("Personal bests is shown", (tester) async {
    stubCatchesByTimestamp();

    await tester.pumpWidget(Testable((_) => StatsPage()));

    expect(find.byType(PersonalBestsReport), findsOneWidget);
  });

  testWidgets("Trip summary is shown", (tester) async {
    stubCatchesByTimestamp();
    stubSingleReport(Report(id: reportIdTripSummary));

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Trip Summary"));

    expect(find.byType(TripSummary), findsOneWidget);
  });

  testWidgets("CatchSummaryReport with all filter types", (tester) async {
    stubCatchesByTimestamp();
    stubSingleReport(
      Report(
        id: randomId(),
        name: "Test Summary",
        type: Report_Type.summary,
        waterDepthFilter: NumberFilter(),
        waterTemperatureFilter: NumberFilter(),
        lengthFilter: NumberFilter(),
        weightFilter: NumberFilter(),
        quantityFilter: NumberFilter(),
        airTemperatureFilter: NumberFilter(),
        airPressureFilter: NumberFilter(),
        airHumidityFilter: NumberFilter(),
        airVisibilityFilter: NumberFilter(),
        windSpeedFilter: NumberFilter(),
      ),
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Test Summary"));

    var filterOptionsBytes = verify(
      managers.isolatesWrapper.computeIntList(any, captureAny),
    ).captured.first;
    var filterOptions = CatchFilterOptions.fromBuffer(filterOptionsBytes);

    expect(filterOptions.hasWaterDepthFilter(), isTrue);
    expect(filterOptions.hasWaterTemperatureFilter(), isTrue);
    expect(filterOptions.hasLengthFilter(), isTrue);
    expect(filterOptions.hasWeightFilter(), isTrue);
    expect(filterOptions.hasQuantityFilter(), isTrue);
    expect(filterOptions.hasAirTemperatureFilter(), isTrue);
    expect(filterOptions.hasAirPressureFilter(), isTrue);
    expect(filterOptions.hasAirHumidityFilter(), isTrue);
    expect(filterOptions.hasAirVisibilityFilter(), isTrue);
    expect(filterOptions.hasWindSpeedFilter(), isTrue);
  });

  testWidgets("CatchSummaryReport with no filter types", (tester) async {
    stubCatchesByTimestamp();
    stubSingleReport(
      Report(id: randomId(), name: "Test Summary", type: Report_Type.summary),
    );

    await tester.pumpWidget(Testable((_) => StatsPage()));

    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Test Summary"));

    var filterOptions =
        verify(
              managers.catchManager.catches(any, opt: captureAnyNamed("opt")),
            ).captured.first
            as CatchFilterOptions;

    expect(filterOptions.hasWaterDepthFilter(), isFalse);
    expect(filterOptions.hasWaterTemperatureFilter(), isFalse);
    expect(filterOptions.hasLengthFilter(), isFalse);
    expect(filterOptions.hasWeightFilter(), isFalse);
    expect(filterOptions.hasQuantityFilter(), isFalse);
    expect(filterOptions.hasAirTemperatureFilter(), isFalse);
    expect(filterOptions.hasAirPressureFilter(), isFalse);
    expect(filterOptions.hasAirHumidityFilter(), isFalse);
    expect(filterOptions.hasAirVisibilityFilter(), isFalse);
    expect(filterOptions.hasWindSpeedFilter(), isFalse);
  });
}
