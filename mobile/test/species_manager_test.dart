import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockDataManager dataManager;

  SpeciesManager speciesManager;

  setUp(() {
    appManager = MockAppManager();

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.addListener(any)).thenAnswer((_) {});

    speciesManager = SpeciesManager(appManager);
  });

  test("Number of baits", () {
    when(catchManager.entityList()).thenReturn([
      Catch(timestamp: 0, speciesId: "species_1"),
      Catch(timestamp: 0, speciesId: "species_1"),
      Catch(timestamp: 0, speciesId: "species_5"),
      Catch(timestamp: 0, speciesId: "species_4"),
      Catch(timestamp: 0, speciesId: "species_1"),
    ]);

    expect(speciesManager.numberOfCatches(null), 0);
    expect(speciesManager.numberOfCatches(
        Species(name: "Species 1", id: "species_1")), 3);
    expect(speciesManager.numberOfCatches(
        Species(name: "Species 1", id: "species_4")), 1);
    expect(speciesManager.numberOfCatches(
        Species(name: "Species 1", id: "species_5")), 1);
  });
}