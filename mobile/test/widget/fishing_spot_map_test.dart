import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/slide_up_transition.dart';
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

    when(appManager.bodyOfWaterManager.listSortedByName()).thenReturn([]);

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.withinRadius(any)).thenReturn(null);
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.userPreferenceManager.setMapType(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
  });

  MapboxMap findMap(WidgetTester tester) =>
      tester.widget<MapboxMap>(find.byType(MapboxMap));

  Future<void> pumpMap(WidgetTester tester, Widget mapWidget) async {
    await tester.pumpWidget(Testable(
      (_) => mapWidget,
      appManager: appManager,
    ));

    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
  }

  testWidgets("My location disabled for static map", (tester) async {
    await pumpMap(
      tester,
      StaticFishingSpotMap(
        FishingSpot(
          id: randomId(),
          lat: 1.23456,
          lng: 6.54321,
        ),
      ),
    );

    expect(findMap(tester).myLocationEnabled, isFalse);
  });

  testWidgets("My location disabled if current location is null",
      (tester) async {
    when(appManager.locationMonitor.currentLocation).thenReturn(null);
    await pumpMap(tester, FishingSpotMap());
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
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;

    await pumpMap(tester, _DidUpdateWidgetTester(controller));
    expect(find.text("Spot 1"), findsOneWidget);

    controller.value = fishingSpot2;
    await tapAndSettle(tester, find.text("TEST"));

    expect(find.text("Spot 2"), findsOneWidget);
  });

  testWidgets("Controller updated on back navigation", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    var controller = InputController<FishingSpot>();
    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    expect(controller.hasValue, isFalse);
    expect(find.text("Dropped Pin"), findsNWidgets(2));

    await tapAndSettle(tester, find.byType(BackButton));
    expect(controller.hasValue, isTrue);
  });

  testWidgets("Scaffold rendered when widget is a page", (tester) async {
    await pumpMap(tester, FishingSpotMap());
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets("Scaffold not rendered when widget is not a page",
      (tester) async {
    await pumpMap(
      tester,
      StaticFishingSpotMap(
        FishingSpot(
          name: "Spot 1",
          lat: 1,
          lng: 2,
        ),
      ),
    );
    expect(find.byType(Scaffold), findsNothing);
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

    await pumpMap(
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

    await pumpMap(
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
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(5, 6));

    await pumpMap(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 6);
    expect(map.initialCameraPosition.zoom, 13.0);
  });

  testWidgets("Start value is 0, 0", (tester) async {
    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    await pumpMap(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.target.longitude, 0);
    expect(map.initialCameraPosition.zoom, 0);
  });

  testWidgets("Uses default zoom when start is not null", (tester) async {
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(5, 6));

    await pumpMap(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.zoom, 13.0);
  });

  testWidgets("Uses 0 zoom when start value is 0, 0", (tester) async {
    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    await pumpMap(tester, FishingSpotMap());

    var map = findMap(tester);
    expect(map.initialCameraPosition.zoom, 0);
  });

  testWidgets("Search bar is hidden", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showSearchBar: false,
      ),
    );
    expect(find.byType(SearchBar), findsNothing);
  });

  testWidgets("Dropped pin at default location", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    // Text shows in the search bar and bottom container.
    expect(find.text("Dropped Pin"), findsNWidgets(2));
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

    await pumpMap(
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
    await pumpMap(
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
    await pumpMap(
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
    await pumpMap(
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

    await pumpMap(tester, FishingSpotMap());

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
    await pumpMap(tester, FishingSpotMap());
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));
  });

  testWidgets("Map style button hidden", (tester) async {
    await pumpMap(
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
    await pumpMap(
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

    expect(findMap(tester).styleString!.contains(satellite), isTrue);
    expect(find.text("Spot 1"), findsNWidgets(2));
    verify(appManager.userPreferenceManager.setMapType(any)).called(1);
  });

  testWidgets("Selecting same map style does not update state", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showMapTypeButton: true,
      ),
    );

    var normal = "ckt1zqb8d1h1p17pglx4pmz4y";

    expect(findMap(tester).styleString!.contains(normal), isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Normal"));

    expect(findMap(tester).styleString!.contains(normal), isTrue);
    verifyNever(appManager.userPreferenceManager.setMapType(any));
  });

  testWidgets("Current location button hidden", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showMyLocationButton: false,
      ),
    );
    expect(find.byIcon(Icons.my_location), findsNothing);
  });

  testWidgets("Current location prompts for permission; declined",
      (tester) async {
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));

    await pumpMap(
      tester,
      FishingSpotMap(
        showMyLocationButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.my_location));

    verify(appManager.permissionHandlerWrapper.requestLocation()).called(1);
    expect(find.text("Location Access"), findsOneWidget);
  });

  testWidgets("Error getting current location", (tester) async {
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));
    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    await pumpMap(
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
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));

    await pumpMap(
      tester,
      FishingSpotMap(
        showMyLocationButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.text("Dropped Pin"), findsNWidgets(2));
  });

  testWidgets("Current location button clears fishing spot when not picking",
      (tester) async {
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.requestLocation())
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.text("Search fishing spots"));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 1"));
    expect(find.text("Spot 1"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.my_location));
    expect(find.text("Spot 1"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsNothing);
  });

  testWidgets("Zoom button hidden", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showZoomExtentsButton: false,
      ),
    );
    expect(find.byIcon(Icons.zoom_out_map), findsNothing);
  });

  testWidgets("Zoom button no-op when no fishing spots", (tester) async {
    when(appManager.fishingSpotManager.list()).thenReturn([]);

    await pumpMap(
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

    await pumpMap(
      tester,
      FishingSpotMap(
        showZoomExtentsButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.zoom_out_map));
    verify(mapController.value.animateCamera(any)).called(1);
  });

  testWidgets("Help button is hidden", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showHelpButton: false,
      ),
    );
    expect(find.byIcon(Icons.help), findsNothing);
    expect(
        tester.widget<HelpTooltip>(find.byType(HelpTooltip)).showing, isFalse);
  });

  testWidgets("Help button shows help widget; picking", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showHelpButton: true,
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.help));
    expect(tester.widget<HelpTooltip>(find.byType(HelpTooltip)).showing, true);
    expect(
      find.text("Long press the map to pick exact coordinates, or select an "
          "existing fishing spot."),
      findsOneWidget,
    );
  });

  testWidgets("No selected spot shows empty", (tester) async {
    await pumpMap(
      tester,
      FishingSpotMap(
        showHelpButton: true,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.help));
    expect(tester.widget<HelpTooltip>(find.byType(HelpTooltip)).showing, true);
    expect(
      find.text("Long press anywhere on the map to drop a pin and add a "
          "fishing spot."),
      findsOneWidget,
    );
  });

  testWidgets("Static doesn't animate", (tester) async {
    await pumpMap(
      tester,
      StaticFishingSpotMap(
        FishingSpot(
          id: randomId(),
          lat: 1.23456,
          lng: 6.54321,
        ),
      ),
    );

    expect(find.byType(SlideUpTransition), findsNothing);
  });

  testWidgets("White attribution logo", (tester) async {
    await pumpMap(tester, FishingSpotMap());

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));

    expect(
      tester
          .widget<MapboxAttribution>(find.byType(MapboxAttribution).first)
          .logoColor,
      Colors.white,
    );
  });

  testWidgets("Black attribution logo", (tester) async {
    await pumpMap(tester, FishingSpotMap());

    expect(
      tester
          .widget<MapboxAttribution>(find.byType(MapboxAttribution).first)
          .logoColor,
      Colors.black,
    );
  });

  testWidgets("Mapbox telemetry toggled", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await pumpMap(tester, FishingSpotMap());
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMap(tester, FishingSpotMap());
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
    when(appManager.fishingSpotManager.withinRadius(any))
        .thenReturn(fishingSpot);

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    // Text shows in the search bar and bottom container.
    expect(find.text("Spot 1"), findsNWidgets(2));
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(fishingSpot1.id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.entityExists(fishingSpot2.id))
        .thenReturn(true);

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    // Verify pin is dropped.
    expect(find.text("Dropped Pin"), findsNWidgets(2));
    expect(mapController.symbolCount, 3); // 2 spots, 1 dropped pin

    // Select an existing spot.
    await tapAndSettle(tester, find.byType(SearchBar));
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.fishingSpotManager.entityExists(fishingSpot1.id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.entityExists(fishingSpot2.id))
        .thenReturn(true);

    var controller = InputController<FishingSpot>();
    controller.value = fishingSpot1;
    await pumpMap(
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
    verify(mapController.value.updateSymbol(captureAny, captureAny)).called(1);

    // Select a new spot.
    await tapAndSettle(tester, find.byType(SearchBar));
    expect(find.byType(FishingSpotListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Spot 2"));
    expect(find.text("Spot 2"), findsNWidgets(2));

    verify(mapController.value.updateSymbol(captureAny, captureAny)).called(2);
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1, fishingSpot2]);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(SearchBar));

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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1]);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    var result = verify(mapController.value.updateSymbol(any, captureAny));
    result.called(1);

    var symbolOptions = result.captured.first as SymbolOptions;
    expect(symbolOptions.iconImage, "active-pin");
  });

  testWidgets("Setting up picker is no-op when not picking", (tester) async {
    await pumpMap(tester, FishingSpotMap());
    verifyNever(appManager.fishingSpotManager.entityExists(any));
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
    await pumpMap(
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

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: controller,
        ),
      ),
    );

    expect(find.text("Dropped Pin"), findsNWidgets(2));
  });

  testWidgets("Setting up picker drops pin at current location",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(1, 2));

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    expect(find.text("Dropped Pin"), findsNWidgets(2));
    expect(find.text("Lat: 1.000000, Lng: 2.000000"), findsOneWidget);
  });

  testWidgets("Setting up picker drops pin at 0, 0", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    await pumpMap(
      tester,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: InputController<FishingSpot>(),
        ),
      ),
    );

    expect(find.text("Dropped Pin"), findsNWidgets(2));
    expect(find.text("Lat: 0.000000, Lng: 0.000000"), findsOneWidget);
  });

  testWidgets("Map movement is animated", (tester) async {
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(1, 2));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));

    await pumpMap(tester, FishingSpotMap());
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
    when(appManager.fishingSpotManager.filteredList(any))
        .thenReturn([fishingSpot1]);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("Spot 1"));

    verify(mapController.value.moveCamera(any)).called(1);
  });

  testWidgets("Static picker settings sets controller value", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      name: "Spot 1",
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);

    await pumpMap(tester, StaticFishingSpotMap(fishingSpot1));
    expect(find.text("Spot 1"), findsOneWidget);
  });

  testWidgets("Static picker hides dropped pin text", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMap(tester, StaticFishingSpotMap(fishingSpot1));
    expect(find.text("Dropped Pin"), findsNothing);
  });

  testWidgets("Static map offsets position; moves map only once",
      (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMap(tester, StaticFishingSpotMap(fishingSpot1));
    verify(mapController.value.toLatLng(any)).called(1);
    verify(mapController.value.moveCamera(any)).called(1);
    verifyNever(mapController.value.animateCamera(any));
  });

  testWidgets("WillPopScope is included in widget tree", (tester) async {
    await pumpMap(tester, FishingSpotMap());
    expect(find.byType(WillPopScope), findsOneWidget);
  });

  testWidgets("WillPopScope is not included in widget tree", (tester) async {
    var fishingSpot1 = FishingSpot(
      id: randomId(),
      lat: 1,
      lng: 2,
    );
    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot1]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await pumpMap(tester, StaticFishingSpotMap(fishingSpot1));
    expect(find.byType(WillPopScope), findsNothing);
  });

  testWidgets("Attribution icon shows bottom sheet", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for Android"), findsOneWidget);
  });

  testWidgets("Attribution iOS title", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for iOS"), findsOneWidget);
  });

  testWidgets("Attribution Android title", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for Android"), findsOneWidget);
  });

  testWidgets("Attribution URL launched", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpMap(tester, FishingSpotMap());
    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    await tapAndSettle(tester, find.text("Improve This Map"));

    verify(appManager.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Map setup is only invoked once", (tester) async {
    await pumpMap(tester, FishingSpotMap());
    verify(mapController.value.setSymbolIconAllowOverlap(any)).called(1);
  });
}

class _DidUpdateWidgetTester extends StatefulWidget {
  final InputController<FishingSpot> controller;

  const _DidUpdateWidgetTester(this.controller);

  @override
  __DidUpdateWidgetTesterState createState() => __DidUpdateWidgetTesterState();
}

class __DidUpdateWidgetTesterState extends State<_DidUpdateWidgetTester> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Button(
          text: "Test",
          onPressed: () => setState(() {}),
        ),
        StaticFishingSpotMap(widget.controller.value!),
      ],
    );
  }
}
