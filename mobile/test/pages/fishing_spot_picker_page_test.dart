import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/floating_container.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var fishingSpot = FishingSpot()
    ..id = randomId()
    ..name = "Test Fishing Spot"
    ..lat = 1.234567
    ..lng = 7.654321;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.listSortedByName())
        .thenReturn([fishingSpot]);
    when(appManager.fishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);
    when(appManager.fishingSpotManager.withinRadius(any, any)).thenReturn(null);
    when(appManager.fishingSpotManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LatLng(0.0, 0.0));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
  });

  // TODO (1): GoogleMap is a native widget; gesture testing doesn't work yet.

  testWidgets("Initial fishing spot shows bottom sheet", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Test Fishing Spot"), findsOneWidget);
    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
    // TODO: Verify marker color
    // TODO: Verify pending marker isn't shown
  });

  testWidgets("Bottom sheet not shown if fishing spot not selected",
      (tester) async {
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
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Center widget shown when no fishing spot is selected",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("On map idle, pending fishing spot is added", (tester) async {
    // TODO (1)
    // TODO: Verify marker color
    // This includes when the picker is built without an initial fishing spot.
    // This should test everything in the onIdle callback.
  });

  testWidgets("On map move started by drag, current spot is cleared",
      (tester) async {
    // TODO (1)
    // TODO: Verify pending marker isn't shown
  });

  testWidgets("On map move stopped after drag, pending spot is added",
      (tester) async {
    // TODO (1)
  });

  testWidgets("Center widget color depends on map type", (tester) async {
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

  testWidgets("Action button showing", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        actionButtonText: "SAVE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("SAVE"), findsOneWidget);
  });

  testWidgets("Action button hidden", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(ActionButton), findsNothing);
  });

  testWidgets("Action button disabled when nothing picked", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        actionButtonText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(findFirst<ActionButton>(tester).onPressed, isNull);
  });

  testWidgets("Selecting fishing spot from search updates map", (tester) async {
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
      (tester) async {
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

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Opening picker with select spot has spot picked",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("Test Fishing Spot"));
    await tapAndSettle(tester, find.byType(SearchBar));

    expect(
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "Test Fishing Spot"),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Opening picker with custom start position", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        startPos: LatLng(1.234567, 8.765432),
        onPicked: (_, __) {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Manually trigger map's onIdle since Google Maps doesn't trigger it in
    // unit tests.
    findFirst<GoogleMap>(tester).onMapCreated!(MockGoogleMapController());
    findFirst<FishingSpotMap>(tester).onIdle!();

    // Wait for "pending" fishing spot animation.
    await tester.pump(Duration(milliseconds: 1000));

    expect(find.text("Lat: 1.234567, Lng: 8.765432"), findsOneWidget);
  });

  testWidgets("Editing fishing spot updates bottom sheet", (tester) async {
    // Use real FishingSpotManager so updates are done correctly.
    var fishingSpotManager = FishingSpotManager(appManager.app);
    fishingSpotManager.addOrUpdate(fishingSpot);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) {},
        fishingSpotId: fishingSpot.id,
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

  testWidgets("onPicked invoked on pop when there's no action button",
      (tester) async {
    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(picked, isTrue);
  });

  testWidgets("onPicked not invoked on pop when there's an action button",
      (tester) async {
    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
        fishingSpotId: fishingSpot.id,
        actionButtonText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(picked, isFalse);
  });

  testWidgets("onPicked invoked when action button pressed", (tester) async {
    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
        fishingSpotId: fishingSpot.id,
        actionButtonText: "DONE",
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    await tapAndSettle(tester, find.text("DONE"));

    expect(picked, isTrue);
  });

  testWidgets("onPicked invoked when 'None' is picked", (tester) async {
    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("None"));

    expect(picked, isTrue);
  });

  testWidgets("When no spot selected, selects closest within default distance",
      (tester) async {
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LatLng(1.0, 2.0));
    when(appManager.fishingSpotManager.withinRadius(any))
        .thenReturn(FishingSpot()
          ..id = randomId()
          ..lat = 1.0
          ..lng = 2.0);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    verify(appManager.fishingSpotManager.withinRadius(any)).called(1);
    expect(find.text("Lat: 1.000000, Lng: 2.000000"), findsOneWidget);
  });

  testWidgets("New fishing spot is added to database", (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(LatLng(1.0, 2.0));

    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => {},
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(BackButton));

    var result = verify(appManager.fishingSpotManager.addOrUpdate(captureAny));
    result.called(1);

    var fishingSpot = result.captured.first as FishingSpot;
    expect(fishingSpot.lat, 1.0);
    expect(fishingSpot.lng, 2.0);
  });

  testWidgets("Picking existing fishing spot doesn't make database call",
      (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(fishingSpot);

    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(BackButton));

    verifyNever(appManager.fishingSpotManager.addOrUpdate(any));
    expect(picked, isTrue);
  });

  testWidgets("When no spot is picked, database call is not made",
      (tester) async {
    var picked = false;
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPickerPage(
        onPicked: (_, __) => picked = true,
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("None"));

    verifyNever(appManager.fishingSpotManager.addOrUpdate(any));
    expect(picked, isTrue);
  });
}
