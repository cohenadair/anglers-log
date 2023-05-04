import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
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
      expect(mapIconColor(MapType.light), Colors.black);
    });
  });

  group("GpsMapTrail", () {
    late StubbedAppManager appManager;
    late MockMapboxMapController controller;

    setUp(() {
      appManager = StubbedAppManager();

      controller = MockMapboxMapController();
      when(controller.onSymbolTapped).thenReturn(ArgumentCallbacks<Symbol>());
      when(controller.addSymbols(any, any)).thenAnswer((invocation) =>
          Future.value(
              (invocation.positionalArguments.first as List<SymbolOptions>)
                  .map((e) => Symbol(const Uuid().v4(), e))
                  .toList()));
    });

    testWidgets("Draw exits early if there's nothing to draw", (tester) async {
      var context = await buildContext(tester);
      var gpsMapTrail = GpsMapTrail(controller);
      gpsMapTrail.draw(context, GpsTrail());
      verifyNever(controller.addSymbols(any, any));
    });

    testWidgets("Only new points are drawn", (tester) async {
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

      var result = verify(controller.addSymbols(captureAny, any));
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
      result = verify(controller.addSymbols(captureAny, any));
      result.called(1);
      expect((result.captured.first as List<SymbolOptions>).length, 1);
    });

    testWidgets("Catches are drawn", (tester) async {
      when(appManager.catchManager.catchesForGpsTrail(any)).thenReturn([
        Catch(id: randomId()),
        Catch(id: randomId()),
      ]);
      when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot(
        lat: 1,
        lng: 2,
      ));

      var context = await buildContext(tester, appManager: appManager);
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
        includeCatches: true,
      );

      var result = verify(controller.addSymbols(captureAny, captureAny));
      result.called(1);
      expect((result.captured.first as List<SymbolOptions>).length, 5);

      var data = result.captured.last as List<Map<String, dynamic>>;
      expect(data.length, 5);
      expect(data[0]["catch_id"], isNull);
      expect(data[1]["catch_id"], isNull);
      expect(data[2]["catch_id"], isNull);
      expect(data[3]["catch_id"], isNotEmpty);
      expect(data[4]["catch_id"], isNotEmpty);
    });

    testWidgets(
        "Tapping catch symbol when onCatchSymbolTapped = null is a no-op",
        (tester) async {
      when(appManager.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester, appManager: appManager);
      var gpsMapTrail = GpsMapTrail(controller, null);

      await gpsMapTrail.draw(
        context,
        GpsTrail(
          points: [
            GpsTrailPoint(lat: 37.32475413, lng: -122.02195627),
            GpsTrailPoint(lat: 37.32475794, lng: -122.02207001),
            GpsTrailPoint(lat: 37.32475426, lng: -122.02218992),
          ],
        ),
        includeCatches: true,
      );

      var symbol = MockSymbol();
      when(symbol.data).thenReturn(null);
      controller.onSymbolTapped.call(symbol);
      verifyNever(symbol.data);
    });

    testWidgets("Tapping non-catch symbol is a no-op", (tester) async {
      when(appManager.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester, appManager: appManager);
      var invoked = false;
      var gpsMapTrail = GpsMapTrail(controller, (_) => invoked = true);

      await gpsMapTrail.draw(
        context,
        GpsTrail(
          points: [
            GpsTrailPoint(lat: 37.32475413, lng: -122.02195627),
            GpsTrailPoint(lat: 37.32475794, lng: -122.02207001),
            GpsTrailPoint(lat: 37.32475426, lng: -122.02218992),
          ],
        ),
        includeCatches: true,
      );

      var symbol = MockSymbol();
      when(symbol.data).thenReturn(null);
      controller.onSymbolTapped.call(symbol);

      expect(invoked, isFalse);
      verify(symbol.data).called(1);
    });

    testWidgets("onCatchSymbolTapped invoked", (tester) async {
      when(appManager.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester, appManager: appManager);
      var invoked = false;
      var gpsMapTrail = GpsMapTrail(controller, (_) => invoked = true);

      await gpsMapTrail.draw(
        context,
        GpsTrail(
          points: [
            GpsTrailPoint(lat: 37.32475413, lng: -122.02195627),
            GpsTrailPoint(lat: 37.32475794, lng: -122.02207001),
            GpsTrailPoint(lat: 37.32475426, lng: -122.02218992),
          ],
        ),
        includeCatches: true,
      );

      var symbol = MockSymbol();
      when(symbol.data).thenReturn({"catch_id": "some-id"});
      controller.onSymbolTapped.call(symbol);

      expect(invoked, isTrue);
    });
  });
}
