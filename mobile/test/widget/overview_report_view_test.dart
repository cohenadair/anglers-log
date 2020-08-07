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
import 'package:mobile/widgets/overview_report_view.dart';
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
    "Bass": Species(id: "Bass", name: "Bass"),
    "Bluegill": Species(id: "Bluegill", name: "Bluegill"),
    "Catfish": Species(id: "Catfish", name: "Catfish"),
    "Steelhead": Species(id: "Steelhead", name: "Steelhead"),
    "Pike": Species(id: "Pike", name: "Pike"),
  };

  Map<String, FishingSpot> fishingSpotMap = {
    "A": FishingSpot(id: "A", lat: 0.0, lng: 0.4),
    "B": FishingSpot(id: "B", lat: 0.1, lng: 0.3),
    "C": FishingSpot(id: "C", lat: 0.2, lng: 0.2),
    "D": FishingSpot(id: "D", lat: 0.3, lng: 0.1),
    "E": FishingSpot(id: "E", lat: 0.4, lng: 0.0),
  };

  Map<String, Bait> baitMap = {
    "Worm": Bait(id: "Worm", name: "Worm"),
    "Bugger": Bait(id: "Bugger", name: "Bugger"),
    "Minnow": Bait(id: "Minnow", name: "Minnow"),
    "Grasshopper": Bait(id: "Grasshopper", name: "Grasshopper"),
    "Grub": Bait(id: "Grub", name: "Grub"),
  };

  setUp(() {
    appManager = MockAppManager();

    baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);
    when(baitManager.entityList).thenReturn(baitMap.values.toList());
    when(baitManager.entity(id: anyNamed("id"))).thenAnswer((invocation) =>
        baitMap[invocation.namedArguments[Symbol("id")]]);
    when(baitManager.entityExists(id: anyNamed("id")))
        .thenAnswer((invocation) =>
            baitMap.containsKey(invocation.namedArguments[Symbol("id")]));

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    clock = MockClock();

    fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.entityList)
        .thenReturn(fishingSpotMap.values.toList());
    when(fishingSpotManager.entity(id: anyNamed("id")))
        .thenAnswer((invocation) =>
            fishingSpotMap[invocation.namedArguments[Symbol("id")]]);
    when(fishingSpotManager.entityExists(id: anyNamed("id")))
        .thenAnswer((invocation) => fishingSpotMap
            .containsKey(invocation.namedArguments[Symbol("id")]));

    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.entityList).thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(id: anyNamed("id"))).thenAnswer((invocation) =>
        speciesMap[invocation.namedArguments[Symbol("id")]]);
  });

  testWidgets("Gather data", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);

    List<Catch> catches = [
      Catch(timestamp: 10, speciesId: "Bass",
        fishingSpotId: "C",
        baitId: "Worm",
      ),
      Catch(timestamp: 5000, speciesId: "Steelhead",
        fishingSpotId: "D",
        baitId: "Grub",
      ),
      Catch(timestamp: 100, speciesId: "Bluegill",
        fishingSpotId: "A",
        baitId: "Worm",
      ),
      Catch(timestamp: 900, speciesId: "Pike",
        fishingSpotId: "E",
        baitId: "Bugger",
      ),
      Catch(timestamp: 78000, speciesId: "Steelhead",
        fishingSpotId: "C",
        baitId: "Worm",
      ),
      Catch(timestamp: 100000, speciesId: "Bass",
        fishingSpotId: "C",
        baitId: "Minnow",
      ),
      Catch(timestamp: 800, speciesId: "Pike",
        fishingSpotId: "B",
        baitId: "Bugger",
      ),
      Catch(timestamp: 70, speciesId: "Pike",
        fishingSpotId: "C",
        baitId: "Worm",
      ),
      Catch(timestamp: 15, speciesId: "Pike",
        fishingSpotId: "C",
        baitId: "Bugger",
      ),
      Catch(timestamp: 6000, speciesId: "Steelhead",
        fishingSpotId: "C",
        baitId: "Worm",
      ),
    ];
    when(catchManager.entityList).thenReturn(catches);
    when(catchManager.catchesSortedByTimestamp(context)).thenReturn(
        catches..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)));
    when(clock.now()).thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));

    // Normal use case.
    var data = OverviewReportViewData(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
    );

    expect(data.msSinceLastCatch, 5000);
    expect(data.totalCatches, 10);
    expect(data.catchesPerSpecies.length, 5);
    expect(data.catchesPerSpecies[speciesMap["Bass"]], 2);
    expect(data.catchesPerSpecies[speciesMap["Steelhead"]], 3);
    expect(data.catchesPerSpecies[speciesMap["Pike"]], 4);
    expect(data.catchesPerSpecies[speciesMap["Bluegill"]], 1);
    expect(data.catchesPerSpecies[speciesMap["Catfish"]], 0);

    expect(data.totalFishingSpots, 5);
    expect(data.catchesPerFishingSpot.length, 5);
    expect(data.catchesPerFishingSpot[fishingSpotMap["A"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["B"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["C"]], 6);
    expect(data.catchesPerFishingSpot[fishingSpotMap["D"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["E"]], 1);

    expect(data.totalBaits, 4);
    expect(data.catchesPerBait.length, 5);
    expect(data.catchesPerBait[baitMap["Worm"]], 5);
    expect(data.catchesPerBait[baitMap["Bugger"]], 3);
    expect(data.catchesPerBait[baitMap["Minnow"]], 1);
    expect(data.catchesPerBait[baitMap["Grasshopper"]], 0);
    expect(data.catchesPerBait[baitMap["Grub"]], 1);

    // Different date range.
    data = OverviewReportViewData(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.newCustom(
        getTitle: (_) => "",
        getValue: (_) => DateRange(
          startDate: DateTime.fromMillisecondsSinceEpoch(0),
          endDate: DateTime.fromMillisecondsSinceEpoch(1000),
        ),
      ),
      clock: clock,
    );

    expect(data.msSinceLastCatch, 5000);
    expect(data.totalCatches, 6);
    expect(data.catchesPerSpecies.length, 5);
    expect(data.catchesPerSpecies[speciesMap["Bass"]], 1);
    expect(data.catchesPerSpecies[speciesMap["Steelhead"]], 0);
    expect(data.catchesPerSpecies[speciesMap["Pike"]], 4);
    expect(data.catchesPerSpecies[speciesMap["Bluegill"]], 1);
    expect(data.catchesPerSpecies[speciesMap["Catfish"]], 0);

    expect(data.totalFishingSpots, 4);
    expect(data.catchesPerFishingSpot.length, 5);
    expect(data.catchesPerFishingSpot[fishingSpotMap["A"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["B"]], 1);
    expect(data.catchesPerFishingSpot[fishingSpotMap["C"]], 3);
    expect(data.catchesPerFishingSpot[fishingSpotMap["D"]], 0);
    expect(data.catchesPerFishingSpot[fishingSpotMap["E"]], 1);

    expect(data.totalBaits, 2);
    expect(data.catchesPerBait.length, 5);
    expect(data.catchesPerBait[baitMap["Worm"]], 3);
    expect(data.catchesPerBait[baitMap["Bugger"]], 3);
    expect(data.catchesPerBait[baitMap["Minnow"]], 0);
    expect(data.catchesPerBait[baitMap["Grasshopper"]], 0);
    expect(data.catchesPerBait[baitMap["Grub"]], 0);
  });
}