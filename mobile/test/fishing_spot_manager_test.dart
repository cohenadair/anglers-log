import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockDataManager dataManager;
  FishingSpotManager fishingSpotManager;

  setUp(() async {
    appManager = MockAppManager();

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    fishingSpotManager = FishingSpotManager(appManager);
  });

  test("Fishing spot within radius", () async {
    // Null cases.
    FishingSpot fishingSpot = fishingSpotManager.withinRadius(LatLng(0, 0), 20);
    expect(fishingSpot, isNull);

    fishingSpot = fishingSpotManager.withinRadius(null);
    expect(fishingSpot, isNull);

    Id fishingSpotId0 = Id.random();
    Id fishingSpotId1 = Id.random();
    Id fishingSpotId2 = Id.random();
    Id fishingSpotId3 = Id.random();
    Id fishingSpotId4 = Id.random();

    // Single fishing spot in radius.
    var newSpot = FishingSpot()
      ..id = fishingSpotId0.bytes
      ..lat = 35.955348
      ..lng = -84.240310;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager.withinRadius(LatLng(35.955348, -84.240310),
        20);
    expect(fishingSpot, isNotNull);
    await fishingSpotManager.delete(Id(newSpot.id));

    // Single fishing spot outside radius.
    newSpot = FishingSpot()
      ..id = fishingSpotId1.bytes
      ..lat = 35.953638
      ..lng = -84.241233;
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager.withinRadius(LatLng(35.955348, -84.240310),
        20);
    expect(fishingSpot, isNull);
    await fishingSpotManager.delete(Id(newSpot.id));

    // Multiple fishing spots within radius.
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId2.bytes
      ..lat = 35.955296
      ..lng = -84.240337);
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId3.bytes
      ..lat = 35.955196
      ..lng = -84.240437);
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = fishingSpotId4.bytes
      ..lat = 35.955335
      ..lng = -84.240300);

    fishingSpot = fishingSpotManager.withinRadius(LatLng(35.955340, -84.240295),
        20);
    expect(fishingSpot, isNotNull);
    expect(fishingSpot.lat, 35.955335);
    expect(fishingSpot.lng, -84.240300);
  });

  test("Fishing spot with LatLng", () async {
    await fishingSpotManager.addOrUpdate(FishingSpot()
      ..id = Id.random().bytes
      ..lat = 35.955296
      ..lng = -84.240337);
    expect(fishingSpotManager.withLatLng(FishingSpot()
      ..id = Id.random().bytes
      ..lat = 35.955296
      ..lng = -84.240337), isNotNull);
    expect(fishingSpotManager.withLatLng(FishingSpot()
      ..id = Id.random().bytes
      ..lat = 35.955297
      ..lng = -84.240337), isNull);
    expect(fishingSpotManager.withLatLng(null), isNull);
  });

  test("Number of catches", () {
    Id speciesId0 = Id.random();

    Id fishingSpotId0 = Id.random();
    Id fishingSpotId4 = Id.random();
    Id fishingSpotId3 = Id.random();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes
        ..fishingSpotId = fishingSpotId0.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes
        ..fishingSpotId = fishingSpotId4.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes
        ..fishingSpotId = fishingSpotId3.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes
        ..fishingSpotId = fishingSpotId0.bytes,
      Catch()
        ..id = Id.random().bytes
        ..timestamp = Timestamps.fromMillis(0)
        ..speciesId = speciesId0.bytes,
    ]);

    expect(fishingSpotManager.numberOfCatches(null), 0);
    expect(fishingSpotManager.numberOfCatches(FishingSpot()
      ..name = "Spot 1"
      ..id = fishingSpotId0.bytes
      ..lat = 0
      ..lng = 0), 2);
    expect(fishingSpotManager.numberOfCatches(FishingSpot()
      ..name = "Spot 1"
      ..id = fishingSpotId3.bytes
      ..lat = 0
      ..lng = 0), 1);
    expect(fishingSpotManager.numberOfCatches(FishingSpot()
      ..name = "Spot 1"
      ..id = fishingSpotId4.bytes
      ..lat = 0
      ..lng = 0), 1);
  });
}