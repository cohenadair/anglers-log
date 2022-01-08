import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;

  late SpeciesManager speciesManager;

  setUp(() {
    appManager = StubbedAppManager();

    catchManager = appManager.catchManager;

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    speciesManager = SpeciesManager(appManager.app);
  });

  test("Number of catches", () {
    var speciesId0 = randomId();
    var speciesId3 = randomId();
    var speciesId4 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId4,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId3,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
    ]);

    expect(speciesManager.numberOfCatches(speciesId0), 3);
    expect(speciesManager.numberOfCatches(speciesId3), 1);
    expect(speciesManager.numberOfCatches(speciesId4), 1);
  });
}
