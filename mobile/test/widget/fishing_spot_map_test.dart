import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as quiver;

import '../mocks/mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));
  });

  void stubFishingSpots() {
    var fishingSpots = <FishingSpot>[
      FishingSpot()
        ..id = randomId()
        ..name = "Fishing Spot 1"
        ..lat = 1.23456
        ..lng = 6.54321,
      FishingSpot()
        ..id = randomId()
        ..name = "Fishing Spot 2"
        ..lat = 2.23456
        ..lng = 7.54321,
      FishingSpot()
        ..id = randomId()
        ..lat = 3.23456
        ..lng = 8.54321,
      FishingSpot()
        ..id = randomId()
        ..name = "Fishing Spot 4"
        ..lat = 4.23456
        ..lng = 9.54321,
    ];
    when(appManager.fishingSpotManager.listSortedByName())
        .thenReturn(fishingSpots);
    when(appManager.fishingSpotManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenAnswer((invocation) => fishingSpots
          ..removeWhere((spot) {
            String? filter = invocation.namedArguments[Symbol("filter")];
            if (quiver.isEmpty(filter)) {
              return false;
            }
            if (quiver.isEmpty(spot.name)) {
              return !spot.lat.toString().contains(filter!) &&
                  !spot.lng.toString().contains(filter);
            }

            return !spot.name.contains(filter!);
          }));
  }

  group("Search bar", () {
    testWidgets("No search bar", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byType(SearchBar), findsNothing);
    });

    testWidgets("Search bar exists", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets("Open fishing spot list with no fishing spots", (tester) async {
      when(appManager.fishingSpotManager.listSortedByName()).thenReturn([]);

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyListPlaceholder), findsOneWidget);
      expect(find.byType(ListItem), findsNothing);
    });

    testWidgets("Spots rendered in list correctly", (tester) async {
      stubFishingSpots();

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      expect(find.text("Fishing Spot 1"), findsOneWidget);
      expect(find.text("Fishing Spot 2"), findsOneWidget);
      expect(find.text("Lat: 3.234560, Lng: 8.543210"), findsOneWidget);
      expect(find.text("Fishing Spot 4"), findsOneWidget);
    });

    testWidgets("Tap fishing spot invokes callback", (tester) async {
      stubFishingSpots();

      var picked = false;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(
            onFishingSpotPicked: (_) => picked = true,
          ),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Fishing Spot 1"));
      await tester.pumpAndSettle();

      // Verify search page closes and the picked callback was invoked.
      expect(find.byType(FishingSpotListPage), findsNothing);
      expect(picked, isTrue);
    });

    /// https://github.com/cohenadair/anglers-log/issues/464
    testWidgets("Selecting 'None' doesn't crash the app", (tester) async {
      stubFishingSpots();

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tapAndSettle(tester, find.byType(SearchBar));
      await tapAndSettle(tester, find.text("None"));

      // Verify search page closes.
      expect(find.byType(FishingSpotListPage), findsNothing);
    });

    testWidgets("Filter list", (tester) async {
      stubFishingSpots();

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), "2");
      await tester.pumpAndSettle(Duration(milliseconds: 550));

      expect(find.text("Fishing Spot 1"), findsNothing);
      expect(find.text("Fishing Spot 2"), findsOneWidget);
      expect(find.text("Lat: 3.234560, Lng: 8.543210"), findsOneWidget);
      expect(find.text("Fishing Spot 4"), findsNothing);
    });

    testWidgets("Filter list no result", (tester) async {
      stubFishingSpots();

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          searchBar: FishingSpotMapSearchBar(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), "Test");
      await tester.pumpAndSettle(Duration(milliseconds: 550));

      expect(find.byType(EmptyListPlaceholder), findsOneWidget);
    });
  });

  group("Children", () {
    testWidgets("Children are rendered", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          children: [
            Text("Test 1"),
            Text("Test 2"),
            Text("Test 3"),
          ],
        ),
        appManager: appManager,
      ));

      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.text("Test 1"), findsOneWidget);
      expect(find.text("Test 2"), findsOneWidget);
      expect(find.text("Test 3"), findsOneWidget);
    });
  });

  group("Help tooltip", () {
    testWidgets("No help", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 2100));
      expect(find.byType(HelpTooltip), findsNothing);
      expect(find.byIcon(Icons.help), findsNothing);
    });

    testWidgets("Help", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          help: Text("Help"),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(findFirst<HelpTooltip>(tester).showing, isTrue);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets("Help is hidden after delay", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          help: Text("Help"),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 2100));
      expect(findFirst<HelpTooltip>(tester).showing, isFalse);
    });

    testWidgets("Tapping FAB shows widget", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          help: Text("Help"),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 2100));

      // Show help.
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();
      expect(findFirst<HelpTooltip>(tester).showing, isTrue);
    });

    testWidgets("Hides if map is dragged", (tester) async {
      var controller = Completer<GoogleMapController>();

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: controller,
          help: Text("Help"),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 2100));

      // Show help.
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();
      expect(findFirst<HelpTooltip>(tester).showing, isTrue);

      findFirst<GoogleMap>(tester).onCameraMoveStarted!();
      await tester.pumpAndSettle();
      expect(findFirst<HelpTooltip>(tester).showing, isFalse);
    });
  });

  group("Map interaction", () {
    testWidgets("onCameraMoveStarted", (tester) async {
      var called = false;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          onMoveStarted: () => called = true,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      findFirst<GoogleMap>(tester).onCameraMoveStarted!();
      expect(called, isTrue);
    });

    testWidgets("onCameraMove", (tester) async {
      var called = false;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          onMove: (_) => called = true,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      findFirst<GoogleMap>(tester).onCameraMove!(CameraPosition(
        target: LatLng(1, 1),
      ));
      expect(called, isTrue);
    });
  });

  group("Map type", () {
    testWidgets("Changing the map type", (tester) async {
      MapType? currentType;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          onMapTypeChanged: (newType) => currentType = newType,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.layers));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Satellite"));
      await tester.pumpAndSettle();

      expect(currentType, MapType.satellite);
    });
  });

  group("My location button", () {
    testWidgets("Hidden", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          showMyLocationButton: false,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byIcon(Icons.my_location), findsNothing);
    });

    testWidgets("Showing", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets("onPressed no location shows error", (tester) async {
      var pressed = false;
      await tester.pumpWidget(Testable(
        (_) => Scaffold(
          body: FishingSpotMap(
            mapController: Completer<GoogleMapController>(),
            onCurrentLocationPressed: () => pressed = true,
          ),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      when(appManager.locationMonitor.currentLocation).thenReturn(null);
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(pressed, isFalse);
    });

    testWidgets("onPressed invokes callback", (tester) async {
      var pressed = false;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          onCurrentLocationPressed: () => pressed = true,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(1, 1));
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets("onPressed shows permission dialog when denied",
        (tester) async {
      when(appManager.permissionHandlerWrapper.requestLocation())
          .thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(find.text("OPEN SETTINGS"), findsOneWidget);
    });
  });

  group("Zoom extents button", () {
    testWidgets("Hidden", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
          showZoomExtentsButton: false,
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byIcon(Icons.zoom_out_map), findsNothing);
    });

    testWidgets("Showing", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));
      expect(find.byIcon(Icons.zoom_out_map), findsOneWidget);
    });

    testWidgets("onPressed invokes callback", (tester) async {
      var completer = Completer<MockGoogleMapController>();
      var controller = MockGoogleMapController();
      when(controller.animateCamera(any)).thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        Testable(
          (_) => FishingSpotMap(
            mapController: completer,
            markers: {
              FishingSpotSymbol(
                fishingSpot: FishingSpot()
                  ..lat = 50
                  ..lng = 1,
              ),
              FishingSpotSymbol(
                fishingSpot: FishingSpot()
                  ..lat = -45
                  ..lng = 150,
              ),
            },
          ),
          appManager: appManager,
        ),
      );
      completer.complete(controller);
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.zoom_out_map));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      verify(controller.animateCamera(any)).called(1);
    });

    testWidgets("onPressed with no markers does not invoke callback",
        (tester) async {
      var completer = Completer<MockGoogleMapController>();
      var controller = MockGoogleMapController();
      when(controller.animateCamera(any)).thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        Testable(
          (_) => FishingSpotMap(
            mapController: completer,
          ),
          appManager: appManager,
        ),
      );
      completer.complete(controller);
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.zoom_out_map));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      verifyNever(controller.animateCamera(any));
    });
  });
}
