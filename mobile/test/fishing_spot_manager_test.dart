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

    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

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

  testWidgets("displayName with name", (tester) async {
    expect(
      fishingSpotManager.displayName(
        await buildContext(tester),
        FishingSpot()
          ..id = randomId()
          ..name = "Test Name"
          ..lat = 0.0
          ..lng = 0.0,
      ),
      "Test Name",
    );
  });

  testWidgets("displayName without name", (tester) async {
    expect(
      fishingSpotManager.displayName(
        await buildContext(tester),
        FishingSpot()
          ..id = randomId()
          ..lat = 0.0
          ..lng = 0.0,
      ),
      "Lat: 0.000000, Lng: 0.000000",
    );
  });

  testWidgets("displayName without labels", (tester) async {
    expect(
      fishingSpotManager.displayName(
        await buildContext(tester),
        FishingSpot()
          ..id = randomId()
          ..lat = 0.0
          ..lng = 0.0,
        includeLatLngLabels: false,
      ),
      "0.000000, 0.000000",
    );
  });

  test("Fishing spot within radius", () async {
    // Null cases.
    var fishingSpot = fishingSpotManager.withinRadius(const LatLng(0, 0), 20);
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
    fishingSpot = fishingSpotManager.withinRadius(
        const LatLng(35.955348, -84.240310), 20);
    expect(fishingSpot, isNotNull);
    await fishingSpotManager.delete(newSpot.id);

    // Single fishing spot outside radius.
    newSpot = FishingSpot()
      ..id = fishingSpotId1
      ..lat = 35.953638
      ..lng = -84.241233;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager.withinRadius(
        const LatLng(35.955348, -84.240310), 20);
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

    fishingSpot = fishingSpotManager.withinRadius(
        const LatLng(35.955340, -84.240295), 20);
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

  test("listSortedByName includes names first", () async {
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

    var sortedSpots = fishingSpotManager.listSortedByName();
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

  test("matchesFilter no fishing spot", () {
    expect(fishingSpotManager.matchesFilter(randomId(), null), isFalse);
  });

  test("matchesFilter super returns true", () async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
    ));
    expect(fishingSpotManager.matchesFilter(id, "Test"), isTrue);
  });

  testWidgets("matchesFilter body of water match", (tester) async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
    ));

    var context = await buildContext(tester, appManager: appManager);
    when(appManager.bodyOfWaterManager.matchesFilter(any, any))
        .thenReturn(true);

    expect(
        fishingSpotManager.matchesFilter(id, "Body Of Water", context), isTrue);
  });

  testWidgets("matchesFilter notes match", (tester) async {
    var id = randomId();
    await fishingSpotManager.addOrUpdate(FishingSpot(
      id: id,
      name: "Test",
      notes: "Some notes",
    ));

    var context = await buildContext(tester, appManager: appManager);
    when(appManager.bodyOfWaterManager.matchesFilter(any, any))
        .thenReturn(false);

    expect(fishingSpotManager.matchesFilter(id, "note", context), isTrue);
    expect(fishingSpotManager.matchesFilter(id, "bad", context), isFalse);
  });

  group("deleteMessage", () {
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
