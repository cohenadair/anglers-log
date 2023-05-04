import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/edit_coordinates_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late StubbedMapController mapController;

  setUp(() {
    appManager = StubbedAppManager();
    mapController = StubbedMapController();

    when(appManager.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(appManager.propertiesManager.mapboxApiKey).thenReturn("KEY");
  });

  testWidgets("Controller defaults to 0, 0", (tester) async {
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    var spotController = InputController<FishingSpot>();
    await pumpMap(
        tester, appManager, mapController, EditCoordinatesPage(spotController));

    expect(spotController.value!.lat.toStringAsFixed(4), "0.0000");
    expect(spotController.value!.lng.toStringAsFixed(4), "0.0000");
    expect(find.text("Lat: 0.000000, Lng: 0.000000"), findsOneWidget);
  });

  testWidgets("Controller has value", (tester) async {
    var spotController = InputController<FishingSpot>();
    spotController.value = FishingSpot(
      lat: 1.234567,
      lng: 7.654321,
    );
    await pumpMap(
        tester, appManager, mapController, EditCoordinatesPage(spotController));

    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
  });

  testWidgets("Symbol is created on startup", (tester) async {
    var spotController = InputController<FishingSpot>();
    spotController.value = FishingSpot(
      lat: 1.234567,
      lng: 7.654321,
    );
    await pumpMap(
        tester, appManager, mapController, EditCoordinatesPage(spotController));

    verify(mapController.value.addSymbol(any)).called(1);
  });

  testWidgets("Target shows while map is moving", (tester) async {
    when(mapController.value.isCameraMoving).thenReturn(true);

    VoidCallback? listener;
    when(mapController.value.addListener(any)).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first;
    });

    var spotController = InputController<FishingSpot>();
    spotController.value = FishingSpot(
      lat: 1.234567,
      lng: 7.654321,
    );
    await pumpMap(
        tester, appManager, mapController, EditCoordinatesPage(spotController));

    // Verify target isn't showing.
    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
      isFalse,
    );

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify target is showing.
    verify(mapController.value.isCameraMoving).called(1);
    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
      isTrue,
    );

    when(mapController.value.isCameraMoving).thenReturn(false);

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify target isn't showing.
    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
      isFalse,
    );
  });

  testWidgets("Controller is updated when map becomes idle", (tester) async {
    var spotController = InputController<FishingSpot>();
    spotController.value = FishingSpot(
      lat: 1.234567,
      lng: 7.654321,
    );
    await pumpMap(
        tester, appManager, mapController, EditCoordinatesPage(spotController));

    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(2.3456, 6.5432)));

    // Manually invoke onCameraIdle.
    findFirst<DefaultMapboxMap>(tester).onCameraIdle?.call();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(spotController.value!.lat.toStringAsFixed(4), "2.3456");
    expect(spotController.value!.lng.toStringAsFixed(4), "6.5432");
    expect(find.text("Lat: 2.345600, Lng: 6.543200"), findsOneWidget);
  });
}
