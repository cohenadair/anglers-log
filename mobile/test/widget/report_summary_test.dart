import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/reports/report_summary.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/time.dart';

import '../test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockClock extends Mock implements Clock {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockSpeciesManager extends Mock implements SpeciesManager {}

void main() {
  MockAppManager appManager;
  MockBaitManager baitManager;
  MockCatchManager catchManager;
  MockClock clock;
  MockFishingSpotManager fishingSpotManager;
  MockSpeciesManager speciesManager;

  Id speciesId0 = randomId();
  Id speciesId1 = randomId();
  Id speciesId2 = randomId();
  Id speciesId3 = randomId();
  Id speciesId4 = randomId();

  Id fishingSpotId0 = randomId();
  Id fishingSpotId1 = randomId();
  Id fishingSpotId2 = randomId();
  Id fishingSpotId3 = randomId();
  Id fishingSpotId4 = randomId();

  Id baitId0 = randomId();
  Id baitId1 = randomId();
  Id baitId2 = randomId();
  Id baitId3 = randomId();
  Id baitId4 = randomId();

  Id catchId0 = randomId();
  Id catchId1 = randomId();
  Id catchId2 = randomId();
  Id catchId3 = randomId();
  Id catchId4 = randomId();
  Id catchId5 = randomId();
  Id catchId6 = randomId();
  Id catchId7 = randomId();
  Id catchId8 = randomId();
  Id catchId9 = randomId();

  Map<Id, Species> speciesMap = {
    speciesId0: Species()..id = speciesId0..name = "Bluegill",
    speciesId1: Species()..id = speciesId1..name = "Pike",
    speciesId2: Species()..id = speciesId2..name = "Catfish",
    speciesId3: Species()..id = speciesId3..name = "Bass",
    speciesId4: Species()..id = speciesId4..name = "Steelhead",
  };

  Map<Id, FishingSpot> fishingSpotMap = {
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

  Map<Id, Bait> baitMap = {
    baitId0: Bait()..id = baitId0..name = "Worm",
    baitId1: Bait()..id = baitId1..name = "Bugger",
    baitId2: Bait()..id = baitId2..name = "Minnow",
    baitId3: Bait()..id = baitId3..name = "Grasshopper",
    baitId4: Bait()..id = baitId4..name = "Grub",
  };

  List<Catch> _catches = [
    Catch()
      ..id = catchId0
      ..timestamp = timestampFromMillis(10)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId1
      ..timestamp = timestampFromMillis(5000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId3
      ..baitId = baitId4,
    Catch()
      ..id = catchId2
      ..timestamp = timestampFromMillis(100)
      ..speciesId = speciesId0
      ..fishingSpotId = fishingSpotId4
      ..baitId = baitId0,
    Catch()
      ..id = catchId3
      ..timestamp = timestampFromMillis(900)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId0
      ..baitId = baitId1,
    Catch()
      ..id = catchId4
      ..timestamp = timestampFromMillis(78000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId5
      ..timestamp = timestampFromMillis(100000)
      ..speciesId = speciesId3
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId2,
    Catch()
      ..id = catchId6
      ..timestamp = timestampFromMillis(800)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId2
      ..baitId = baitId1,
    Catch()
      ..id = catchId7
      ..timestamp = timestampFromMillis(70)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
    Catch()
      ..id = catchId8
      ..timestamp = timestampFromMillis(15)
      ..speciesId = speciesId1
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId1,
    Catch()
      ..id = catchId9
      ..timestamp = timestampFromMillis(6000)
      ..speciesId = speciesId4
      ..fishingSpotId = fishingSpotId1
      ..baitId = baitId0,
  ];

  setUp(() {
    appManager = MockAppManager();

    baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);
    when(baitManager.list()).thenReturn(baitMap.values.toList());
    when(baitManager.entity(any)).thenAnswer((invocation) =>
        baitMap[invocation.positionalArguments[0]]);

    catchManager = MockCatchManager();
    when(catchManager.list()).thenReturn(_catches);
    when(appManager.catchManager).thenReturn(catchManager);

    clock = MockClock();
    when(clock.now()).thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));

    fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.list()).thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(any)).thenAnswer((invocation) =>
        fishingSpotMap[invocation.positionalArguments[0]]);

    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.list()).thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(any)).thenAnswer((invocation) =>
        speciesMap[invocation.positionalArguments[0]]);
  });

  void _stubCatchesByTimestamp(BuildContext context) {
    when(catchManager.catchesSortedByTimestamp(context,
      dateRange: anyNamed("dateRange"),
      baitIds: anyNamed("baitIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      speciesIds: anyNamed("speciesIds"),
    )).thenReturn(
        _catches..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)));
  }

  testWidgets("Gather data normal case", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    // Normal use case.
    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
    );
    
    expect(data.containsNow, true);
    expect(data.msSinceLastCatch, 5000);
    expect(data.totalCatches, 10);
    expect(data.catchesPerSpecies.length, 4);
    expect(data.allCatchIds, _catches.map((c) => c.id).toSet());
    expect(data.catchIdsPerSpecies[speciesMap[speciesId3]], {catchId0, catchId5});
    expect(data.catchIdsPerSpecies[speciesMap[speciesId4]],
        {catchId9, catchId4, catchId1});
    expect(data.catchIdsPerSpecies[speciesMap[speciesId1]],
        {catchId8, catchId7, catchId6, catchId3});
    expect(data.catchIdsPerSpecies[speciesMap[speciesId0]], {catchId2});
    expect(data.catchIdsPerSpecies[speciesMap[speciesId2]], null);
    expect(data.catchesPerSpecies[speciesMap[speciesId3]], 2);
    expect(data.catchesPerSpecies[speciesMap[speciesId4]], 3);
    expect(data.catchesPerSpecies[speciesMap[speciesId1]], 4);
    expect(data.catchesPerSpecies[speciesMap[speciesId0]], 1);
    expect(data.catchesPerSpecies[speciesMap[speciesId2]], null);

    expect(data.catchesPerFishingSpot.length, 5);
    expect(data.catchesPerFishingSpot[fishingSpotMap[fishingSpotId4]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap[fishingSpotId2]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap[fishingSpotId1]], 6);
    expect(data.catchesPerFishingSpot[fishingSpotMap[fishingSpotId3]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap[fishingSpotId0]], 1);
    
    expect(data.catchesPerBait.length, 4);
    expect(data.catchesPerBait[baitMap[baitId0]], 5);
    expect(data.catchesPerBait[baitMap[baitId1]], 3);
    expect(data.catchesPerBait[baitMap[baitId2]], 1);
    expect(data.catchesPerBait[baitMap[baitId3]], null);
    expect(data.catchesPerBait[baitMap[baitId4]], 1);

    expect(data.baitsPerSpecies(speciesMap[speciesId1])[baitMap[baitId1]], 3);
    expect(data.baitsPerSpecies(speciesMap[speciesId1])[baitMap[baitId0]], 1);
    expect(data.baitsPerSpecies(speciesMap[speciesId1])[baitMap[baitId4]], null);
    expect(data.baitsPerSpecies(speciesMap[speciesId1])[baitMap[baitId2]], null);
    expect(data.baitsPerSpecies(speciesMap[speciesId4])[baitMap[baitId1]],
        null);
    expect(data.baitsPerSpecies(speciesMap[speciesId4])[baitMap[baitId0]], 2);
    expect(data.baitsPerSpecies(speciesMap[speciesId4])[baitMap[baitId4]], 1);
    expect(data.baitsPerSpecies(speciesMap[speciesId4])[baitMap[baitId2]],
        null);
    expect(data.baitsPerSpecies(speciesMap[speciesId3])[baitMap[baitId1]], null);
    expect(data.baitsPerSpecies(speciesMap[speciesId3])[baitMap[baitId0]], 1);
    expect(data.baitsPerSpecies(speciesMap[speciesId3])[baitMap[baitId4]], null);
    expect(data.baitsPerSpecies(speciesMap[speciesId3])[baitMap[baitId2]], 1);
    expect(data.baitsPerSpecies(speciesMap[speciesId0])[baitMap[baitId1]],
        null);
    expect(data.baitsPerSpecies(speciesMap[speciesId0])[baitMap[baitId0]], 1);
    expect(data.baitsPerSpecies(speciesMap[speciesId0])[baitMap[baitId4]], null);
    expect(data.baitsPerSpecies(speciesMap[speciesId0])[baitMap[baitId2]],
        null);
    expect(data.baitsPerSpecies(speciesMap[speciesId2]), {});

    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId1])[fishingSpotMap[fishingSpotId4]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId1])[fishingSpotMap[fishingSpotId2]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId1])[fishingSpotMap[fishingSpotId1]], 2);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId1])[fishingSpotMap[fishingSpotId3]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId1])[fishingSpotMap[fishingSpotId0]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId4])[fishingSpotMap[fishingSpotId4]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId4])[fishingSpotMap[fishingSpotId2]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId4])[fishingSpotMap[fishingSpotId1]], 2);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId4])[fishingSpotMap[fishingSpotId3]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId4])[fishingSpotMap[fishingSpotId0]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId3])[fishingSpotMap[fishingSpotId4]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId3])[fishingSpotMap[fishingSpotId2]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId3])[fishingSpotMap[fishingSpotId1]], 2);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId3])[fishingSpotMap[fishingSpotId3]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId3])[fishingSpotMap[fishingSpotId0]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId0])[fishingSpotMap[fishingSpotId4]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId0])[fishingSpotMap[fishingSpotId2]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId0])[fishingSpotMap[fishingSpotId1]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId0])[fishingSpotMap[fishingSpotId3]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap[speciesId0])[fishingSpotMap[fishingSpotId0]], null);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId2]), {});
  });

  testWidgets("Gather data including zeros", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      includeZeros: true,
    );

    expect(data.catchesPerSpecies.length, 5);
  });

  testWidgets("Gather data alphabetical order", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      sortOrder: ReportSummaryModelSortOrder.alphabetical,
    );

    expect(data.catchesPerSpecies.keys.toList(), [
      speciesMap[speciesId3],
      speciesMap[speciesId0],
      speciesMap[speciesId1],
      speciesMap[speciesId4],
    ]);
    expect(data.catchesPerFishingSpot.keys.toList(), [
      fishingSpotMap[fishingSpotId4],
      fishingSpotMap[fishingSpotId2],
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId3],
      fishingSpotMap[fishingSpotId0],
    ]);
    expect(data.catchesPerBait.keys.toList(), [
      baitMap[baitId1],
      baitMap[baitId4],
      baitMap[baitId2],
      baitMap[baitId0],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId3]).keys.toList(), [
      fishingSpotMap[fishingSpotId1],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId0]).keys.toList(), [
      fishingSpotMap[fishingSpotId4],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId2]).keys.toList(),
        []);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId4]).keys.toList(), [
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId3],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId1]).keys.toList(), [
      fishingSpotMap[fishingSpotId2],
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId3]).keys.toList(), [
      baitMap[baitId2],
      baitMap[baitId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId0]).keys.toList(), [
      baitMap[baitId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId2]).keys.toList(), []);
    expect(data.baitsPerSpecies(speciesMap[speciesId4]).keys.toList(), [
      baitMap[baitId4],
      baitMap[baitId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId1]).keys.toList(), [
      baitMap[baitId1],
      baitMap[baitId0],
    ]);
  });

  testWidgets("Gather data sequential order", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
    );

    expect(data.catchesPerSpecies.keys.toList(), [
      speciesMap[speciesId1],
      speciesMap[speciesId4],
      speciesMap[speciesId3],
      speciesMap[speciesId0],
    ]);
    expect(data.catchesPerFishingSpot.keys.toList(), [
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId3],
      fishingSpotMap[fishingSpotId0],
      fishingSpotMap[fishingSpotId2],
      fishingSpotMap[fishingSpotId4],
    ]);
    expect(data.catchesPerBait.keys.toList(), [
      baitMap[baitId0],
      baitMap[baitId1],
      baitMap[baitId2],
      baitMap[baitId4],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId3]).keys.toList(), [
      fishingSpotMap[fishingSpotId1],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId0]).keys.toList(), [
      fishingSpotMap[fishingSpotId4],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId2]).keys.toList(),
        []);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId4]).keys.toList(), [
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId3],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap[speciesId1]).keys.toList(), [
      fishingSpotMap[fishingSpotId1],
      fishingSpotMap[fishingSpotId0],
      fishingSpotMap[fishingSpotId2],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId3]).keys.toList(), [
      baitMap[baitId2],
      baitMap[baitId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId0]).keys.toList(), [
      baitMap[baitId0],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId2]).keys.toList(), []);
    expect(data.baitsPerSpecies(speciesMap[speciesId4]).keys.toList(), [
      baitMap[baitId0],
      baitMap[baitId4],
    ]);
    expect(data.baitsPerSpecies(speciesMap[speciesId1]).keys.toList(), [
      baitMap[baitId1],
      baitMap[baitId0],
    ]);
  });

  testWidgets("Filters", (WidgetTester tester) async {
    when(baitManager.entity(any)).thenAnswer((invocation) =>
        baitMap[invocation.positionalArguments[0]]);
    when(fishingSpotManager.entity(any)).thenAnswer((invocation) =>
        fishingSpotMap[invocation.positionalArguments[0]]);
    when(speciesManager.entity(any)).thenAnswer((invocation) =>
        speciesMap[invocation.positionalArguments[0]]);

    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      baitIds: {baitId0, baitId4},
      fishingSpotIds: {fishingSpotId0, fishingSpotId2, fishingSpotId1},
      speciesIds: {speciesId4, speciesId2},
    );

    expect(data.filters(),
        {"All dates", "Worm", "Grub", "E", "B", "C", "Steelhead", "Catfish"});
    expect(data.filters(includeSpecies: false),
        {"All dates", "Worm", "Grub", "E", "B", "C"});
    expect(data.filters(includeDateRange: false),
        {"Worm", "Grub", "E", "B", "C", "Steelhead", "Catfish"});
    expect(data.filters(includeSpecies: false, includeDateRange: false),
        {"Worm", "Grub", "E", "B", "C"});
  });

  testWidgets("Filters with null values", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      baitIds: {baitId0, baitId4},
      fishingSpotIds: {fishingSpotId0, fishingSpotId2, fishingSpotId1},
      speciesIds: {speciesId4, speciesId2},
    );

    // By not stubbing EntityManager.entity() methods, no filters should be
    // entity names.
    when(baitManager.entity(any)).thenReturn(null);
    when(fishingSpotManager.entity(any)).thenReturn(null);
    when(speciesManager.entity(any)).thenReturn(null);

    expect(data.filters(), {"All dates"});
    expect(data.filters(includeSpecies: false), {"All dates"});
    expect(data.filters(includeDateRange: false), Set.of([]));
    expect(data.filters(includeSpecies: false, includeDateRange: false),
        Set.of([]));
  });

  testWidgets("removeZerosComparedTo", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data1 = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      includeZeros: true,
    );
    expect(data1.catchesPerSpecies.length, 5);

    var data2 = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      includeZeros: true,
    );
    expect(data2.catchesPerSpecies.length, 5);

    // Both data sets will be missing catfish.
    data1.removeZerosComparedTo(data2);
    expect(data1.catchesPerSpecies.length, 4);
    expect(data2.catchesPerSpecies.length, 4);
  });
}