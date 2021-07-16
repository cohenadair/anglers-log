import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockAssetPathEntity allAlbum;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.catchManager
            .addOrUpdate(any, imageFiles: anyNamed("imageFiles")))
        .thenAnswer((_) => Future.value(false));

    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.listSortedByName()).thenReturn([]);
    when(appManager.fishingSpotManager.withinRadius(any, any)).thenReturn(null);
    when(appManager.fishingSpotManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    var mockAssets = [
      createMockAssetEntity(
        fileName: "android_logo.png",
        latLngLegacy: LatLng(latitude: 1.234567, longitude: 7.654321),
        latLngAsync: LatLng(latitude: 1.234567, longitude: 7.654321),
        dateTime: DateTime(2020, 4, 1),
      ),
      createMockAssetEntity(
        fileName: "anglers_log_logo.png",
        dateTime: DateTime(2020, 3, 1),
      ),
      createMockAssetEntity(
        fileName: "apple_logo.png",
        dateTime: DateTime(2020, 2, 1),
      ),
      createMockAssetEntity(
        fileName: "flutter_logo.png",
        dateTime: DateTime(2020, 1, 1),
      ),
    ];
    allAlbum = MockAssetPathEntity();
    when(allAlbum.assetCount).thenReturn(mockAssets.length);
    when(allAlbum.getAssetListPaged(any, any))
        .thenAnswer((_) => Future.value(mockAssets));
    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(true));
    when(appManager.photoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(allAlbum));

    when(appManager.userPreferenceManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);

    when(appManager.speciesManager.listSortedByName(filter: anyNamed("filter")))
        .thenReturn([
      Species()
        ..id = randomId()
        ..name = "Steelhead"
    ]);

    when(appManager.subscriptionManager.isFree).thenReturn(false);
  });

  testWidgets("Picked image uses location data to fetch existing fishing spot",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot 1"
      ..lat = 9.876543
      ..lng = 3.456789;
    when(appManager.fishingSpotManager.withinRadius(any, any))
        .thenReturn(fishingSpot);
    when(appManager.fishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);
    when(appManager.fishingSpotManager.entityExists(fishingSpot.id))
        .thenReturn(true);
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    verify(appManager.fishingSpotManager.withinRadius(any, any)).called(1);

    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(FishingSpotPickerPage), findsNothing);
    expect(find.byType(SaveCatchPage), findsOneWidget);
    expect(find.text("Spot 1"), findsOneWidget);
    expect(find.text("Lat: 9.876543, Lng: 3.456789"), findsOneWidget);
  });

  testWidgets("Picked image uses location data to create new fishing spot",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    // Select first photo.
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    // Select species.
    await tapAndSettle(tester, find.text("Steelhead"));
    expect(find.byType(FishingSpotPickerPage), findsOneWidget);

    // Manually trigger map's onIdle since Google Maps doesn't trigger it in
    // unit tests.
    findFirst<google.GoogleMap>(tester)
        .onMapCreated!(MockGoogleMapController());
    findFirst<FishingSpotMap>(tester).onIdle!();

    // Wait for "pending" fishing spot animation so NEXT button is enabled.
    await tester.pump(Duration(milliseconds: 1000));

    expect(
        findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNotNull);
    await tapAndSettle(tester, find.text("NEXT"));

    var result = verify(appManager.fishingSpotManager.addOrUpdate(captureAny));
    result.called(1);
    var fishingSpot = result.captured.first as FishingSpot;
    expect(findFirst<SaveCatchPage>(tester).fishingSpotId, fishingSpot.id);
  });

  testWidgets("Picked image without location data shows fishing spot picker",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).at(1));
    await tapAndSettle(tester, find.text("NEXT"));

    verifyNever(appManager.fishingSpotManager.withinRadius(any, any));

    await tapAndSettle(tester, find.text("Steelhead"));
    expect(find.byType(FishingSpotPickerPage), findsOneWidget);
    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);

    // TODO: Can't test any further; GoogleMap doesn't yet support gestures.
  });

  testWidgets("Saving catch pops entire journey", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));
    await tapAndSettle(tester, find.text("SAVE"));

    expect(find.byType(SaveCatchPage), findsNothing);
    expect(find.byType(FishingSpotPickerPage), findsNothing);
    expect(find.byType(SpeciesListPage), findsNothing);
    expect(find.byType(ImagePickerPage), findsNothing);
  });

  testWidgets("Fishing spot is skipped when not tracking fishing spots",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp(),
      catchFieldIdSpecies(),
    ]);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Steelhead"));

    expect(findFirst<SaveCatchPage>(tester).fishingSpotId, isNull);
    expect(find.text("Fishing Spot"), findsNothing);
  });

  testWidgets("Fishing spot is skipped when spot already exists",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(SaveCatchPage), findsOneWidget);
  });

  testWidgets("Photo location is skipped when fishing spot is pre-picked",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..name = "Test");

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(
        fishingSpot: appManager.fishingSpotManager.entity(randomId()),
      ),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(SaveCatchPage), findsOneWidget);
    verifyNever(appManager.fishingSpotManager.withinRadius(any));
  });

  testWidgets("Fishing spot is not skipped when preferences is empty",
      (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(FishingSpotPickerPage), findsOneWidget);
  });

  testWidgets("Image picker is skipped when not tracking images",
      (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp(),
      catchFieldIdSpecies(),
    ]);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsNothing);
    expect(find.byType(SpeciesListPage), findsOneWidget);

    // Ensure a close button is still shown.
    // 1 for closing the journey, 1 for clearing the search bar.
    expect(find.byIcon(Icons.close), findsNWidgets(2));
  });

  testWidgets("Image picker is not skipped when preferences is empty",
      (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsOneWidget);
    expect(find.byType(SpeciesListPage), findsNothing);

    await tapAndSettle(tester, find.text("NEXT"));
    expect(find.byType(SpeciesListPage), findsOneWidget);

    // Ensure a back button (not close button) is still shown.
    expect(find.byType(BackButton), findsOneWidget);

    // 1 for clearing the search bar.
    expect(find.byIcon(Icons.close), findsNWidgets(1));
  });
}
