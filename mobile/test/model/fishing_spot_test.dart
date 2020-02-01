import 'package:mobile/model/fishing_spot.dart';
import 'package:test/test.dart';

void main() {
  test("Mapping", () {
    FishingSpot fishingSpot = FishingSpot(
      lat: 0.1,
      lng: 0.3,
      name: "Test name",
    );

    var map = fishingSpot.toMap();
    expect(map["lat"], 0.1);
    expect(map["lng"], 0.3);
    expect(map["name"], "Test name");
    expect(map["id"], isNotNull);

    map = {
      "id" : "testId",
      "lat" : 0.5,
      "lng" : 0.6,
      "name" : "A NAME",
    };
    var fishingSpot2 = FishingSpot.fromMap(map);
    expect(fishingSpot2.id, "testId");
    expect(fishingSpot2.lat, 0.5);
    expect(fishingSpot2.lng, 0.6);
    expect(fishingSpot2.name, "A NAME");
  });
}