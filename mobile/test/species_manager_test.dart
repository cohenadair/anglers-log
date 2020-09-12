import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
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

  test("Number of catches", () {
    Id speciesId0 = Id.random();
    Id speciesId3 = Id.random();
    Id speciesId4 = Id.random();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId4.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId3.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes,
    ]);

    expect(speciesManager.numberOfCatches(null), 0);
    expect(speciesManager.numberOfCatches(speciesId0), 3);
    expect(speciesManager.numberOfCatches(speciesId3), 1);
    expect(speciesManager.numberOfCatches(speciesId4), 1);
  });
}