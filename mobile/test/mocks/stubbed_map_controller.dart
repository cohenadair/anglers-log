import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/map/mapbox_map_controller.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import 'stubbed_managers.dart';
import 'stubbed_mapbox_map.dart';

class StubbedMapController {
  late final MapboxMapController value;

  final StubbedManagers _managers;
  final map = StubbedMapboxMap();

  StubbedMapController(this._managers);

  /// MapboxMap callbacks aren't called in widget tests, so we manually invoke
  /// them when needed.
  Future<void> finishLoading(WidgetTester tester) async {
    value = await MapboxMapController.create(map.value);
    when(
      _managers.mapControllerFactory.createMapbox(
        any,
        myLocationEnabled: anyNamed("myLocationEnabled"),
      ),
    ).thenAnswer((_) => Future.value(value));

    findFirst<MapWidget>(tester).onMapCreated?.call(map.value);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  void moveMap({bool isMoving = false}) {
    assert(map.onMapMoveCallback != null);
    map.onMapMoveCallback!(
      MapContentGestureContext(
        touchPosition: ScreenCoordinate(x: 0, y: 0),
        point: Point(coordinates: Position(0, 0)),
        gestureState: isMoving ? .started : .ended,
      ),
    );
  }

  void stubCameraPosition(CameraPosition position) {
    when(map.value.getCameraState()).thenAnswer(
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
