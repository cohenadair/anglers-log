import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/map_page.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/styled_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  List<FishingSpot> fishingSpots = [
    FishingSpot()
      ..id = randomId()
      ..name = "A"
      ..lat = 2.345678
      ..lng = 6.543210,
    FishingSpot()
      ..id = randomId()
      ..lat = 1.234567
      ..lng = 7.654321,
    FishingSpot()
      ..id = randomId()
      ..lat = 3.456789
      ..lng = 5.432109,
    FishingSpot()
      ..id = randomId()
      ..name = "D"
      ..lat = 4.567890
      ..lng = 4.321098,
    FishingSpot()
      ..id = randomId()
      ..name = "E"
      ..lat = 5.678901
      ..lng = 3.210987,
  ];

  setUp(() {
    appManager = MockAppManager(
      mockDataManager: true,
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
    );

    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockFishingSpotManager.list()).thenReturn(fishingSpots);
    when(appManager.mockFishingSpotManager.listSortedByName())
        .thenReturn(fishingSpots);

    when(appManager.mockLocationMonitor.currentLocation)
        .thenReturn(LatLng(0.0, 0.0));
  });

  // TODO: GoogleMap is a native widget, so gesture testing doesn't work yet.
  // TODO (1): Marker tapping - https://github.com/flutter/flutter/issues/36024
  // TODO (2): Camera movement verification when Google Map updates
  // TODO (3): Map tapping when Google Map updates

  testWidgets("Active fishing spot with name", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    // Search bar and bottom sheet
    expect(find.text("A"), findsNWidgets(2));
    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isTrue);
    expect(find.byType(StyledBottomSheet), findsOneWidget);
    expect(find.text("Lat: 2.345678, Lng: 6.543210"), findsOneWidget);

    // TODO (1): Verify marker color
  });

  testWidgets("Active fishing spot without name", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("Lat: 1.234567, Lng: 7.654321"));

    expect(find.text("1.234567, 7.654321"), findsOneWidget);
    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isTrue);
    expect(find.byType(StyledBottomSheet), findsOneWidget);

    // TODO (1): Verify marker color
  });

  testWidgets("Clear button closes bottom sheet", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    expect(find.text("A"), findsNWidgets(2));
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isTrue);
    expect(find.byType(StyledBottomSheet), findsOneWidget);

    // Clear current selection.
    await tapAndSettle(tester, find.byIcon(Icons.clear));

    expect(find.text("A"), findsNothing);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isFalse);
    expect(find.byType(StyledBottomSheet), findsNothing);
  });

  testWidgets("No active fishing spot", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(findFirst<GoogleMap>(tester).markers.length, 5);
    expect(find.text("Search fishing spots"), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isFalse);
    expect(find.byType(StyledBottomSheet), findsNothing);
  });

  testWidgets("Picking new spot from search moves map", (WidgetTester tester)
      async
  {
    // TODO (2): Verify camera movement
  });

  testWidgets("Tapping map drops pin and moves map", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tester.tap(find.byType(GoogleMap));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // TODO (3): Verify pin is dropped
//    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
//        isTrue);
//    expect(find.text("Dropped Pin"), findsNWidgets(2));

    // TODO (2): Verify camera movement
  });

  testWidgets("Updating fishing spot resets active spot", (WidgetTester tester)
      async
  {
    // Setup a real FishingSpotManager so update callbacks are called.
    var fishingSpotManager = FishingSpotManager(appManager);
    for (var fishingSpot in fishingSpots) {
      fishingSpotManager.addOrUpdate(fishingSpot, notify: false);
    }
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    // Update selected fishing spot.
    fishingSpotManager.addOrUpdate(fishingSpots.first.copyWith((updates) {
      updates.name = "Updated Name";
    }));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Updated Name"), findsNWidgets(2));
  });

  testWidgets("Tapping my location clears active spot", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    // Select current location.
    await tapAndSettle(tester, find.byIcon(Icons.my_location));

    expect(find.text("Search fishing spots"), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isFalse);
    expect(find.byType(StyledBottomSheet), findsNothing);
  });

  testWidgets("Dismissing (swipe down) bottom sheet clears active spot",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    // Dismiss bottom sheet.
    await tester.fling(find.byType(StyledBottomSheet), Offset(0, 300), 800);
    await tester.pumpAndSettle();

    expect(find.text("Search fishing spots"), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isFalse);
    expect(find.byType(StyledBottomSheet), findsNothing);
  });

  testWidgets("Deleting spot clears active spot", (WidgetTester tester) async {
    // Setup a real FishingSpotManager so update callbacks are called.
    var fishingSpotManager = FishingSpotManager(appManager);
    for (var fishingSpot in fishingSpots) {
      fishingSpotManager.addOrUpdate(fishingSpot, notify: false);
    }
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    // Update selected fishing spot.
    fishingSpotManager.delete(fishingSpots.first.id);
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Search fishing spots"), findsOneWidget);
    expect(findFirstWithIcon<AnimatedVisibility>(tester, Icons.clear).visible,
        isFalse);
    expect(find.byType(StyledBottomSheet), findsNothing);
  });

  testWidgets("Edit chip opens edit page", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    await tapAndSettle(tester, find.text("Edit"));

    expect(find.byType(SaveFishingSpotPage), findsOneWidget);
  });

  testWidgets("Editing bottom sheet", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Select fishing spot.
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("A"));

    expect(find.text("Edit"), findsOneWidget);
    expect(find.text("Delete"), findsOneWidget);
    expect(find.text("Add Catch"), findsOneWidget);
    expect(find.text("Directions"), findsOneWidget);
  });

  testWidgets("Not editing bottom sheet", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => MapPage(),
      appManager: appManager,
    ));
    // Allow map to load.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Drop a pin.
    await tester.tap(find.byType(GoogleMap));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // TODO (3): Verify pin is dropped
//    expect(find.text("Edit"), findsNothing);
//    expect(find.text("Save"), findsOneWidget);
//    expect(find.text("Delete"), findsNothing);
//    expect(find.text("Add Catch"), findsNothing);
//    expect(find.text("Directions"), findsOneWidget);
  });
}