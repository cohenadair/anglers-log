import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../mocks/mocks.mocks.dart';
import '../test_utils.dart';

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
      var bounds = fishingSpotMapBounds({
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

  group("mapIconColor", () {
    test("White icon", () {
      expect(mapIconColor(MapType.satellite), Colors.white);
    });

    test("Black icon", () {
      expect(mapIconColor(MapType.normal), Colors.black);
    });
  });

  group("GpsMapTrail", () {
    testWidgets("Draw exits early if there's nothing to draw", (tester) async {
      var controller = MockMapboxMapController();
      when(controller.addSymbols(any)).thenAnswer(
          (invocation) => Future.value(invocation.positionalArguments.first));

      var context = await buildContext(tester);
      var gpsMapTrail = GpsMapTrail(controller);
      gpsMapTrail.draw(context, GpsTrail());
      verifyNever(controller.addSymbols(any));
    });

    testWidgets("Only new points are drawn", (tester) async {
      var controller = MockMapboxMapController();
      when(controller.addSymbols(any)).thenAnswer((invocation) => Future.value(
          (invocation.positionalArguments.first as List<SymbolOptions>)
              .map((e) => Symbol(const Uuid().v4(), e))
              .toList()));

      var context = await buildContext(tester);
      var gpsMapTrail = GpsMapTrail(controller);

      await gpsMapTrail.draw(
        context,
        GpsTrail(
          points: [
            GpsTrailPoint(lat: 37.32475413, lng: -122.02195627),
            GpsTrailPoint(lat: 37.32475794, lng: -122.02207001),
            GpsTrailPoint(lat: 37.32475426, lng: -122.02218992),
          ],
        ),
      );

      var result = verify(controller.addSymbols(captureAny));
      result.called(1);
      expect((result.captured.first as List<SymbolOptions>).length, 3);

      await gpsMapTrail.draw(
        context,
        GpsTrail(
          points: [
            GpsTrailPoint(lat: 37.32475413, lng: -122.02195627),
            GpsTrailPoint(lat: 37.32475794, lng: -122.02207001),
            GpsTrailPoint(lat: 37.32475426, lng: -122.02218992),
            GpsTrailPoint(lat: 37.32475499, lng: -122.02230437),
          ],
        ),
      );

      // Only one more point is drawn.
      result = verify(controller.addSymbols(captureAny));
      result.called(1);
      expect((result.captured.first as List<SymbolOptions>).length, 1);
    });
  });
}
