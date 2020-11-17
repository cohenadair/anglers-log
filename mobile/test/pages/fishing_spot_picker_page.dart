import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/floating_container.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
    );

    when(appManager.mockFishingSpotManager.listSortedByName()).thenReturn([
      FishingSpot()
        ..id = randomId()
        ..name = "Test Fishing Spot"
        ..lat = 1.234567
        ..lng = 7.654321,
    ]);
  });

  // TODO (1): GoogleMap is a native widget; gesture testing doesn't work yet.

  testWidgets("Initial fishing spot shows bottom sheet",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..name = "Fishing Spot 1"
          ..lat = 1.234567
          ..lng = 7.654321,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Fishing Spot 1"), findsOneWidget);
    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
    // TODO: Verify marker color
    // TODO: Verify pending marker isn't shown
  });

  testWidgets("Bottom sheet not shown if fishing spot not selected",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(FloatingContainer), findsNothing);
  });

  testWidgets("Center widget hidden with fishing spot is selected",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..name = "Fishing Spot 1"
          ..lat = 1.234567
          ..lng = 7.654321,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Center widget shown when no fishing spot is selected",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("On map idle, pending fishing spot is added",
      (WidgetTester tester) async
  {
    // TODO (1)
    // TODO: Verify marker color
  });

  testWidgets("On map move started by drag, current spot is cleared",
      (WidgetTester tester) async
  {
    // TODO (1)
    // TODO: Verify pending marker isn't shown
  });

  testWidgets("On map move stopped after drag, pending spot is added",
      (WidgetTester tester) async
  {
    // TODO (1)
  });

  testWidgets("Center widget color depends on map type", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Normal"));
    expect(tester.widget<Icon>(find.byIcon(Icons.add)).color, Colors.black);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Terrain"));
    expect(tester.widget<Icon>(find.byIcon(Icons.add)).color, Colors.black);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));
    expect(tester.widget<Icon>(find.byIcon(Icons.add)).color, Colors.white);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Hybrid"));
    expect(tester.widget<Icon>(find.byIcon(Icons.add)).color, Colors.white);
  });

  testWidgets("Custom done button text", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        doneButtonText: "SAVE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("SAVE"), findsOneWidget);
  });

  testWidgets("Done button disabled if fishing spot not selected",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(findFirstWithText<ActionButton>(tester, "DONE").onPressed, isNull);
  });

  testWidgets("Done button enabled if fishing spot selected",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..name = "Fishing Spot 1"
          ..lat = 1.234567
          ..lng = 7.654321,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(findFirstWithText<ActionButton>(tester, "DONE").onPressed,
        isNotNull);
  });

  testWidgets("Selecting fishing spot from search updates map",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("Test Fishing Spot"));

    expect(find.byType(FloatingContainer), findsOneWidget);
    expect(find.text("Test Fishing Spot"), findsOneWidget);
    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
  });

  testWidgets("Selecting no fishing spot from search does not update map",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.byType(CloseButton));

    expect(find.byType(FloatingContainer), findsNothing);
  });

  testWidgets("Editing fishing spot updates bottom sheet", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..name = "Fishing Spot 1"
          ..lat = 1.234567
          ..lng = 7.654321,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.text("EDIT"));
    expect(find.byType(SaveFishingSpotPage), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "New Name");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.byType(SaveFishingSpotPage), findsNothing);
    expect(find.text("New Name"), findsOneWidget);
  });
}