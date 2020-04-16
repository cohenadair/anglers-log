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
    fishingSpotManager = FishingSpotManager.get(appManager);

    when(appManager.dataManager).thenReturn(dataManager);
  });

  test("Fishing spot within radius", () async {
    List<FishingSpot> fishingSpots = [];
    when(dataManager.fetchAllNamedEntities(any)).thenAnswer((_) => Future.value(
      fishingSpots.map((f) => f.toMap()).toList()
    ));

    // Null case.
    FishingSpot fishingSpot = await fishingSpotManager.withinRadius(
      latLng: LatLng(0, 0),
      meters: 20,
    );
    expect(fishingSpot, isNull);

    // Single fishing spot in radius.
    fishingSpots = [FishingSpot(lat: 35.955348, lng: -84.240310)];
    fishingSpot = await fishingSpotManager.withinRadius(
      latLng: LatLng(35.955348, -84.240310),
      meters: 20,
    );
    expect(fishingSpot, isNotNull);

    // Single fishing spot outside radius.
    fishingSpots = [FishingSpot(lat: 35.953638, lng: -84.241233)];
    fishingSpot = await fishingSpotManager.withinRadius(
      latLng: LatLng(35.955348, -84.240310),
      meters: 20,
    );
    expect(fishingSpot, isNull);

    // Multiple fishing spots within radius.
    fishingSpots = [
      FishingSpot(lat: 35.955296, lng: -84.240337),
      FishingSpot(lat: 35.955196, lng: -84.240437),
      FishingSpot(lat: 35.955335, lng: -84.240300),
    ];
    fishingSpot = await fishingSpotManager.withinRadius(
      latLng: LatLng(35.955340, -84.240295),
      meters: 20,
    );
    expect(fishingSpot, isNotNull);
    expect(fishingSpot.lat, 35.955335);
    expect(fishingSpot.lng, -84.240300);
  });
}