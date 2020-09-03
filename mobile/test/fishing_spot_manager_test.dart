import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
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
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    fishingSpotManager = FishingSpotManager(appManager);
  });

  test("Fishing spot within radius", () async {
    // Null cases.
    FishingSpot fishingSpot = fishingSpotManager.withinRadius(
      latLng: LatLng(0, 0),
      meters: 20,
    );
    expect(fishingSpot, isNull);

    fishingSpot = fishingSpotManager.withinRadius(
      latLng: null,
    );
    expect(fishingSpot, isNull);

    // Single fishing spot in radius.
    var newSpot = FishingSpot(lat: 35.955348, lng: -84.240310);
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager.withinRadius(
      latLng: LatLng(35.955348, -84.240310),
      meters: 20,
    );
    expect(fishingSpot, isNotNull);
    await fishingSpotManager.delete(newSpot);

    // Single fishing spot outside radius.
    newSpot = FishingSpot(lat: 35.953638, lng: -84.241233);
    await fishingSpotManager.addOrUpdate(newSpot);
    fishingSpot = fishingSpotManager.withinRadius(
      latLng: LatLng(35.955348, -84.240310),
      meters: 20,
    );
    expect(fishingSpot, isNull);
    await fishingSpotManager.delete(newSpot);

    // Multiple fishing spots within radius.
    await fishingSpotManager.addOrUpdate(
        FishingSpot(lat: 35.955296, lng: -84.240337));
    await fishingSpotManager.addOrUpdate(
        FishingSpot(lat: 35.955196, lng: -84.240437));
    await fishingSpotManager.addOrUpdate(
        FishingSpot(lat: 35.955335, lng: -84.240300));
    fishingSpot = fishingSpotManager.withinRadius(
      latLng: LatLng(35.955340, -84.240295),
      meters: 20,
    );
    expect(fishingSpot, isNotNull);
    expect(fishingSpot.lat, 35.955335);
    expect(fishingSpot.lng, -84.240300);
  });

  test("Fishing spot with LatLng", () async {
    await fishingSpotManager.addOrUpdate(
        FishingSpot(lat: 35.955296, lng: -84.240337));
    expect(fishingSpotManager.withLatLng(LatLng(35.955296, -84.240337)),
        isNotNull);
    expect(fishingSpotManager.withLatLng(LatLng(35.955297, -84.240337)),
        isNull);
    expect(fishingSpotManager.withLatLng(null), isNull);
  });

  test("Number of catches", () {
    when(catchManager.entityList()).thenReturn([
      Catch(timestamp: 0, speciesId: "species_1", fishingSpotId: "spot_1"),
      Catch(timestamp: 0, speciesId: "species_1", fishingSpotId: "spot_5"),
      Catch(timestamp: 0, speciesId: "species_1", fishingSpotId: "spot_4"),
      Catch(timestamp: 0, speciesId: "species_1", fishingSpotId: "spot_1"),
      Catch(timestamp: 0, speciesId: "species_1"),
    ]);

    expect(fishingSpotManager.numberOfCatches(null), 0);
    expect(fishingSpotManager.numberOfCatches(
        FishingSpot(name: "Bait 1", id: "spot_1", lat: 0, lng: 0)), 2);
    expect(fishingSpotManager.numberOfCatches(
        FishingSpot(name: "Bait 1", id: "spot_4", lat: 0, lng: 0)), 1);
    expect(fishingSpotManager.numberOfCatches(
        FishingSpot(name: "Bait 1", id: "spot_5", lat: 0, lng: 0)), 1);
  });
}