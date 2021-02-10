import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockDataManager dataManager;

  SpeciesManager speciesManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockCatchManager: true,
      mockDataManager: true,
      mockSubscriptionManager: true,
    );

    var authStream = MockStream<void>();
    when(authStream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => authStream);

    catchManager = appManager.mockCatchManager;
    when(appManager.catchManager).thenReturn(catchManager);

    dataManager = appManager.mockDataManager;
    when(appManager.dataManager).thenReturn(dataManager);
    var dataStream = MockStream<DataManagerEvent>();
    when(dataStream.listen(any)).thenReturn(null);
    when(appManager.mockDataManager.stream).thenAnswer((_) => dataStream);

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    speciesManager = SpeciesManager(appManager);
  });

  test("Number of catches", () {
    var speciesId0 = randomId();
    var speciesId3 = randomId();
    var speciesId4 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId4,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId3,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0,
    ]);

    expect(speciesManager.numberOfCatches(null), 0);
    expect(speciesManager.numberOfCatches(speciesId0), 3);
    expect(speciesManager.numberOfCatches(speciesId3), 1);
    expect(speciesManager.numberOfCatches(speciesId4), 1);
  });
}
