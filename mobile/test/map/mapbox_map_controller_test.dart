import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/mapbox_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/async.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockPointAnnotationManager pointAnnotationManager;
  late MockAnnotationManager annotations;
  late MockMapboxMap mapboxMap;
  late MapboxMapController mapController;

  setUp(() async {
    pointAnnotationManager = MockPointAnnotationManager();
    when(
      pointAnnotationManager.setSymbolZOrder(any),
    ).thenAnswer((_) => Future.value());

    annotations = MockAnnotationManager();
    when(
      annotations.createPointAnnotationManager(),
    ).thenAnswer((_) => Future.value(pointAnnotationManager));

    final attributionSettings = MockAttributionSettingsInterface();
    when(
      attributionSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    final logoSettings = MockLogoSettingsInterface();
    when(logoSettings.updateSettings(any)).thenAnswer((_) => Future.value());

    final compassSettings = MockCompassSettingsInterface();
    when(compassSettings.updateSettings(any)).thenAnswer((_) => Future.value());

    final scaleBarSettings = MockScaleBarSettingsInterface();
    when(
      scaleBarSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    final locationComponentSettings = MockLocationSettings();
    when(
      locationComponentSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    mapboxMap = MockMapboxMap();
    when(mapboxMap.attribution).thenReturn(attributionSettings);
    when(mapboxMap.logo).thenReturn(logoSettings);
    when(mapboxMap.compass).thenReturn(compassSettings);
    when(mapboxMap.scaleBar).thenReturn(scaleBarSettings);
    when(mapboxMap.location).thenReturn(locationComponentSettings);
    when(mapboxMap.annotations).thenReturn(annotations);
    when(mapboxMap.setOnMapMoveListener(any)).thenAnswer((_) => () {});

    mapController = await MapboxMapController.create(mapboxMap);
  });

  test("Symbol tapped callback management", () async {
    final cancelable = MockCancelable();
    when(
      pointAnnotationManager.tapEvents(onTap: anyNamed("onTap")),
    ).thenReturn(cancelable);

    void onSymbolTapped(_) {}
    mapController.addOnSymbolTapped(onSymbolTapped);
    verify(
      pointAnnotationManager.tapEvents(onTap: anyNamed("onTap")),
    ).called(1);

    mapController.removeOnSymbolTapped(onSymbolTapped);
    verify(cancelable.cancel()).called(1);

    final logs = await capturePrintStatements(() async {
      mapController.removeOnSymbolTapped((_) {});
    });
    expect(logs.length, 1);
    expect(
      logs.first.contains(
        "Calling removeOnSymbolTapped for a callback that doesn't exist",
      ),
      isTrue,
    );
  });

  test("Single symbol management", () async {
    const lat = 5.0;
    const lng = 2.0;

    final symbol = Symbol(
      options: SymbolOptions(
        latLng: LatLng(lat: lat, lng: lng),
      ),
    );

    // Stub annotation result from Mapbox.
    final annotation = PointAnnotation(
      id: randomId().uuid,
      geometry: Point(coordinates: Position(lng, lat)),
      customData: symbol.mapboxCustomData,
    );
    final annotations = [annotation];
    when(
      pointAnnotationManager.createMulti(any),
    ).thenAnswer((_) => Future.value(annotations));
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value(annotations));

    // Add a single symbol.
    await mapController.addSymbol(symbol);
    expect(mapController.symbols.length, 1);

    // Verify the added symbol is equal to the map controller's symbol, but not
    // an identical instance. The symbol is converted to Mapbox format and back.
    expect(identical(mapController.symbols.first, symbol), isFalse);
    expect(mapController.symbols.first.id, annotation.id);
    expect(mapController.symbols.first.latLng.lat, lat);
    expect(mapController.symbols.first.latLng.lng, lng);

    // Remove the symbol.
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value([]));
    await mapController.removeSymbol(symbol);
    expect(mapController.symbols.isEmpty, isTrue);
  });

  test("Multi symbol management", () async {
    const lat1 = 5.0;
    const lng1 = 2.0;
    const lat2 = 10.0;
    const lng2 = 8.0;

    final symbol1 = Symbol(
      options: SymbolOptions(
        latLng: LatLng(lat: lat1, lng: lng1),
      ),
    );
    final symbol2 = Symbol(
      options: SymbolOptions(
        latLng: LatLng(lat: lat2, lng: lng2),
      ),
    );

    // Stub annotation result from Mapbox.
    final annotation1 = PointAnnotation(
      id: randomId().uuid,
      geometry: Point(coordinates: Position(lng1, lat1)),
      customData: symbol1.mapboxCustomData,
    );
    final annotation2 = PointAnnotation(
      id: randomId().uuid,
      geometry: Point(coordinates: Position(lng2, lat2)),
      customData: symbol2.mapboxCustomData,
    );
    final annotations = [annotation1, annotation2];
    when(
      pointAnnotationManager.createMulti(any),
    ).thenAnswer((_) => Future.value(annotations));
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value(annotations));

    // Add a single symbol.
    await mapController.addSymbols([symbol1, symbol2]);
    expect(mapController.symbols.length, 2);

    // Verify the added symbol is equal to the map controller's symbol, but not
    // an identical instance. The symbol is converted to Mapbox format and back.
    expect(identical(mapController.symbols.first, symbol1), isFalse);
    expect(mapController.symbols.first.id, annotation1.id);
    expect(mapController.symbols.first.latLng.lat, lat1);
    expect(mapController.symbols.first.latLng.lng, lng1);
    expect(identical(mapController.symbols.last, symbol2), isFalse);
    expect(mapController.symbols.last.id, annotation2.id);
    expect(mapController.symbols.last.latLng.lat, lat2);
    expect(mapController.symbols.last.latLng.lng, lng2);

    // Remove the symbol.
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value([]));
    await mapController.removeSymbols([symbol1, symbol2]);
    expect(mapController.symbols.isEmpty, isTrue);
  });

  test("clearSymbols clears all symbols", () async {
    const lat = 5.0;
    const lng = 2.0;

    final symbol = Symbol(
      options: SymbolOptions(
        latLng: LatLng(lat: lat, lng: lng),
      ),
    );

    // Stub annotation result from Mapbox.
    final annotation = PointAnnotation(
      id: randomId().uuid,
      geometry: Point(coordinates: Position(lng, lat)),
      customData: symbol.mapboxCustomData,
    );
    final annotations = [annotation];
    when(
      pointAnnotationManager.createMulti(any),
    ).thenAnswer((_) => Future.value(annotations));
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value(annotations));

    // Add a single symbol.
    await mapController.addSymbol(symbol);
    expect(mapController.symbols.length, 1);

    // Clear symbols.
    when(
      pointAnnotationManager.getAnnotations(),
    ).thenAnswer((_) => Future.value([]));
    when(pointAnnotationManager.deleteAll()).thenAnswer((_) => Future.value());
    await mapController.clearSymbols();
    expect(mapController.symbols.isEmpty, isTrue);
  });

  test("animateCamera easeIn is true", () async {
    await mapController.animateCamera(CameraPosition(), easeIn: true);
    verify(mapboxMap.easeTo(any, any)).called(1);
    verifyNever(mapboxMap.flyTo(any, any));
  });

  test("animateCamera easeIn is false", () async {
    await mapController.animateCamera(CameraPosition(), easeIn: false);
    verifyNever(mapboxMap.easeTo(any, any));
    verify(mapboxMap.flyTo(any, any)).called(1);
  });

  test("animateToBounds exits early for null bounds", () async {
    await mapController.animateToBounds(null);
    verifyNever(
      mapboxMap.cameraForCoordinateBounds(any, any, any, any, any, any),
    );
  });

  test("animateBounds invokes with correct fields", () async {
    when(
      mapboxMap.cameraForCoordinateBounds(any, any, any, any, any, any),
    ).thenAnswer((_) => Future.value(CameraOptions()));

    await mapController.animateToBounds(
      LatLngBounds(
        southwest: LatLng(lat: 1.0, lng: 2.0),
        northeast: LatLng(lat: 3.0, lng: 4.0),
      ),
    );
    final result = verify(
      mapboxMap.cameraForCoordinateBounds(
        captureAny,
        captureAny,
        any,
        any,
        any,
        any,
      ),
    );
    result.called(1);

    final bounds = result.captured.first as CoordinateBounds;
    expect(bounds.southwest, Point(coordinates: Position(2.0, 1.0)));
    expect(bounds.northeast, Point(coordinates: Position(4.0, 3.0)));

    final insets = result.captured.last as MbxEdgeInsets;
    expect(insets.top, paddingXL);
    expect(insets.left, paddingXL);
    expect(insets.bottom, paddingXL);
    expect(insets.right, paddingXL);

    verify(mapboxMap.flyTo(any, any)).called(1);
  });

  test("Map movement updates isCameraMoving", () async {
    var callCount = 0;
    mapController.onMapMoveCallback = () => callCount++;

    final result = verify(mapboxMap.setOnMapMoveListener(captureAny));
    result.called(1);

    final onMapMove = result.captured.first as OnMapScrollListener;

    // Start.
    onMapMove.call(
      MapContentGestureContext(
        gestureState: .started,
        touchPosition: ScreenCoordinate(x: 0, y: 0),
        point: Point(coordinates: Position(0, 0)),
      ),
    );
    expect(mapController.isCameraMoving, isTrue);
    expect(callCount, 1);

    // End.
    onMapMove.call(
      MapContentGestureContext(
        gestureState: .ended,
        touchPosition: ScreenCoordinate(x: 0, y: 0),
        point: Point(coordinates: Position(0, 0)),
      ),
    );
    expect(mapController.isCameraMoving, isFalse);
    expect(callCount, 2);
  });

  test("Symbol.iconImage returns active pin", () async {
    expect(
      Symbol(
        options: SymbolOptions(pin: SymbolOptions_PinType.active),
      ).iconImage,
      "active-pin",
    );
  });

  test("Symbol.iconImage returns direction arrow", () async {
    expect(
      Symbol(
        options: SymbolOptions(pin: SymbolOptions_PinType.direction_arrow),
      ).iconImage,
      "direction-arrow",
    );
  });

  test("Symbol.iconImage returns inactive pin", () async {
    expect(
      Symbol(
        options: SymbolOptions(pin: SymbolOptions_PinType.inactive),
      ).iconImage,
      "inactive-pin",
    );
  });
}
