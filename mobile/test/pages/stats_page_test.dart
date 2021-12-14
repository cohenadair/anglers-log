import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
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
      for (var attachment in invocation.positionalArguments[1]) {
        result.add(baitMap[attachment.baitId]!.name);
      }
      return result;
    });

    when(appManager.catchManager.catches(
      any,
      dateRange: anyNamed("dateRange"),
      baits: anyNamed("baits"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn([]);
    when(appManager.catchManager.list()).thenReturn(_catches);
    when(appManager.catchManager.hasEntities).thenReturn(false);

    when(appManager.reportManager.list()).thenReturn([]);
    when(appManager.reportManager.listSortedByName()).thenReturn([]);
    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.nameComparator)
        .thenReturn((lhs, rhs) => quiver.compareIgnoreCase(lhs.name, rhs.name));
    when(appManager.reportManager.defaultReports).thenReturn([
      Report(id: reportIdPersonalBests),
    ]);
    when(appManager.reportManager.defaultReport)
        .thenReturn(Report(id: reportIdPersonalBests));
    when(appManager.reportManager.displayName(any, any))
        .thenAnswer((invocation) {
      var id = invocation.positionalArguments[1].id;
      if (id == reportIdPersonalBests) {
        return "Overview";
      }
      return invocation.positionalArguments[1].name;
    });

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
    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingPeriods).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingSeasons).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingTides).thenReturn(false);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(false);
  });

  void _stubCatchesByTimestamp([List<Catch>? catches]) {
    when(appManager.catchManager.catches(
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
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tester.ensureVisible(find.text("Comparison"));
    await tapAndSettle(tester, find.text("Comparison"));
    expect(find.text("Comparison"), findsOneWidget);

    // Simulate deleting the report.
    await comparisonReportManager.delete(reportId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsNothing);
    expect(find.text("Personal Bests"), findsOneWidget);
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
    await tapAndSettle(tester, find.text("Personal Bests"));
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
    expect(find.text("Personal Bests"), findsNothing);
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
    await tapAndSettle(tester, find.text("Personal Bests"));
    await tapAndSettle(tester, find.text("Comparison"));

    // Simulate deleting a report that isn't selected.
    await reportManager.delete(summaryId);

    // Wait for listeners to be invoked.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text("Comparison"), findsOneWidget);
  });
}
