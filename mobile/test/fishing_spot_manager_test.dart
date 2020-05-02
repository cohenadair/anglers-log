import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockDataManager dataManager;
  FishingSpotManager fishingSpotManager;

  setUp(() async {
    appManager = MockAppManager();
    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    fishingSpotManager = FishingSpotManager(appManager);
  });

  test("Fishing spot within radius", () async {
    // Null case.
    FishingSpot fishingSpot = fishingSpotManager.withinRadius(
      latLng: LatLng(0, 0),
      meters: 20,
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
  });
}