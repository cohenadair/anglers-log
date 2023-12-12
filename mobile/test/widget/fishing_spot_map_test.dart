import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/pages/pro_page.dart';
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

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late StubbedMapController mapController;

  setUp(() {
    appManager = StubbedAppManager();
    mapController = StubbedMapController();

    when(appManager.bodyOfWaterManager.listSortedByDisplayName(any))
        .thenReturn([]);

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.withinPreferenceRadius(any))
        .thenReturn(null);
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.gpsTrailManager.activeTrial).thenReturn(null);
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(false);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.userPreferenceManager.setMapType(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(0, 0)));
  });

  MapboxMap findMap(WidgetTester tester) =>
      tester.widget<MapboxMap>(find.byType(MapboxMap));

  Future<void> pumpMapWrapper(WidgetTester tester, Widget mapWidget) async {
    await pumpMap(tester, appManager, mapController, mapWidget);
  }

  testWidgets("My location disabled if current location is null",
      (tester) async {
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);
    await pumpMapWrapper(tester, FishingSpotMap());
    expect(findMap(tester).myLocationEnabled, isFalse);
  });

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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);

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
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    var controller = MockInputController<FishingSpot>();
    when(controller.value = any).thenAnswer((_) {});
    when(controller.value).thenReturn(null);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
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

    when(appManager.fishingSpotManager.list()).thenReturn([controller.value!]);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 2);
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
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 2);
  });

  testWidgets("Start value is current location", (tester) async {
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(5, 6));

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 6);
    expect(map.initialCameraPosition.zoom, 13.0);
  });

  testWidgets("Start value is 0, 0", (tester) async {
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 0);
    expect(map.initialCameraPosition.zoom, 0);
  });

  testWidgets("Uses default zoom when start is not null", (tester) async {
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(5, 6));

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.zoom, 13.0);
  });

  testWidgets("Uses 0 zoom when start value is 0, 0", (tester) async {
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.zoom, 0);
  });

  testWidgets("Search bar is hidden", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showSearchBar: false,
      ),
    );
    expect(find.byType(OurSearchBar), findsNothing);
  });

  testWidgets("Dropped pin at default location", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

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
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    var result = verify(mapController.value.addSymbol(any, captureAny));
    result.called(1);

    // Extract map from symbol data.
    var map = result.captured.first as Map<dynamic, dynamic>;
    var originalId = (map["fishing_spot"] as FishingSpot).id;
    expect(originalId, isNotNull);

    // Move the camera, causing dropped pin to update.
    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(1, 1)));
    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onCameraIdle!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Verify fishing spot ID didn't change.
    result = verify(mapController.value.addSymbol(any, captureAny));
    result.called(1);

    // Extract map from symbol data.
    map = result.captured.first as Map<dynamic, dynamic>;
    var updatedId = (map["fishing_spot"] as FishingSpot).id;
    expect(updatedId, isNotNull);
    expect(updatedId, originalId);
  });

  testWidgets("Dropping pickerSettings pin doesn't notify listeners",
      (tester) async {
    when(appManager.fishingSpotManager.withinPreferenceRadius(any))
        .thenReturn(null);

    var listenerCalls = 0;
    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(
      id: randomId(),
      lat: 1,
      lng: 2,
    );
    controller.addListener(() => listenerCalls++);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    expect(listenerCalls, 0);
  });

  testWidgets("Existing fishing spot is set to controller value",
      (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot;

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
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
  });

  testWidgets("Search bar shows clear button when not picking", (tester) async {
    // Setup mocks so a symbol can be selected.
    var onSymbolTappedCallback = MockArgumentCallbacks<Symbol>();
    when(mapController.value.onSymbolTapped).thenReturn(onSymbolTappedCallback);

    // Setup and existing fishing spot.
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);

    await pumpMapWrapper(tester, FishingSpotMap());

    var result = verify(onSymbolTappedCallback.add(captureAny));
    result.called(1);

    // Manually invoke on tapped callback to select a fishing spot.
    var onSymbolTapped = result.captured.first;
    await onSymbolTapped(Symbol(
      "symbol_1",
      SymbolOptions(
        geometry: fishingSpot.latLng,
        iconImage: "active-pin",
        iconSize: 1.5,
      ),
      {
        "fishing_spot": fishingSpot,
      },
    ));
    await tester.pumpAndSettle();

    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(
      tester
          .widget<AnimatedVisibility>(find.ancestor(
            of: find.byIcon(Icons.clear),
            matching: find.byType(AnimatedVisibility),
          ))
          .visible,
      isTrue,
    );

    // Tapping the clear button dismisses fishing spot.
    await tapAndSettle(tester, find.byIcon(Icons.clear));
    expect(find.byType(FishingSpotDetails), findsNothing);
    expect(
      tester
          .widget<AnimatedVisibility>(find.ancestor(
            of: find.byIcon(Icons.clear),
            matching: find.byType(AnimatedVisibility),
          ))
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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets("Map style button hidden", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMapTypeButton: false,
      ),
    );
    expect(find.byIcon(Icons.layers), findsNothing);
  });

  testWidgets("Selecting new map style updates state", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMapTypeButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    var normal = "ckt1zqb8d1h1p17pglx4pmz4y";
    var satellite = "ckt1m613b127t17qqf3mmw47h";

    expect(findMap(tester).styleString!.contains(normal), isTrue);
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));

    // Manually invoke the style loaded callback so the previous fishing spot
    // is selected again.
    findMap(tester).onStyleLoadedCallback!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(findMap(tester).styleString!.contains(satellite), isTrue);
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(mapController.symbolCount, 1);
    verify(appManager.userPreferenceManager.setMapType(any)).called(1);
  });

  testWidgets("Selecting same map style does not update state", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMapTypeButton: true,
      ),
    );

    var normal = "ckt1zqb8d1h1p17pglx4pmz4y";

    expect(findMap(tester).styleString!.contains(normal), isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Light"));

    expect(findMap(tester).styleString!.contains(normal), isTrue);
    verifyNever(appManager.userPreferenceManager.setMapType(any));
  });

  testWidgets("Current location button hidden", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMyLocationButton: false,
      ),
    );
    expect(find.byIcon(Icons.my_location), findsNothing);
  });

  testWidgets("Current location prompts for permission; declined",
      (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(false));

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMyLocationButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.my_location));

    verify(appManager.permissionHandlerWrapper.isLocationGranted).called(1);
    expect(find.text("Location Access"), findsOneWidget);
  });

  testWidgets("Error getting current location", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showMyLocationButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets("Picking current location button drops pin", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

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

  testWidgets("Current location button clears fishing spot when not picking",
      (tester) async {
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.text("Spot 1"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Current location button starts tracking if GPS trail is active",
      (tester) async {
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    verify(mapController.value.startTracking()).called(1);
  });

  testWidgets("Zoom button hidden", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showZoomExtentsButton: false,
      ),
    );
    expect(find.byIcon(Icons.zoom_out_map), findsNothing);
  });

  testWidgets("Zoom button no-op when no fishing spots", (tester) async {
    when(appManager.fishingSpotManager.list()).thenReturn([]);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showZoomExtentsButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.zoom_out_map));
    verifyNever(mapController.value.animateCamera(any));
  });

  testWidgets("Zoom button animates camera", (tester) async {
    when(appManager.fishingSpotManager.list()).thenReturn([
      FishingSpot(
        name: "Spot 1",
        lat: 1,
        lng: 2,
      ),
    ]);

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        showZoomExtentsButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.zoom_out_map));
    verify(mapController.value.animateCamera(any)).called(1);
  });

  testWidgets("Mapbox telemetry toggled", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);

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
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(fishingSpot.id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.withinPreferenceRadius(any))
        .thenReturn(fishingSpot);

    var controller = InputController<FishingSpot>();
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(fishingSpot1.id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.entityExists(fishingSpot2.id))
        .thenReturn(true);

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

  testWidgets("Selecting existing spot deactivates active spot",
      (tester) async {
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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(fishingSpot1.id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.entityExists(fishingSpot2.id))
        .thenReturn(true);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    // Verify spot is active.
    expect(find.text("Spot 1"), findsNWidgets(2));
    expect(mapController.symbolCount, 2); // 2 spots
    verify(mapController.value.updateSymbol(any, any)).called(2);

    // Select a new spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 2"));
    expect(find.text("Spot 2"), findsNWidgets(2));

    verify(mapController.value.updateSymbol(any, any)).called(2);
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
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));

    mapController.clearSymbols();
    await tapAndSettle(tester, find.text("Spot 1"));

    verifyNever(mapController.value.updateSymbol(any, any));
  });

  testWidgets("Selecting spot activates symbol", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    var result = verify(mapController.value.updateSymbol(any, captureAny));
    result.called(1);

    var symbolOptions = result.captured.first as SymbolOptions;
    expect(symbolOptions.iconImage, "active-pin");
  });

  testWidgets("Editing selected spot updates fishing spot widget",
      (tester) async {
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);

    // Use real FishingSpotManager to trigger update callbacks.
    var fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);
    fishingSpotManager.addOrUpdate(FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    ));

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
    verifyNever(appManager.fishingSpotManager.withinPreferenceRadius(any));
  });

  testWidgets("Setting up picker is no-op spot is already active",
      (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 2",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(controller: controller),
      ),
    );
    verifyNever(appManager.fishingSpotManager.withinPreferenceRadius(any));
  });

  testWidgets("Setting up picker selects controller value", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    expect(find.text("Spot 1"), findsNWidgets(2));
  });

  testWidgets("Setting up picker drops pin at selected value", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    var controller = InputController<FishingSpot>();
    controller.value = FishingSpot(
      id: randomId(),
      lat: 1,
      lng: 2,
    );

    await pumpMapWrapper(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    expect(find.text("New Fishing Spot"), findsNWidgets(2));
  });

  testWidgets("Setting up picker drops pin at current location",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 2));

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
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

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
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

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
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot1]);

    await pumpMapWrapper(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    verify(mapController.value.moveCamera(any)).called(1);
  });

  testWidgets("Map setup is only invoked once", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    verify(mapController.value.setSymbolIconAllowOverlap(any)).called(1);
  });

  testWidgets("No-op when camera moves and no dropped pin", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onCameraIdle!();
    verifyNever(mapController.value.cameraPosition);
  });

  testWidgets("Pin updated on camera idle", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition).called(2);

    // Ensure position has changed.
    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(1, 1)));
    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onCameraIdle!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Called once to update the spot, and once to move the map.
    verify(mapController.value.cameraPosition).called(2);
  });

  testWidgets("Pin not updated on camera idle if position didn't change",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(1, 1)));

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition).called(2);

    // Ensure position hasn't changed.
    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(1, 1)));
    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onCameraIdle!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Called once to update the spot, and once to move the map.
    verify(mapController.value.cameraPosition).called(1);
  });

  testWidgets("Target hidden when map is idle", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
      isFalse,
    );
  });

  testWidgets("Target hidden when no active dropped pin", (tester) async {
    VoidCallback? listener;
    when(mapController.value.addListener(any)).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first;
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();

    verifyNever(mapController.value.isCameraMoving);
    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
      isFalse,
    );
  });

  testWidgets("Target is shown when map is moving", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(mapController.value.isCameraMoving).thenReturn(true);

    VoidCallback? listener;
    when(mapController.value.addListener(any)).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first;
    });

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Add a pin.
    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Called once to add the spot, and once to move the map.
    verify(mapController.value.cameraPosition).called(2);

    // Manually invoke controller update listener to trigger _updateTarget.
    expect(listener, isNotNull);
    listener!();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    verify(mapController.value.isCameraMoving).called(1);
    expect(
      findFirstWithIcon<AnimatedVisibility>(tester, CustomIcons.mapTarget)
          .visible,
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
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Select an existing fishing spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Stub FishingSpotManager so the selected spot no longer exists.
    when(appManager.fishingSpotManager.filteredList(any, any)).thenReturn([]);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    // Force call entity listener builder.
    findFirst<EntityListenerBuilder>(tester).onAnyChange!();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text("Spot 1"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Pin not updated if map controller target is null",
      (tester) async {
    when(mapController.value.cameraPosition).thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Tapping add button drops a pin", (tester) async {
    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.add), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);
  });

  testWidgets("Move map exits early if already at position", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(0, 0));

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.my_location), 200);
    verifyNever(mapController.value.animateCamera(captureAny));
  });

  testWidgets("Move map zooms to default", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Default position is 0, 0. Set something else so the map actually moves.
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const LatLng(1, 1));
    await tapAndSettle(tester, find.byIcon(Icons.my_location), 200);

    var result = verify(mapController.value.animateCamera(captureAny));
    result.called(1);

    var update = result.captured.first as CameraUpdate;
    expect(update.toJson()[1]["zoom"], 13.0);
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
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.gpsTrailManager.startTracking(any))
        .thenAnswer((_) => Future.value());
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verify(appManager.gpsTrailManager.startTracking(any)).called(1);
  });

  testWidgets("GPS trail button stops tracking", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verify(appManager.gpsTrailManager.stopTracking()).called(1);
  });

  testWidgets("GPS trail tracking ends if not pro", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    expect(find.byType(ProPage), findsNothing);
  });

  testWidgets("GPS trail button shows Pro page", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    await tapAndSettle(tester, find.byIcon(iconGpsTrail));

    verifyNever(appManager.gpsTrailManager.startTracking(any));
    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("GpsTrailPage shown after tracking ends", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));

    // Trail is active.
    expect(findFirst<BadgeContainer>(tester).isBadgeVisible, isTrue);

    // Deactivate the trail.
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(false);
    controller
        .add(EntityEvent<GpsTrail>(GpsTrailEventType.endTracking, GpsTrail()));
    await tester.pumpAndSettle();
    expect(find.byType(GpsTrailPage), findsOneWidget);

    // Ensure active trail badge is no longer showing.
    await tapAndSettle(tester, find.byIcon(Icons.close));
    expect(findFirst<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });

  testWidgets("GPS trail is setup correctly", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => controller.stream);

    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(true);
    when(appManager.gpsTrailManager.activeTrial).thenReturn(GpsTrail(
      points: [
        GpsTrailPoint(
          lat: 5.0,
          lng: 6.0,
        ),
        GpsTrailPoint(
          lat: 7.0,
          lng: 8.0,
        ),
      ],
    ));
    when(mapController.value.addSymbols(any))
        .thenAnswer((_) => Future.value([]));

    await pumpMapWrapper(tester, FishingSpotMap(showGpsTrailButton: true));
    verify(mapController.value.startTracking()).called(1);

    findFirst<DefaultMapboxMap>(tester)
        .onCameraTrackingChanged!(MyLocationTrackingMode.Tracking);
    controller.add(
        EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, GpsTrail()));
    await tester.pumpAndSettle();

    verify(mapController.value.animateCamera(any)).called(1);
  });

  testWidgets("GPS trail update exits early if picking", (tester) async {
    var controller = StreamController<EntityEvent<GpsTrail>>.broadcast();
    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => controller.stream);

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
        EntityEvent<GpsTrail>(GpsTrailEventType.startTracking, GpsTrail()));
    verifyNever(appManager.gpsTrailManager.activeTrial);
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
    verifyNever(appManager.gpsTrailManager.activeTrial);
  });

  testWidgets("Map type updates when theme mode changes", (tester) async {
    var controller = StreamController<String>.broadcast();
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.userPreferenceManager.themeMode)
        .thenReturn(ThemeMode.light);

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
    when(appManager.userPreferenceManager.themeMode).thenReturn(ThemeMode.dark);
    controller.add(UserPreferenceManager.keyMapType);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findFirst<DefaultMapboxMap>(tester).style, MapType.dark.url);
  });

  testWidgets("Dropping pin while spot is selected creates new spot",
      (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await pumpMapWrapper(tester, FishingSpotMap());
    await mapController.finishLoading(tester);

    // Select an existing fishing spot.
    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot 1"), 200);
    expect(find.byType(FishingSpotDetails), findsOneWidget);
    expect(find.text("Spot 1"), findsNWidgets(2));

    // Move the camera and add a new spot, causing dropped pin to update.
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(mapController.value.cameraPosition)
        .thenReturn(const CameraPosition(target: LatLng(1, 1)));
    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onCameraIdle!();
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
      FishingSpotMap.selected(FishingSpot(
        id: randomId(),
        name: "Spot 1",
        lat: 1,
        lng: 2,
      )),
    );
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Directions button is shown if widget is static", (tester) async {
    await pumpMapWrapper(
      tester,
      FishingSpotMap.selected(FishingSpot(
        id: randomId(),
        name: "Spot 1",
        lat: 1,
        lng: 2,
      )),
    );
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets("Directions button is hidden while picking", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

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
