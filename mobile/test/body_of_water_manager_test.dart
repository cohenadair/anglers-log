import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late MockFishingSpotManager fishingSpotManager;

  late BodyOfWaterManager bodyOfWaterManager;

  setUp(() async {
    managers = await StubbedManagers.create();

    fishingSpotManager = managers.fishingSpotManager;

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    bodyOfWaterManager = BodyOfWaterManager(managers.app);
  });

  test("Number of fishing spots", () {
    var bodyOfWaterId0 = randomId();
    var bodyOfWaterId1 = randomId();
    var bodyOfWaterId2 = randomId();

    when(fishingSpotManager.list()).thenReturn([
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId2,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId1,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
    ]);

    expect(bodyOfWaterManager.numberOfFishingSpots(bodyOfWaterId0), 3);
    expect(bodyOfWaterManager.numberOfFishingSpots(bodyOfWaterId1), 1);
    expect(bodyOfWaterManager.numberOfFishingSpots(bodyOfWaterId2), 1);
  });

  testWidgets("deleteMessage", (tester) async {
    var bodyOfWaterId0 = randomId();
    var bodyOfWaterId1 = randomId();
    var bodyOfWaterId2 = randomId();

    when(fishingSpotManager.list()).thenReturn([
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId2,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId1,
      FishingSpot()
        ..id = randomId()
        ..bodyOfWaterId = bodyOfWaterId0,
    ]);

    var context = await buildContext(tester);

    expect(
      bodyOfWaterManager.deleteMessage(
        context,
        BodyOfWater(
          id: bodyOfWaterId0,
          name: "Body Of Water 1",
        ),
      ),
      "Body Of Water 1 is associated with 3 fishing spots; are you sure "
      "you want to delete it? This cannot be undone.",
    );

    expect(
      bodyOfWaterManager.deleteMessage(
        context,
        BodyOfWater(
          id: bodyOfWaterId1,
          name: "Body Of Water 2",
        ),
      ),
      "Body Of Water 2 is associated with 1 fishing spot; are you sure "
      "you want to delete it? This cannot be undone.",
    );
  });
}
