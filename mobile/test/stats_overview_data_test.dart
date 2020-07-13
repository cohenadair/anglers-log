import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/stats/stats_overview_data.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/time.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockClock extends Mock implements Clock {}
class MockSpeciesManager extends Mock implements SpeciesManager {}

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockClock clock;
  MockSpeciesManager speciesManager;

  Map<String, Species> speciesMap = {
    "Bass": Species(id: "Bass", name: "Bass"),
    "Bluegill": Species(id: "Bluegill", name: "Bluegill"),
    "Catfish": Species(id: "Catfish", name: "Catfish"),
    "Steelhead": Species(id: "Steelhead", name: "Steelhead"),
    "Pike": Species(id: "Pike", name: "Pike"),
  };

  setUp(() {
    appManager = MockAppManager();

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    clock = MockClock();

    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);
    when(speciesManager.entityList).thenReturn(speciesMap.values.toList());
    when(speciesManager.entity(id: anyNamed("id"))).thenAnswer((invocation) =>
        speciesMap[invocation.namedArguments[Symbol("id")]]);
  });

  testWidgets("", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);

    List<Catch> catches = [
      Catch(timestamp: 10, speciesId: "Bass"),
      Catch(timestamp: 5000, speciesId: "Steelhead"),
      Catch(timestamp: 100, speciesId: "Bluegill"),
      Catch(timestamp: 900, speciesId: "Pike"),
      Catch(timestamp: 78000, speciesId: "Steelhead"),
      Catch(timestamp: 100000, speciesId: "Bass"),
      Catch(timestamp: 800, speciesId: "Pike"),
      Catch(timestamp: 70, speciesId: "Pike"),
      Catch(timestamp: 15, speciesId: "Pike"),
      Catch(timestamp: 6000, speciesId: "Steelhead"),
    ];
    when(catchManager.entityList).thenReturn(catches);
    when(catchManager.catchesSortedByTimestamp(context)).thenReturn(
        catches..sort((lhs, rhs) => rhs.timestamp.compareTo(lhs.timestamp)));
    when(clock.now()).thenReturn(DateTime.fromMillisecondsSinceEpoch(105000));

    // Normal use case.
    var data = StatsOverviewData(
      appManager: appManager,
      context: context,
      displayDateRange: DisplayDateRange.allDates,
      clock: clock,
    );

    expect(data.msSinceLastCatch, 5000);
    expect(data.totalCatches, 10);
    expect(data.allCatchesPerSpecies.length, 5);
    expect(data.allCatchesPerSpecies[speciesMap["Bass"]], 2);
    expect(data.allCatchesPerSpecies[speciesMap["Steelhead"]], 3);
    expect(data.allCatchesPerSpecies[speciesMap["Pike"]], 4);
    expect(data.allCatchesPerSpecies[speciesMap["Bluegill"]], 1);
    expect(data.allCatchesPerSpecies[speciesMap["Catfish"]], 0);

    // Quantity limits.
    List<Species> orderedSpecies = data.catchesPerSpecies().keys.toList();
    expect(orderedSpecies.length, 5);
    expect(orderedSpecies[0].id, "Pike");
    expect(orderedSpecies[1].id, "Steelhead");
    expect(orderedSpecies[2].id, "Bass");
    expect(orderedSpecies[3].id, "Bluegill");
    expect(orderedSpecies[4].id, "Catfish");

    orderedSpecies = data.catchesPerSpecies(maxResultLength: 3).keys.toList();
    expect(orderedSpecies.length, 3);
    expect(orderedSpecies[0].id, "Pike");
    expect(orderedSpecies[1].id, "Steelhead");
    expect(orderedSpecies[2].id, "Bass");

    // Different date range.
    data = StatsOverviewData(
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
    expect(data.allCatchesPerSpecies.length, 5);
    expect(data.allCatchesPerSpecies[speciesMap["Bass"]], 1);
    expect(data.allCatchesPerSpecies[speciesMap["Steelhead"]], 0);
    expect(data.allCatchesPerSpecies[speciesMap["Pike"]], 4);
    expect(data.allCatchesPerSpecies[speciesMap["Bluegill"]], 1);
    expect(data.allCatchesPerSpecies[speciesMap["Catfish"]], 0);
  });
}