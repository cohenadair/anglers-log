import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:test/test.dart';

void main() {
  test("Name is set properly", () {
    var fishingSpot = FishingSpot(latLng: LatLng(0, 0), name: "Narrow Bend");
    expect(fishingSpot.name, "Narrow Bend");
  });
}