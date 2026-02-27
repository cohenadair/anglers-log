import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/map/mapbox_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';

void main() {
  group("distanceBetween", () {
    test("Invalid input", () {
      expect(distanceBetween(LatLng(lat: -45.0, lng: -75.0), null), 0);
      expect(distanceBetween(null, LatLng(lat: 89, lng: 150)), 0);
    });

    test("Invalid input", () {
      expect(
        distanceBetween(
          LatLng(lat: -45.0, lng: -75.0),
          LatLng(lat: 89, lng: 150),
        ),
        29105052.801043,
      );
    });
  });

  group("mapBounds", () {
    test("Invalid input", () {
      expect(latLngsToBounds({}), isNull);
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
      expect(bounds.southwest, LatLng(lat: -45.0, lng: -75.0));
      expect(bounds.northeast, LatLng(lat: 89, lng: 150));
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
    late StubbedManagers managers;
    late StubbedMapController controller;

    setUp(() async {
      managers = await StubbedManagers.create();
      controller = StubbedMapController(managers);
      controller.value = await MapboxMapController.create(controller.map);
    });

    testWidgets("Draw exits early if there's nothing to draw", (tester) async {
      var context = await buildContext(tester);
      var gpsMapTrail = SymbolTrail(controller.value);
      gpsMapTrail.draw(context, GpsTrail());
      expect(controller.value.symbols.isEmpty, isTrue);
    });

    testWidgets("Only new points are drawn", (tester) async {
      var context = await buildContext(tester);
      var gpsMapTrail = SymbolTrail(controller.value);

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

      expect(controller.value.symbols.length, 3);

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
      expect(controller.value.symbols.length, 4);
    });

    testWidgets("Catches are drawn", (tester) async {
      final id0 = randomId();
      final id1 = randomId();
      when(
        managers.catchManager.catchesForGpsTrail(any),
      ).thenReturn([Catch(id: id0), Catch(id: id1)]);
      when(
        managers.fishingSpotManager.entity(any),
      ).thenReturn(FishingSpot(lat: 1, lng: 2));

      var context = await buildContext(tester);
      var gpsMapTrail = SymbolTrail(controller.value);

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

      final symbols = controller.value.symbols;
      expect(symbols.length, 5);
      expect(symbols[0].metadata.hasCatchId(), false);
      expect(symbols[1].metadata.hasCatchId(), false);
      expect(symbols[2].metadata.hasCatchId(), false);
      expect(symbols[3].metadata.catchId, id0);
      expect(symbols[4].metadata.catchId, id1);
    });

    testWidgets(
      "Tapping catch symbol when onCatchSymbolTapped = null is a no-op",
      (tester) async {
        when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
        when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

        var context = await buildContext(tester);
        var gpsMapTrail = SymbolTrail(controller.value, null);

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

        final metadata = MockSymbolMetadata();
        when(metadata.hasCatchId()).thenReturn(false);
        final symbol = MockSymbol();
        when(symbol.metadata).thenReturn(metadata);
        controller.value.tapEvents.first.call(symbol);
        verifyNever(metadata.hasCatchId());
      },
    );

    testWidgets("Tapping non-catch symbol is a no-op", (tester) async {
      when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester);
      var invoked = false;
      var gpsMapTrail = SymbolTrail(controller.value, (_) => invoked = true);

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

      final metadata = MockSymbolMetadata();
      when(metadata.hasCatchId()).thenReturn(false);
      final symbol = MockSymbol();
      when(symbol.metadata).thenReturn(metadata);
      controller.value.tapEvents.first.call(symbol);

      expect(invoked, isFalse);
      verify(metadata.hasCatchId()).called(1);
      verifyNever(metadata.catchId);
    });

    testWidgets("onCatchSymbolTapped invoked", (tester) async {
      when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester);
      Id? invokedId;
      var gpsMapTrail = SymbolTrail(controller.value, (id) => invokedId = id);

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

      // Exits early if symbol doesn't have a fishing spot.
      controller.value.tapEvents.first.call(Symbol(metadata: SymbolMetadata()));
      expect(invokedId, isNull);

      final id = randomId();
      controller.value.tapEvents.first.call(
        Symbol(metadata: SymbolMetadata(catchId: id)),
      );
      expect(invokedId, id);
    });
  });
}
