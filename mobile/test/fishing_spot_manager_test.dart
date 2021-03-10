import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockLocalDatabaseManager dataManager;
  FishingSpotManager fishingSpotManager;

  setUp(() async {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockCatchManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
    );

    var authStream = MockStream<void>();
    when(authStream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => authStream);

    catchManager = appManager.mockCatchManager;
    when(appManager.catchManager).thenReturn(catchManager);

    dataManager = appManager.mockLocalDatabaseManager;
    when(appManager.localDatabaseManager).thenReturn(dataManager);
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    fishingSpotManager = FishingSpotManager(appManager);
  });

  test("Fishing spot within radius", () async {
    // Null cases.
    var fishingSpot = fishingSpotManager.withinRadius(LatLng(0, 0), 20);
    expect(fishingSpot, isNull);

    fishingSpot = fishingSpotManager.withinRadius(null);
    expect(fishingSpot, isNull);

    var fishingSpotId0 = randomId();
    var fishingSpotId1 = randomId();
    var fishingSpotId2 = randomId();
    var fishingSpotId3 = randomId();
    var fishingSpotId4 = randomId();

    // Single fishing spot in radius.
    var newSpot = FishingSpot()
      ..id = fishingSpotId0
      ..lat = 35.955348
      ..lng = -84.240310;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot =
        fishingSpotManager.withinRadius(LatLng(35.955348, -84.240310), 20);
    expect(fishingSpot, isNotNull);
    await fishingSpotManager.delete(newSpot.id);

    // Single fishing spot outside radius.
    newSpot = FishingSpot()
      ..id = fishingSpotId1
      ..lat = 35.953638
      ..lng = -84.241233;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot =
        fishingSpotManager.withinRadius(LatLng(35.955348, -84.240310), 20);
    expect(fishingSpot, isNull);
    await fishingSpotManager.delete(newSpot.id);

    // Multiple fishing spots within radius.
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId2
      ..lat = 35.955296
      ..lng = -84.240337);
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId3
      ..lat = 35.955196
      ..lng = -84.240437);
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId4
      ..lat = 35.955335
      ..lng = -84.240300);

    fishingSpot =
        fishingSpotManager.withinRadius(LatLng(35.955340, -84.240295), 20);
    expect(fishingSpot, isNotNull);
    expect(fishingSpot.lat, 35.955335);
    expect(fishingSpot.lng, -84.240300);
  });

  test("Fishing spot with LatLng", () async {
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = randomId()
      ..lat = 35.955296
      ..lng = -84.240337);
    expect(
      fishingSpotManager.withLatLng(FishingSpot()
        ..id = randomId()
        ..lat = 35.955296
        ..lng = -84.240337),
      isNotNull,
    );
    expect(
      fishingSpotManager.withLatLng(FishingSpot()
        ..id = randomId()
        ..lat = 35.955297
        ..lng = -84.240337),
      isNull,
    );
    expect(fishingSpotManager.withLatLng(null), isNull);
  });

  test("Number of catches", () {
    var speciesId0 = randomId();

    var fishingSpotId0 = randomId();
    var fishingSpotId4 = randomId();
    var fishingSpotId3 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId0,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId4,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId3,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..fishingSpotId = fishingSpotId0,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
    ]);

    expect(fishingSpotManager.numberOfCatches(null), 0);
    expect(
      fishingSpotManager.numberOfCatches(FishingSpot()
        ..name = "Spot 1"
        ..id = fishingSpotId0
        ..lat = 0
        ..lng = 0),
      2,
    );
    expect(
      fishingSpotManager.numberOfCatches(FishingSpot()
        ..name = "Spot 1"
        ..id = fishingSpotId3
        ..lat = 0
        ..lng = 0),
      1,
    );
    expect(
      fishingSpotManager.numberOfCatches(FishingSpot()
        ..name = "Spot 1"
        ..id = fishingSpotId4
        ..lat = 0
        ..lng = 0),
      1,
    );
  });

  group("deleteMessage", () {
    testWidgets("Input", (tester) async {
      expect(
        () => fishingSpotManager.deleteMessage(
            null,
            FishingSpot()
              ..id = randomId()
              ..name = "A"),
        throwsAssertionError,
      );

      var context = await buildContext(tester);
      expect(() => fishingSpotManager.deleteMessage(context, null),
          throwsAssertionError);
    });

    testWidgets("Singular", (tester) async {
      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "A";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
      ]);

      var context = await buildContext(tester);
      expect(
        fishingSpotManager.deleteMessage(context, fishingSpot),
        "A is associated with 1 catch; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "A";

      when(catchManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        fishingSpotManager.deleteMessage(context, fishingSpot),
        "A is associated with 0 catches; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });

    testWidgets("Plural none zero", (tester) async {
      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "A";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
        Catch()
          ..id = randomId()
          ..timestamp = Int64(5)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
      ]);

      var context = await buildContext(tester);
      expect(
        fishingSpotManager.deleteMessage(context, fishingSpot),
        "A is associated with 2 catches; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });

    testWidgets("Without a name singular", (tester) async {
      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..lat = 0.000006
        ..lng = 0.000007;

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
      ]);

      var context = await buildContext(tester);
      expect(
        fishingSpotManager.deleteMessage(context, fishingSpot),
        "This fishing spot is associated with 1 catch; are you sure you "
        "want to delete it? This cannot be undone.",
      );
    });

    testWidgets("Without a name plural", (tester) async {
      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..lat = 0.000006
        ..lng = 0.000007;

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
        Catch()
          ..id = randomId()
          ..timestamp = Int64(5)
          ..speciesId = randomId()
          ..fishingSpotId = fishingSpot.id,
      ]);

      var context = await buildContext(tester);
      expect(
        fishingSpotManager.deleteMessage(context, fishingSpot),
        "This fishing spot is associated with 2 catches; are you sure you "
        "want to delete it? This cannot be undone.",
      );
    });
  });
}
