import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

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
    late MockMapController controller;

    setUp(() async {
      managers = await StubbedManagers.create();

      controller = MockMapController();
      when(controller.addSymbols(any)).thenAnswer(
        (invocation) => Future.value(
          (invocation.positionalArguments.first as List<Symbol>)
              .map((e) => e.deepCopy()..id = randomId().uuid)
              .toList(),
        ),
      );
    });

    testWidgets("Draw exits early if there's nothing to draw", (tester) async {
      var context = await buildContext(tester);
      var gpsMapTrail = SymbolTrail(controller);
      gpsMapTrail.draw(context, GpsTrail());
      verifyNever(controller.addSymbols(any));
    });

    testWidgets("Only new points are drawn", (tester) async {
      var context = await buildContext(tester);
      var gpsMapTrail = SymbolTrail(controller);

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
      expect((result.captured.first as List<Symbol>).length, 3);

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
      expect((result.captured.first as List<Symbol>).length, 1);
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
      var gpsMapTrail = SymbolTrail(controller);

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

      var result = verify(controller.addSymbols(captureAny));
      result.called(1);

      final symbols = result.captured.first as List<Symbol>;
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
        late OnSymbolTappedCallback onSymbolTapped;
        when(controller.addOnSymbolTapped(any)).thenAnswer(
          (invocation) => onSymbolTapped = invocation.positionalArguments[0],
        );
        when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
        when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

        var context = await buildContext(tester);
        var gpsMapTrail = SymbolTrail(controller, null);

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
        onSymbolTapped.call(symbol);
        verifyNever(metadata.hasCatchId());
      },
    );

    testWidgets("Tapping non-catch symbol is a no-op", (tester) async {
      late OnSymbolTappedCallback onSymbolTapped;
      when(controller.addOnSymbolTapped(any)).thenAnswer(
        (invocation) => onSymbolTapped = invocation.positionalArguments[0],
      );
      when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester);
      var invoked = false;
      var gpsMapTrail = SymbolTrail(controller, (_) => invoked = true);

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
      onSymbolTapped.call(symbol);

      expect(invoked, isFalse);
      verify(metadata.hasCatchId()).called(1);
      verifyNever(metadata.catchId);
    });

    testWidgets("onCatchSymbolTapped invoked", (tester) async {
      late OnSymbolTappedCallback onSymbolTapped;
      when(controller.addOnSymbolTapped(any)).thenAnswer(
        (invocation) => onSymbolTapped = invocation.positionalArguments[0],
      );
      when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
      when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());

      var context = await buildContext(tester);
      Id? invokedId = null;
      var gpsMapTrail = SymbolTrail(controller, (id) => invokedId = id);

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

      final id = randomId();
      onSymbolTapped.call(Symbol(metadata: SymbolMetadata(catchId: id)));
      expect(invokedId, id);
    });
  });
}
