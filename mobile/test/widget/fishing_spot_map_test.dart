import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/our_search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late StubbedMapController mapController;

  setUp(() async {
    managers = await StubbedManagers.create();
    mapController = StubbedMapController(managers);

    when(
      managers.bodyOfWaterManager.listSortedByDisplayName(any),
    ).thenReturn([]);

    when(managers.catchManager.list(any)).thenReturn([]);

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        includeLatLngLabels: anyNamed("includeLatLngLabels"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(0);

    when(
      managers.gpsTrailManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.propertiesManager.mapboxApiKey).thenReturn("");

    when(
      managers.userPreferenceManager.setMapType(any),
    ).thenAnswer((_) => Future.value());
    when(managers.userPreferenceManager.mapType).thenReturn(null);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      mapController.value.cameraPosition(),
    ).thenAnswer((_) => Future.value(CameraPosition(latLng: LatLngs.zero)));
  });

  MapWidget findMap(WidgetTester tester) =>
      tester.widget<MapWidget>(find.byType(MapWidget));

  Future<void> pumpMapWrapper(WidgetTester tester, Widget mapWidget) async {
    await pumpMap(tester, mapController, mapWidget);
  }

  testWidgets("didUpdateWidget updates selected fishing spot", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 3,
      lng: 4,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;

    await pumpMapWrapper(
      tester,
      DidUpdateWidgetTester<InputController<FishingSpot>>(
        controller,
        (context, controller) => SizedBox(
          width: 500,
          height: 500,
          child: FishingSpotMap.selected(controller.value!),
        ),
      ),
    );
    expect(find.text("Spot 1"), findsOneWidget);

    controller.value = fishingSpot2;
    await tapAndSettle(tester, find.text("DID UPDATE WIDGET BUTTON"));

    expect(find.text("Spot 2"), findsOneWidget);
  });

  testWidgets("Controller updated on back navigation", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    var controller = MockInputController<FishingSpot>();
    when(controller.value = any).thenAnswer((_) {});
    when(controller.value).thenReturn(null);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    // Called on map loaded.
    verify(controller.value = any).called(1);
    expect(find.text("New Fishing Spot"), findsNWidgets(2));

    await tapAndSettle(tester, find.byType(BackButton));

    // Called again when map is popped from the navigation stack.
    verify(controller.value = any).called(1);
  });

  testWidgets("Scaffold rendered when widget is a page", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets("Start position is active symbol", (tester) async {
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );

    when(managers.fishingSpotManager.list()).thenReturn([controller.value!]);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    var map = findMap(tester);
    expect(map.cameraOptions!.center!.coordinates.lng, 2);
  });

  testWidgets("Start position is controller value", (tester) async {
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );

    // Note that by not stubbing FishingSpotManager.list() here, like in the
    // previous test, we're ensuring that _activeSymbol cannot be set because
    // the fishing spot doesn't exist in the database.

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    var map = findMap(tester);
    expect(map.cameraOptions!.center!.coordinates.lng, 2);
  });

  testWidgets("Start value is current location", (tester) async {
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 5, lng: 6));

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.cameraOptions!.center!.coordinates.lng, 6);
    expect(map.cameraOptions!.zoom, 13.0);
  });

  testWidgets("Start value is 0, 0", (tester) async {
    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.cameraOptions!.center!.coordinates.lng, 0);
    expect(map.cameraOptions!.zoom, 0);
  });

  testWidgets("Uses default zoom when start is not null", (tester) async {
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 5, lng: 6));

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.cameraOptions!.zoom, 13.0);
  });

  testWidgets("Uses 0 zoom when start value is 0, 0", (tester) async {
    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.cameraOptions!.zoom, 0);
  });

  testWidgets("Search bar is hidden", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showSearchBar: false));
    expect(find.byType(OurSearchBar), findsNothing);
  });

  testWidgets("Dropped pin at default location", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    // Text shows in the search bar and bottom container.
    expect(find.text("New Fishing Spot"), findsNWidgets(2));
  });

  testWidgets("Dropped pin keeps old fishing spot ID", (tester) async {
    VoidCallback? onMapMoveCallback;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      onMapMoveCallback = invocation.positionalArguments[0];
    });

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    var result = verify(mapController.value.addSymbol(captureAny));
    result.called(1);

    // Extract map from symbol data.
    var symbol = result.captured.first as Symbol;
    var originalId = symbol.metadata.fishingSpot.id;
    expect(originalId, isNotNull);

    // Move the camera, causing dropped pin to update.
    when(mapController.value.cameraPosition()).thenAnswer(
      (_) => Future.value(CameraPosition(latLng: LatLng(lat: 1, lng: 1))),
    );
    when(mapController.value.isCameraMoving).thenReturn(false);
    onMapMoveCallback!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify fishing spot ID didn't change.
    result = verify(mapController.value.addSymbol(captureAny));
    result.called(1);

    // Extract map from symbol data.
    symbol = result.captured.first as Symbol;
    var updatedId = symbol.metadata.fishingSpot.id;
    expect(updatedId, isNotNull);
    expect(updatedId, originalId);
  });

  testWidgets("Dropping pickerSettings pin doesn't notify listeners", (
    tester,
  ) async {
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);

    var listenerCalls = 0;
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(id: randomId(), lat: 1, lng: 2);
    controller.addListener(() => listenerCalls++);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    expect(listenerCalls, 0);
  });

  testWidgets("Existing fishing spot is set to controller value", (
    tester,
  ) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot;

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    // Text shows in the search bar and bottom container.
    expect(find.text("Spot 1"), findsNWidgets(2));
  });

  testWidgets("Picking shows back button", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets("Picking with custom onNext widget", (tester) async {
    var invoked = false;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
          onNext: () => invoked = true,
        ),
      ),
    );

    expect(find.text("NEXT"), findsOneWidget);
    expect(invoked, isFalse);

    await tapAndSettle(tester, find.text("NEXT"));
    expect(invoked, isTrue);
  });

  testWidgets("Picking with null custom onNext widget", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
          onNext: null,
        ),
      ),
    );

    expect(find.text("NEXT"), findsNothing);
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets("Pick clear button clears picked spot", (tester) async {
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(id: randomId());

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
          onNext: null,
        ),
      ),
    );
    expect(controller.hasValue, isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.clear));
    expect(controller.hasValue, isFalse);
  });

  testWidgets("Skip picking clears selection", (tester) async {
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(id: randomId());

    var invoked = false;

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
          onNext: () => invoked = true,
        ),
      ),
    );

    expect(find.text("SKIP"), findsOneWidget);
    expect(invoked, isFalse);
    expect(controller.hasValue, isTrue);

    await tapAndSettle(tester, find.text("SKIP"));
    expect(invoked, isTrue);
    expect(controller.hasValue, isFalse);
  });

  testWidgets("Search bar shows clear button when not picking", (tester) async {
    // Setup and existing fishing spot.
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);

    await pumpMapWrapper(tester, FishingSpotMap());

    var result = verify(mapController.value.addOnSymbolTapped(captureAny));
    result.called(1);

    // Manually invoke on tapped callback to select a fishing spot.
    var onSymbolTapped = result.captured.first;
    await onSymbolTapped(
      Symbol(
        id: randomId().uuid,
        options: SymbolOptions(
          latLng: fishingSpot.latLng,
          pin: .active,
          iconSize: 1.5,
        ),
        metadata: SymbolMetadata(fishingSpot: fishingSpot),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(
      tester
          .widget<AnimatedVisibility>(
            find.ancestor(
              of: find.byIcon(Icons.clear),
              matching: find.byType(AnimatedVisibility),
            ),
          )
          .visible,
      isTrue,
    );

    // Tapping the clear button dismisses fishing spot.
    await tapAndSettle(tester, find.byIcon(Icons.clear));
    expect(find.byType(FishingSpotDetails), findsNothing);
    expect(
      tester
          .widget<AnimatedVisibility>(
            find.ancestor(
              of: find.byIcon(Icons.clear),
              matching: find.byType(AnimatedVisibility),
            ),
          )
          .visible,
      isFalse,
    );
  });

  testWidgets("Search bar shows placeholder when not selected", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    expect(find.text("Search fishing spots"), findsOneWidget);
  });

  testWidgets("Picking from FishingSpotListPage", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets("Map style button hidden", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showMapTypeButton: false));
    expect(find.byIcon(Icons.layers), findsNothing);
  });

  testWidgets("Selecting new map style updates state", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot1]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMapTypeButton: true,
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    var normal = "ckt1zqb8d1h1p17pglx4pmz4y";
    var satellite = "ckt1m613b127t17qqf3mmw47h";

    expect(findMap(tester).styleUri.contains(normal), isTrue);
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));

    // Allow map to update.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(findMap(tester).styleUri.contains(satellite), isTrue);
    expect(find.text("Spot 1"), findsNWidgets(2));
    verify(managers.userPreferenceManager.setMapType(any)).called(1);
    verify(mapController.value.setMapType(.satellite)).called(1);
  });

  testWidgets("Selecting same map style does not update state", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showMapTypeButton: true));

    var normal = "ckt1zqb8d1h1p17pglx4pmz4y";

    expect(findMap(tester).styleUri.contains(normal), isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Light"));

    expect(findMap(tester).styleUri.contains(normal), isTrue);
    verifyNever(managers.userPreferenceManager.setMapType(any));
    verifyNever(mapController.value.setMapType(any));
  });

  testWidgets("Current location button hidden", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showMyLocationButton: false));
    expect(find.byIcon(Icons.my_location), findsNothing);
  });

  testWidgets("Current location prompts for permission; declined", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocation(),
    ).thenAnswer((_) => Future.value(false));

    await pumpMapWrapper(tester, FishingSpotMap(showMyLocationButton: true));

    await tapAndSettle(tester, find.byIcon(Icons.my_location));

    verify(managers.lib.permissionHandlerWrapper.requestLocation()).called(1);
    expect(find.text("Location Access"), findsOneWidget);
  });

  testWidgets("Error getting current location", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));
    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap(showMyLocationButton: true));

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets("Picking current location button drops pin", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 1, lng: 2));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMyLocationButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.text("New Fishing Spot"), findsNWidgets(2));
  });

  testWidgets("Current location button clears fishing spot when not picking", (
    tester,
  ) async {
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 1, lng: 2));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.text("Spot 1"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Zoom button hidden", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showZoomExtentsButton: false));
    expect(find.byIcon(Icons.zoom_out_map), findsNothing);
  });

  testWidgets("Zoom button no-op when no fishing spots", (tester) async {
    when(managers.fishingSpotManager.list()).thenReturn([]);

    await pumpMapWrapper(tester, FishingSpotMap(showZoomExtentsButton: true));

    await tapAndSettle(tester, find.byIcon(Icons.zoom_out_map));
    verifyNever(mapController.value.animateCamera(any));
  });

  testWidgets("Zoom button animates camera", (tester) async {
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([FishingSpot(name: "Spot 1", lat: 1, lng: 2)]);

    await pumpMapWrapper(tester, FishingSpotMap(showZoomExtentsButton: true));

    await tapAndSettle(tester, find.byIcon(Icons.zoom_out_map));
    verify(mapController.value.animateToBounds(any)).called(1);
  });

  testWidgets("Mapbox telemetry toggled", (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    await tapAndSettle(tester, find.byType(PaddedCheckbox));
    verify(mapController.value.setTelemetryEnabled(any)).called(1);
  });

  testWidgets("Updating map style re-selects fishing spot", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));

    expect(find.text("Spot 1"), findsNWidgets(2));
  });

  testWidgets("Drop pin at nearby fishing spot", (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.fishingSpotManager.entityExists(fishingSpot.id),
    ).thenReturn(true);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(fishingSpot);

    var controller = InputController<FishingSpot>();
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    // Text shows in the search bar and bottom container.
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(controller.value, fishingSpot);
  });

  testWidgets("Selecting existing spot removes dropped pin", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.fishingSpotManager.entityExists(fishingSpot1.id),
    ).thenReturn(true);
    when(
      managers.fishingSpotManager.entityExists(fishingSpot2.id),
    ).thenReturn(true);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    // Verify pin is dropped.
    expect(find.text("New Fishing Spot"), findsNWidgets(2));
    expect(mapController.symbolCount, 3); // 2 spots, 1 dropped pin

    // Select an existing spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    // Dropped pin was removed.
    expect(mapController.symbolCount, 2);
  });

  testWidgets("Selecting existing spot deactivates active spot", (
    tester,
  ) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.fishingSpotManager.entityExists(fishingSpot1.id),
    ).thenReturn(true);
    when(
      managers.fishingSpotManager.entityExists(fishingSpot2.id),
    ).thenReturn(true);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    // Verify spot is active.
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(mapController.symbolCount, 2); // 2 spots
    verify(mapController.value.updateSymbol(any)).called(2);

    // Select a new spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 2"));
    expect(find.text("Spot 2"), findsNWidgets(2));

    verify(mapController.value.updateSymbol(any)).called(2);
  });

  testWidgets("Selecting spot that does not exist is a no-op", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    var fishingSpot2 = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));

    mapController.clearSymbols();
    await tapAndSettle(tester, find.text("Spot 1"));

    verifyNever(mapController.value.updateSymbol(any));
  });

  testWidgets("Selecting spot activates symbol", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    var result = verify(mapController.value.updateSymbol(captureAny));
    result.called(1);

    var symbolOptions = result.captured.first as Symbol;
    expect(symbolOptions.options.pin, SymbolOptions_PinType.active);
  });

  testWidgets("Editing selected spot updates fishing spot widget", (
    tester,
  ) async {
    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn(null);

    // Use real FishingSpotManager to trigger update callbacks.
    var fishingSpotManager = FishingSpotManager(managers.app);
    when(managers.app.fishingSpotManager).thenReturn(fishingSpotManager);
    fishingSpotManager.addOrUpdate(
      FishingSpot(id: randomId(), name: "Spot 1", lat: 1, lng: 2),
    );

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    // Edit the fishing spot.
    await tapAndSettle(tester, find.text("Edit"));
    await enterTextAndSettle(tester, find.text("Spot 1"), "Spot 2");
    await tapAndSettle(tester, find.text("SAVE"));

    // Confirm edits were made.
    expect(find.text("Spot 2"), findsNWidgets(2));
  });

  testWidgets("Setting up picker is no-op when not picking", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    verifyNever(managers.fishingSpotManager.withinPreferenceRadius(any));
  });

  testWidgets("Setting up picker is no-op spot is already active", (
    tester,
  ) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );
    verifyNever(managers.fishingSpotManager.withinPreferenceRadius(any));
  });

  testWidgets("Setting up picker selects controller value", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot1]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    expect(find.text("Spot 1"), findsNWidgets(2));
  });

  testWidgets("Setting up picker drops pin at selected value", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(id: randomId(), lat: 1, lng: 2);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );

    expect(find.text("New Fishing Spot"), findsNWidgets(2));
  });

  testWidgets("Setting up picker drops pin at current location", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 1, lng: 2));

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    expect(find.text("New Fishing Spot"), findsNWidgets(2));
    expect(find.text("Lat: 1.000000, Lng: 2.000000"), findsOneWidget);
  });

  testWidgets("Setting up picker drops pin at 0, 0", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    expect(find.text("New Fishing Spot"), findsNWidgets(2));
    expect(find.text("Lat: 0.000000, Lng: 0.000000"), findsOneWidget);
  });

  testWidgets("Map movement is animated", (tester) async {
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 1, lng: 2));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    verify(mapController.value.animateCamera(any)).called(1);
  });

  testWidgets("Map movement is not animated", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    verify(mapController.value.moveCamera(any)).called(1);
  });

  testWidgets("No-op when camera moves and no dropped pin", (tester) async {
    VoidCallback? onMapMoveCallback;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      onMapMoveCallback = invocation.positionalArguments[0];
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    onMapMoveCallback!();
    verifyNever(mapController.value.cameraPosition());
  });

  testWidgets("Pin updated on camera idle", (tester) async {
    VoidCallback? onMapMoveCallback;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      onMapMoveCallback = invocation.positionalArguments[0];
    });

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition()).called(2);

    // Ensure position has changed.
    when(mapController.value.cameraPosition()).thenAnswer(
      (_) => Future.value(CameraPosition(latLng: LatLng(lat: 1, lng: 1))),
    );
    when(mapController.value.isCameraMoving).thenReturn(false);
    onMapMoveCallback!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Called once to update the spot, and once to move the map.
    verify(mapController.value.cameraPosition()).called(2);
  });

  testWidgets("Pin not updated on camera idle if position didn't change", (
    tester,
  ) async {
    VoidCallback? onMapMoveCallback;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      onMapMoveCallback = invocation.positionalArguments[0];
    });

    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(mapController.value.cameraPosition()).thenAnswer(
      (_) => Future.value(CameraPosition(latLng: LatLng(lat: 1, lng: 1))),
    );

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition()).called(2);

    // Ensure position hasn't changed.
    when(mapController.value.cameraPosition()).thenAnswer(
      (_) => Future.value(CameraPosition(latLng: LatLng(lat: 1, lng: 1))),
    );
    when(mapController.value.isCameraMoving).thenReturn(false);
    onMapMoveCallback!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Called once to update the spot, and once to move the map.
    verify(mapController.value.cameraPosition()).called(1);
  });

  testWidgets("Target hidden when map is idle", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    expect(
      findFirstWithIcon<AnimatedVisibility>(
        tester,
        CustomIcons.mapTarget,
      ).visible,
      isFalse,
    );
  });

  testWidgets("Target hidden when no active dropped pin", (tester) async {
    VoidCallback? listener;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first;
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();

    verifyNever(mapController.value.isCameraMoving);
    expect(
      findFirstWithIcon<AnimatedVisibility>(
        tester,
        CustomIcons.mapTarget,
      ).visible,
      isFalse,
    );
  });

  testWidgets("Target is shown when map is moving", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(mapController.value.isCameraMoving).thenReturn(true);

    VoidCallback? listener;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first;
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Add a pin.
    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition()).called(2);

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    verify(mapController.value.isCameraMoving).called(1);
    expect(
      findFirstWithIcon<AnimatedVisibility>(
        tester,
        CustomIcons.mapTarget,
      ).visible,
      isTrue,
    );
  });

  testWidgets("Fishing spot is deselected when deleted", (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot]);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Select an existing fishing spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Stub FishingSpotManager so the selected spot no longer exists.
    when(managers.fishingSpotManager.filteredList(any, any)).thenReturn([]);
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    // Force call entity listener builder.
    findFirst<EntityListenerBuilder>(tester).onAnyChange!();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text("Spot 1"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Tapping add button drops a pin", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);
  });

  testWidgets("Move map exits early if already at position", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    when(managers.locationMonitor.currentLatLng).thenReturn(LatLngs.zero);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.my_location), 200);
    verifyNever(mapController.value.animateCamera(captureAny));
  });

  testWidgets("Move map zooms to default", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Default position is 0, 0. Set something else so the map actually moves.
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(LatLng(lat: 1, lng: 1));
    await tapAndSettle(tester, find.byIcon(Icons.my_location), 200);

    var result = verify(mapController.value.animateCamera(captureAny));
    result.called(1);

    var update = result.captured.first as CameraPosition;
    expect(update.zoom, 13.0);
  });

  testWidgets("GPS trail button is hidden", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: false));
    expect(find.byIcon(iconGpsTrail), findsNothing);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showGpsTrailButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );
    expect(find.byIcon(iconGpsTrail), findsNothing);
  });

  testWidgets("GPS trail button starts tracking", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.gpsTrailManager.startTracking(any),
    ).thenAnswer((_) => Future.value());
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verify(managers.gpsTrailManager.startTracking(any)).called(1);
  });

  testWidgets("GPS trail button stops tracking", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verify(managers.gpsTrailManager.stopTracking()).called(1);
  });

  testWidgets("GPS trail tracking ends if not pro", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    expect(find.byType(AnglersLogProPage), findsNothing);
  });

  testWidgets("GPS trail button shows Pro page", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.lib.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value(null));

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verifyNever(managers.gpsTrailManager.startTracking(any));
    expect(find.byType(AnglersLogProPage), findsOneWidget);
  });

  testWidgets("GpsTrailPage shown after tracking ends", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(managers.gpsTrailManager.stream).thenAnswer((_) => controller.stream);
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));

    // Trail is active.
    expect(findFirst<BadgeContainer>(tester).isBadgeVisible, isTrue);

    // Deactivate the trail.
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    controller.add(
      EntityEvent<GpsTrail>(GpsTrailEventType.endTracking, GpsTrail()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GpsTrailPage), findsOneWidget);

    // Ensure active trail badge is no longer showing.
    await tapAndSettle(tester, find.byIcon(Icons.close));
    expect(findFirst<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });

  testWidgets("GPS trail is setup correctly", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(managers.gpsTrailManager.stream).thenAnswer((_) => controller.stream);

    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(managers.gpsTrailManager.activeTrial).thenReturn(
      GpsTrail(
        points: [
          GpsTrailPoint(lat: 5.0, lng: 6.0),
          GpsTrailPoint(lat: 7.0, lng: 8.0),
        ],
      ),
    );
    when(
      mapController.value.addSymbols(any),
    ).thenAnswer((_) => Future.value([]));

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));

    verify(
      mapController.value.animateCamera(any, easeIn: anyNamed("easeIn")),
    ).called(1);
  });

  testWidgets("GPS trail update exits early if picking", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(managers.gpsTrailManager.stream).thenAnswer((_) => controller.stream);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showGpsTrailButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    controller.add(
      EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, GpsTrail()),
    );
    verifyNever(managers.gpsTrailManager.activeTrial);
  });

  testWidgets("GPS trail setup exits early if picking", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showGpsTrailButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );
    verifyNever(managers.gpsTrailManager.activeTrial);
  });

  testWidgets("Map type updates when theme mode changes", (tester) async {
    var controller = StreamController<String>.broadcast();
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => controller.stream);
    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.light);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );
    expect(findFirst<DefaultMapboxMap>(tester).style, MapType.light.url);

    // Trigger update, but not a theme change.
    controller.add("not a theme mode change event");
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findFirst<DefaultMapboxMap>(tester).style, MapType.light.url);

    // Trigger a theme change.
    when(managers.lib.appConfig.themeMode).thenReturn(() => ThemeMode.dark);
    controller.add(UserPreferenceManager.keyMapType);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findFirst<DefaultMapboxMap>(tester).style, MapType.dark.url);
  });

  testWidgets("Dropping pin while spot is selected creates new spot", (
    tester,
  ) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot]);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    when(mapController.value.isCameraMoving).thenReturn(false);

    VoidCallback? onMapMoveCallback;
    when(mapController.value.onMapMoveCallback = any).thenAnswer((invocation) {
      onMapMoveCallback = invocation.positionalArguments[0];
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Select an existing fishing spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);
    expect(find.text("Spot 1"), findsNWidgets(2));

    // Move the camera and add a new spot, causing dropped pin to update.
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(mapController.value.cameraPosition()).thenAnswer(
      (_) => Future.value(CameraPosition(latLng: LatLng(lat: 1, lng: 1))),
    );
    onMapMoveCallback!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byType(FloatingButton),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify new spot is selected.
    expect(find.text("Spot 1"), findsNothing);
    expect(find.text("New Fishing Spot"), findsNWidgets(2));
  });

  testWidgets("FishingSpotMap.selected hides add button", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap.selected(
        FishingSpot(id: randomId(), name: "Spot 1", lat: 1, lng: 2),
      ),
    );
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Directions button is shown if widget is static", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap.selected(
        FishingSpot(id: randomId(), name: "Spot 1", lat: 1, lng: 2),
      ),
    );
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets("Directions button is hidden while picking", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    expect(find.text("Directions"), findsNothing);
  });
}
