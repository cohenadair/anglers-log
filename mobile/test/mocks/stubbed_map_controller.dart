import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/mapbox_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import 'mocks.mocks.dart';
import 'stubbed_managers.dart';

class StubbedMapController {
  OnMapScrollListener? onMapMoveCallback;

  late final MapboxMapController value;

  final StubbedManagers _managers;

  final map = MockMapboxMap();
  final pointAnnotationManager = MockPointAnnotationManager();

  StubbedMapController(this._managers, {bool createController = false}) {
    when(
      pointAnnotationManager.setSymbolZOrder(any),
    ).thenAnswer((_) => Future.value());

    final cancelable = MockCancelable();
    when(cancelable.cancel()).thenAnswer((_) {});
    when(
      pointAnnotationManager.tapEvents(onTap: anyNamed("onTap")),
    ).thenReturn(cancelable);
    when(pointAnnotationManager.createMulti(any)).thenAnswer((inv) {
      final options =
          inv.positionalArguments[0] as List<PointAnnotationOptions>;
      final annotations = options.map(
        (o) => PointAnnotation(id: randomId().uuid, geometry: o.geometry),
      );
      return Future.value(annotations.toList());
    });

    final annotations = MockAnnotationManager();
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

    when(map.attribution).thenReturn(attributionSettings);
    when(map.logo).thenReturn(logoSettings);
    when(map.compass).thenReturn(compassSettings);
    when(map.scaleBar).thenReturn(scaleBarSettings);
    when(map.location).thenReturn(locationComponentSettings);
    when(map.annotations).thenReturn(annotations);
    when(map.setOnMapMoveListener(any)).thenAnswer(
      (invocation) => onMapMoveCallback = invocation.positionalArguments[0],
    );
  }

  /// MapboxMap callbacks aren't called in widget tests, so we manually invoke
  /// them when needed.
  Future<void> finishLoading(WidgetTester tester) async {
    value = await MapboxMapController.create(map);
    when(
      _managers.mapControllerFactory.createMapbox(
        any,
        myLocationEnabled: anyNamed("myLocationEnabled"),
      ),
    ).thenAnswer((_) => Future.value(value));

    findFirst<MapWidget>(tester).onMapCreated?.call(map);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  void moveMap({bool isMoving = false}) {
    assert(onMapMoveCallback != null);
    onMapMoveCallback!(
      MapContentGestureContext(
        touchPosition: ScreenCoordinate(x: 0, y: 0),
        point: Point(coordinates: Position(0, 0)),
        gestureState: isMoving ? .started : .ended,
      ),
    );
  }

  void stubCameraPosition(CameraPosition position) {
    when(map.getCameraState()).thenAnswer(
      (_) => Future.value(
        CameraState(
          center: position.latLng.point,
          padding: MbxEdgeInsets(
            left: position.left,
            right: position.right,
            top: position.top,
            bottom: position.bottom,
          ),
          zoom: position.zoom,
          bearing: 0,
          pitch: 0,
        ),
      ),
    );
  }
}
