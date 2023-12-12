import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;
  late MockLocalDatabaseManager dataManager;
  late FishingSpotManager fishingSpotManager;

  setUp(() async {
    appManager = StubbedAppManager();

    catchManager = appManager.catchManager;

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    fishingSpotManager = FishingSpotManager(appManager.app);
  });

  test("Fishing spot within radius", () async {
    when(appManager.userPreferenceManager.fishingSpotDistance).thenReturn(
      MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 20,
        ),
      ),
    );

    // Null cases.
    var fishingSpot =
        fishingSpotManager.withinPreferenceRadius(const LatLng(0, 0));
    expect(fishingSpot, isNull);

    fishingSpot = fishingSpotManager.withinPreferenceRadius(null);
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
    fishingSpot = fishingSpotManager
        .withinPreferenceRadius(const LatLng(35.955348, -84.240310));
    expect(fishingSpot, isNotNull);
    await fishingSpotManager.delete(newSpot.id);

    // Single fishing spot outside radius.
    newSpot = FishingSpot()
      ..id = fishingSpotId1
      ..lat = 35.953638
      ..lng = -84.241233;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager
        .withinPreferenceRadius(const LatLng(35.955348, -84.240310));
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

    fishingSpot = fishingSpotManager
        .withinPreferenceRadius(const LatLng(35.955340, -84.240295));
    expect(fishingSpot, isNotNull);
    expect(fishingSpot!.lat, 35.955335);
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
    expect(fishingSpotManager.numberOfCatches(fishingSpotId0), 2);
    expect(fishingSpotManager.numberOfCatches(fishingSpotId3), 1);
    expect(fishingSpotManager.numberOfCatches(fishingSpotId4), 1);
  });

  testWidgets("listSortedByName includes names first", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);

    await fishingSpotManager.addOrUpdate(
      FishingSpot()
        ..id = randomId()
        ..lat = 36.955296
        ..lng = -85.240337,
    );
    await fishingSpotManager.addOrUpdate(
      FishingSpot()
        ..id = randomId()
        ..name = "Zebra"
        ..lat = 35.955296
        ..lng = -84.240337,
    );
    await fishingSpotManager.addOrUpdate(
      FishingSpot()
        ..id = randomId()
        ..name = "Balloon"
        ..lat = 30.955296
        ..lng = -80.240337,
    );

    var context = await buildContext(tester);
    var sortedSpots = fishingSpotManager.listSortedByDisplayName(context);
    expect(sortedSpots[0].name, "Balloon");
    expect(sortedSpots[1].name, "Zebra");
    expect(sortedSpots[2].hasName(), isFalse);
  });

  test("setImageName", () {
    var id = randomId();
    var fishingSpot = FishingSpot(id: id);
    expect(fishingSpot.id, id);
    expect(fishingSpot.hasImageName(), isFalse);

    fishingSpotManager.setImageName(fishingSpot, "test_name.png");
    expect(fishingSpot.id, id);
    expect(fishingSpot.hasImageName(), isTrue);
  });

  test("clearImageName", () {
    var id = randomId();
    var fishingSpot = FishingSpot(
      id: id,
      imageName: "test_name.png",
    );
    expect(fishingSpot.id, id);
    expect(fishingSpot.hasImageName(), isTrue);

    fishingSpotManager.clearImageName(fishingSpot);
    expect(fishingSpot.id, id);
    expect(fishingSpot.hasImageName(), isFalse);
  });

  testWidgets("matchesFilter no fishing spot", (tester) async {
    expect(
      fishingSpotManager.matchesFilter(
          randomId(), await buildContext(tester), null),
      isFalse,
    );
  });

  testWidgets("matchesFilter super returns true", (tester) async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
    ));
    expect(
      fishingSpotManager.matchesFilter(id, await buildContext(tester), "Test"),
      isTrue,
    );
  });

  testWidgets("matchesFilter body of water match", (tester) async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
    ));

    var context = await buildContext(tester, appManager: appManager);
    when(appManager.bodyOfWaterManager.matchesFilter(any, any, any))
        .thenReturn(true);

    expect(
      fishingSpotManager.matchesFilter(id, context, "Body Of Water"),
      isTrue,
    );
  });

  testWidgets("matchesFilter notes match", (tester) async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
      notes: "Some notes",
    ));

    var context = await buildContext(tester, appManager: appManager);
    when(appManager.bodyOfWaterManager.matchesFilter(any, any, any))
        .thenReturn(false);

    expect(fishingSpotManager.matchesFilter(id, context, "note"), isTrue);
    expect(fishingSpotManager.matchesFilter(id, context, "bad"), isFalse);
  });

  testWidgets("deleteMessage singular", (tester) async {
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

  testWidgets("deleteMessage plural zero", (tester) async {
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

  testWidgets("Delete message plural none zero", (tester) async {
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

  testWidgets("deleteMessage without a name singular", (tester) async {
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

  testWidgets("deleteMessage without a name plural", (tester) async {
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

  testWidgets("displayName with spot, body of water; includeBodyOfWater = true",
      (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    var context = await buildContext(tester, appManager: appManager);
    var displayName = fishingSpotManager.displayName(
      context,
      FishingSpot(
        name: "River Mouth",
        bodyOfWaterId: randomId(),
      ),
      includeBodyOfWater: true,
    );
    expect(displayName, "River Mouth (Lake Huron)");
  });

  testWidgets(
      "displayName with spot, body of water; includeBodyOfWater = false",
      (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    var context = await buildContext(tester, appManager: appManager);
    var displayName = fishingSpotManager.displayName(
      context,
      FishingSpot(
        name: "River Mouth",
        bodyOfWaterId: randomId(),
      ),
      includeBodyOfWater: false,
    );
    expect(displayName, "River Mouth");
  });

  testWidgets(
      "displayName with empty spot, non-empty body of water; includeBodyOfWater = true",
      (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    var context = await buildContext(tester, appManager: appManager);
    var displayName = fishingSpotManager.displayName(
      context,
      FishingSpot(
        bodyOfWaterId: randomId(),
        lat: 1,
        lng: 2,
      ),
      includeBodyOfWater: true,
    );
    expect(displayName, "Lake Huron");
  });

  testWidgets(
      "displayName with empty spot, non-empty body of water; includeBodyOfWater = false",
      (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    var context = await buildContext(tester, appManager: appManager);
    var displayName = fishingSpotManager.displayName(
      context,
      FishingSpot(
        bodyOfWaterId: randomId(),
        lat: 1,
        lng: 2,
      ),
      includeBodyOfWater: false,
      useLatLngFallback: true,
    );
    expect(displayName, "Lat: 1.000000, Lng: 2.000000");
  });

  testWidgets("displayName coordinates only; useLatLngFallback = false",
      (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    var context = await buildContext(tester, appManager: appManager);
    var displayName = fishingSpotManager.displayName(
      context,
      FishingSpot(
        bodyOfWaterId: randomId(),
        lat: 1,
        lng: 2,
      ),
      includeBodyOfWater: false,
      useLatLngFallback: false,
    );
    expect(displayName, isEmpty);
  });

  testWidgets("displayNameFromId returns null", (tester) async {
    expect(
      fishingSpotManager.displayNameFromId(
        await buildContext(tester),
        randomId(),
      ),
      isNull,
    );
  });

  testWidgets("displayNameFromId returns value", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);

    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test Spot",
    ));
    expect(
      fishingSpotManager.displayNameFromId(
        await buildContext(tester, appManager: appManager),
        id,
      ),
      "Test Spot",
    );
  });

  test("namedWithBodyOfWater", () async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      bodyOfWaterId: randomId(),
      name: "Test 1",
    );

    await fishingSpotManager.addOrUpdate(fishingSpot);

    expect(
      fishingSpotManager.namedWithBodyOfWater(
          "Test 1", fishingSpot.bodyOfWaterId),
      isNotNull,
    );
    expect(
      fishingSpotManager.namedWithBodyOfWater("Test 1", randomId()),
      isNull,
    );
    expect(
      fishingSpotManager.namedWithBodyOfWater("Test 1", null),
      isNotNull,
    );
  });
}
