import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
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

  Map<String, Species> speciesMap = {
    "Bluegill": Species(id: "Bluegill", name: "Bluegill"),
    "Pike": Species(id: "Pike", name: "Pike"),
    "Catfish": Species(id: "Catfish", name: "Catfish"),
    "Bass": Species(id: "Bass", name: "Bass"),
    "Steelhead": Species(id: "Steelhead", name: "Steelhead"),
  };

  Map<String, FishingSpot> fishingSpotMap = {
    "E": FishingSpot(id: "E", name: "E", lat: 0.4, lng: 0.0),
    "C": FishingSpot(id: "C", name: "C",  lat: 0.2, lng: 0.2),
    "B": FishingSpot(id: "B", name: "B",  lat: 0.1, lng: 0.3),
    "D": FishingSpot(id: "D", name: "D",  lat: 0.3, lng: 0.1),
    "A": FishingSpot(id: "A", name: "A",  lat: 0.0, lng: 0.4),
  };

  Map<String, Bait> baitMap = {
    "Worm": Bait(id: "Worm", name: "Worm"),
    "Bugger": Bait(id: "Bugger", name: "Bugger"),
    "Minnow": Bait(id: "Minnow", name: "Minnow"),
    "Grasshopper": Bait(id: "Grasshopper", name: "Grasshopper"),
    "Grub": Bait(id: "Grub", name: "Grub"),
  };

  List<Catch> _catches = [
    Catch(
      id: "0",
      timestamp: 10,
      speciesId: "Bass",
      fishingSpotId: "C",
      baitId: "Worm",
    ),
    Catch(
      id: "1",
      timestamp: 5000,
      speciesId: "Steelhead",
      fishingSpotId: "D",
      baitId: "Grub",
    ),
    Catch(
      id: "2",
      timestamp: 100,
      speciesId: "Bluegill",
      fishingSpotId: "A",
      baitId: "Worm",
    ),
    Catch(
      id: "3",
      timestamp: 900,
      speciesId: "Pike",
      fishingSpotId: "E",
      baitId: "Bugger",
    ),
    Catch(
      id: "4",
      timestamp: 78000,
      speciesId: "Steelhead",
      fishingSpotId: "C",
      baitId: "Worm",
    ),
    Catch(
      id: "5",
      timestamp: 100000,
      speciesId: "Bass",
      fishingSpotId: "C",
      baitId: "Minnow",
    ),
    Catch(
      id: "6",
      timestamp: 800,
      speciesId: "Pike",
      fishingSpotId: "B",
      baitId: "Bugger",
    ),
    Catch(
      id: "7",
      timestamp: 70,
      speciesId: "Pike",
      fishingSpotId: "C",
      baitId: "Worm",
    ),
    Catch(
      id: "8",
      timestamp: 15,
      speciesId: "Pike",
      fishingSpotId: "C",
      baitId: "Bugger",
    ),
    Catch(
      id: "9",
      timestamp: 6000,
      speciesId: "Steelhead",
      fishingSpotId: "C",
      baitId: "Worm",
    ),
  ];

  setUp(() {
    appManager = MockAppManager();

    baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);
    when(baitManager.entityList()).thenReturn(baitMap.values.toList());
    when(baitManager.entity(id: anyNamed("id"))).thenAnswer((invocation) =>
        baitMap[invocation.namedArguments[Symbol("id")]]);
    when(baitManager.entityExists(id: anyNamed("id")))
        .thenAnswer((invocation) =>
            baitMap.containsKey(invocation.namedArguments[Symbol("id")]));

    catchManager = MockCatchManager();
    when(catchManager.entityList()).thenReturn(_catches);
    when(appManager.catchManager).thenReturn(catchManager);

    clock = MockClock();
    when(clock.now()).thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));

    fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.entityList())
        .thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(id: anyNamed("id")))
        .thenAnswer((invocation) =>
            fishingSpotMap[invocation.namedArguments[Symbol("id")]]);
    when(fishingSpotManager.entityExists(id: anyNamed("id")))
        .thenAnswer((invocation) => fishingSpotMap
            .containsKey(invocation.namedArguments[Symbol("id")]));

    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.entityList()).thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(id: anyNamed("id"))).thenAnswer((invocation) =>
        speciesMap[invocation.namedArguments[Symbol("id")]]);
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
    expect(data.catchIdsPerSpecies[speciesMap["Bass"]], {"0", "5"});
    expect(data.catchIdsPerSpecies[speciesMap["Steelhead"]], {"9", "4", "1"});
    expect(data.catchIdsPerSpecies[speciesMap["Pike"]], {"8", "7", "6", "3"});
    expect(data.catchIdsPerSpecies[speciesMap["Bluegill"]], {"2"});
    expect(data.catchIdsPerSpecies[speciesMap["Catfish"]], null);
    expect(data.catchesPerSpecies[speciesMap["Bass"]], 2);
    expect(data.catchesPerSpecies[speciesMap["Steelhead"]], 3);
    expect(data.catchesPerSpecies[speciesMap["Pike"]], 4);
    expect(data.catchesPerSpecies[speciesMap["Bluegill"]], 1);
    expect(data.catchesPerSpecies[speciesMap["Catfish"]], null);

    expect(data.catchesPerFishingSpot.length, 5);
    expect(data.catchesPerFishingSpot[fishingSpotMap["A"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["B"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["C"]], 6);
    expect(data.catchesPerFishingSpot[fishingSpotMap["D"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["E"]], 1);

    expect(data.catchesPerBait.length, 4);
    expect(data.catchesPerBait[baitMap["Worm"]], 5);
    expect(data.catchesPerBait[baitMap["Bugger"]], 3);
    expect(data.catchesPerBait[baitMap["Minnow"]], 1);
    expect(data.catchesPerBait[baitMap["Grasshopper"]], null);
    expect(data.catchesPerBait[baitMap["Grub"]], 1);

    expect(data.baitsPerSpecies(speciesMap["Pike"])[baitMap["Bugger"]], 3);
    expect(data.baitsPerSpecies(speciesMap["Pike"])[baitMap["Worm"]], 1);
    expect(data.baitsPerSpecies(speciesMap["Pike"])[baitMap["Grub"]], null);
    expect(data.baitsPerSpecies(speciesMap["Pike"])[baitMap["Minnow"]], null);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"])[baitMap["Bugger"]],
        null);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"])[baitMap["Worm"]], 2);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"])[baitMap["Grub"]], 1);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"])[baitMap["Minnow"]],
        null);
    expect(data.baitsPerSpecies(speciesMap["Bass"])[baitMap["Bugger"]], null);
    expect(data.baitsPerSpecies(speciesMap["Bass"])[baitMap["Worm"]], 1);
    expect(data.baitsPerSpecies(speciesMap["Bass"])[baitMap["Grub"]], null);
    expect(data.baitsPerSpecies(speciesMap["Bass"])[baitMap["Minnow"]], 1);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"])[baitMap["Bugger"]],
        null);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"])[baitMap["Worm"]], 1);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"])[baitMap["Grub"]], null);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"])[baitMap["Minnow"]],
        null);
    expect(data.baitsPerSpecies(speciesMap["Catfish"]), {});

    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"])[fishingSpotMap["A"]],
        null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"])[fishingSpotMap["B"]],
        1);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"])[fishingSpotMap["C"]],
        2);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"])[fishingSpotMap["D"]],
        null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"])[fishingSpotMap["E"]],
        1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Steelhead"])[fishingSpotMap["A"]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Steelhead"])[fishingSpotMap["B"]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Steelhead"])[fishingSpotMap["C"]], 2);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Steelhead"])[fishingSpotMap["D"]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Steelhead"])[fishingSpotMap["E"]], null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"])[fishingSpotMap["A"]],
        null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"])[fishingSpotMap["B"]],
        null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"])[fishingSpotMap["C"]],
        2);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"])[fishingSpotMap["D"]],
        null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"])[fishingSpotMap["E"]],
        null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Bluegill"])[fishingSpotMap["A"]], 1);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Bluegill"])[fishingSpotMap["B"]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Bluegill"])[fishingSpotMap["C"]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Bluegill"])[fishingSpotMap["D"]], null);
    expect(data.fishingSpotsPerSpecies(
        speciesMap["Bluegill"])[fishingSpotMap["E"]], null);
    expect(data.fishingSpotsPerSpecies(speciesMap["Catfish"]), {});
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
      speciesMap["Bass"],
      speciesMap["Bluegill"],
      speciesMap["Pike"],
      speciesMap["Steelhead"],
    ]);
    expect(data.catchesPerFishingSpot.keys.toList(), [
      fishingSpotMap["A"],
      fishingSpotMap["B"],
      fishingSpotMap["C"],
      fishingSpotMap["D"],
      fishingSpotMap["E"],
    ]);
    expect(data.catchesPerBait.keys.toList(), [
      baitMap["Bugger"],
      baitMap["Grub"],
      baitMap["Minnow"],
      baitMap["Worm"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"]).keys.toList(), [
      fishingSpotMap["C"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bluegill"]).keys.toList(), [
      fishingSpotMap["A"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Catfish"]).keys.toList(),
        []);
    expect(data.fishingSpotsPerSpecies(speciesMap["Steelhead"]).keys.toList(), [
      fishingSpotMap["C"],
      fishingSpotMap["D"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"]).keys.toList(), [
      fishingSpotMap["B"],
      fishingSpotMap["C"],
      fishingSpotMap["E"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Bass"]).keys.toList(), [
      baitMap["Minnow"],
      baitMap["Worm"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"]).keys.toList(), [
      baitMap["Worm"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Catfish"]).keys.toList(), []);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"]).keys.toList(), [
      baitMap["Grub"],
      baitMap["Worm"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Pike"]).keys.toList(), [
      baitMap["Bugger"],
      baitMap["Worm"],
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
      speciesMap["Pike"],
      speciesMap["Steelhead"],
      speciesMap["Bass"],
      speciesMap["Bluegill"],
    ]);
    expect(data.catchesPerFishingSpot.keys.toList(), [
      fishingSpotMap["C"],
      fishingSpotMap["D"],
      fishingSpotMap["E"],
      fishingSpotMap["B"],
      fishingSpotMap["A"],
    ]);
    expect(data.catchesPerBait.keys.toList(), [
      baitMap["Worm"],
      baitMap["Bugger"],
      baitMap["Minnow"],
      baitMap["Grub"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bass"]).keys.toList(), [
      fishingSpotMap["C"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Bluegill"]).keys.toList(), [
      fishingSpotMap["A"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Catfish"]).keys.toList(),
        []);
    expect(data.fishingSpotsPerSpecies(speciesMap["Steelhead"]).keys.toList(), [
      fishingSpotMap["C"],
      fishingSpotMap["D"],
    ]);
    expect(data.fishingSpotsPerSpecies(speciesMap["Pike"]).keys.toList(), [
      fishingSpotMap["C"],
      fishingSpotMap["E"],
      fishingSpotMap["B"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Bass"]).keys.toList(), [
      baitMap["Minnow"],
      baitMap["Worm"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Bluegill"]).keys.toList(), [
      baitMap["Worm"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Catfish"]).keys.toList(), []);
    expect(data.baitsPerSpecies(speciesMap["Steelhead"]).keys.toList(), [
      baitMap["Worm"],
      baitMap["Grub"],
    ]);
    expect(data.baitsPerSpecies(speciesMap["Pike"]).keys.toList(), [
      baitMap["Bugger"],
      baitMap["Worm"],
    ]);
  });

  testWidgets("Filters", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    _stubCatchesByTimestamp(context);

    var data = ReportSummaryModel(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
      baitIds: {"Worm", "Grub"},
      fishingSpotIds: {"E", "B", "C"},
      speciesIds: {"Steelhead", "Catfish"},
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