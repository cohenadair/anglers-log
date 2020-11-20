import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as quiver;

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
    );
  });

  void stubFishingSpots() {
    var fishingSpots = <FishingSpot>[
      FishingSpot()
        ..name = "Fishing Spot 1"
        ..lat = 1.23456
        ..lng = 6.54321,
      FishingSpot()
        ..name = "Fishing Spot 2"
        ..lat = 2.23456
        ..lng = 7.54321,
      FishingSpot()
        ..lat = 3.23456
        ..lng = 8.54321,
      FishingSpot()
        ..name = "Fishing Spot 4"
        ..lat = 4.23456
        ..lng = 9.54321,
    ];
    when(appManager.mockFishingSpotManager.listSortedByName())
        .thenReturn(fishingSpots);
    when(appManager.mockFishingSpotManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenAnswer((invocation) => fishingSpots
          ..removeWhere((spot) {
            String filter = invocation.namedArguments[Symbol("filter")];
            if (quiver.isEmpty(filter)) {
              return false;
            }
            if (quiver.isEmpty(spot.name)) {
              return !spot.lat.toString().contains(filter) &&
                  !spot.lng.toString().contains(filter);
            }
            return !spot.name.contains(
                invocation.namedArguments[Symbol("filter")] as String);
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

    testWidgets("Open fishing spot list with no fishing spots",
        (tester) async {
      when(appManager.mockFishingSpotManager.listSortedByName()).thenReturn([]);

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

      // For now, an empty ListView is shown.
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListItem), findsNothing);
    });

    testWidgets("Spots rendered in list correctly",
        (tester) async {
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

    testWidgets("Tap fishing spot invokes callback",
        (tester) async {
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
      expect(find.byType(SearchPage), findsNothing);
      expect(picked, isTrue);
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
      await tester.enterText(find.byType(TextField), "2");
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
      await tester.enterText(find.byType(TextField), "Test");
      await tester.pumpAndSettle(Duration(milliseconds: 550));

      expect(find.byType(NoResults), findsOneWidget);
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

      findFirst<GoogleMap>(tester).onCameraMoveStarted();
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

      findFirst<GoogleMap>(tester).onCameraMoveStarted();
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

      findFirst<GoogleMap>(tester).onCameraMove(CameraPosition(
        target: LatLng(1, 1),
      ));
      expect(called, isTrue);
    });
  });

  group("Map type", () {
    Visibility visibility(String text, tester) {
      return tester.firstWidget(find.descendant(
        of: find.widgetWithText(ListItem, text),
        matching: find.byType(Visibility),
      ));
    }

    testWidgets("All map options + check mark", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotMap(
          mapController: Completer<GoogleMapController>(),
        ),
        appManager: appManager,
      ));
      await tester.pumpAndSettle(Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.layers));
      await tester.pumpAndSettle();

      // Verify options.
      expect(find.text("Normal"), findsOneWidget);
      expect(visibility("Normal", tester).visible, isTrue);
      expect(find.text("Satellite"), findsOneWidget);
      expect(visibility("Satellite", tester).visible, isFalse);
      expect(find.text("Hybrid"), findsOneWidget);
      expect(visibility("Hybrid", tester).visible, isFalse);
      expect(find.text("Terrain"), findsOneWidget);
      expect(visibility("Terrain", tester).visible, isFalse);
    });

    testWidgets("Changing the map type", (tester) async {
      MapType currentType;
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

      when(appManager.mockLocationMonitor.currentLocation).thenReturn(null);
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

      when(appManager.mockLocationMonitor.currentLocation)
          .thenReturn(LatLng(1, 1));
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}
