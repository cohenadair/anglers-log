import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:test/test.dart';

void main() {
  group("distanceBetween", () {
    test("Invalid input", () {
      expect(distanceBetween(const LatLng(-45.0, -75.0), null), 0);
      expect(distanceBetween(null, const LatLng(89, 150)), 0);
    });

    test("Invalid input", () {
      expect(distanceBetween(const LatLng(-45.0, -75.0), const LatLng(89, 150)),
          29105052.801043);
    });
  });

  group("mapBounds", () {
    test("Invalid input", () {
      expect(mapBounds({}), isNull);
    });

    test("Normal case", () {
      var bounds = mapBounds({
        FishingSpot()
          ..lat = 50
          ..lng = 1,
        FishingSpot()
          ..lat = -45
          ..lng = 150,
        FishingSpot()
          ..lat = -10
          ..lng = 35,
        FishingSpot()
          ..lat = 89
          ..lng = -75,
      })!;
      expect(bounds.southwest, const LatLng(-45.0, -75.0));
      expect(bounds.northeast, const LatLng(89, 150));
    });
  });
}
