import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as map;
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late StubbedMapController mapController;
  late MockAssetPathEntity allAlbum;

  setUp(() async {
    managers = await StubbedManagers.create();
    mapController = StubbedMapController();

    when(managers.anglerManager.entityExists(any)).thenReturn(false);

    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);

    when(
      managers.catchManager.addOrUpdate(
        any,
        imageFiles: anyNamed("imageFiles"),
      ),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.catchManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(
      managers.gpsTrailManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.fishingSpotManager.listSortedByDisplayName(any),
    ).thenReturn([]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);
    when(
      managers.fishingSpotManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(false));

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.propertiesManager.mapboxApiKey).thenReturn("");

    var mockAssets = [
      createMockAssetEntity(
        fileName: "android_logo.png",
        latLngLegacy: const LatLng(latitude: 1.234567, longitude: 7.654321),
        latLngAsync: const LatLng(latitude: 1.234567, longitude: 7.654321),
        dateTime: dateTime(2020, 4, 1),
      ),
      createMockAssetEntity(
        fileName: "anglers_log_logo.png",
        dateTime: dateTime(2020, 3, 1),
      ),
      createMockAssetEntity(
        fileName: "apple_logo.png",
        dateTime: dateTime(2020, 2, 1),
      ),
      createMockAssetEntity(
        fileName: "flutter_logo.png",
        dateTime: dateTime(2020, 1, 1),
      ),
    ];
    allAlbum = MockAssetPathEntity();
    when(
      allAlbum.assetCountAsync,
    ).thenAnswer((_) => Future.value(mockAssets.length));
    when(
      allAlbum.getAssetListPaged(
        page: anyNamed("page"),
        size: anyNamed("size"),
      ),
    ).thenAnswer((_) => Future.value(mockAssets));
    when(
      managers.permissionHandlerWrapper.requestPhotos(),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.photoManagerWrapper.getAllAssetPathEntity(any),
    ).thenAnswer((_) => Future.value(allAlbum));

    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.mapType).thenReturn(null);
    when(managers.userPreferenceManager.isTrackingImages).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.didRateApp).thenReturn(true);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);

    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(
      managers.speciesManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([species]);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);
    when(managers.speciesManager.entity(any)).thenReturn(species);
    when(
      managers.speciesManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);

    when(
      mapController.value.cameraPosition,
    ).thenReturn(const map.CameraPosition(target: map.LatLng(0, 0)));

    var exif = MockExif();
    when(exif.getLatLong()).thenAnswer((_) => Future.value(null));
    when(exif.getOriginalDate()).thenAnswer((_) => Future.value(null));
    when(
      managers.exifWrapper.fromPath(any),
    ).thenAnswer((_) => Future.value(exif));
  });

  testWidgets(
    "Picked image uses location data to fetch existing fishing spot",
    (tester) async {
      await showPresentedWidget(
        tester,
        (context) => present(context, const AddCatchJourney()),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot 1"
        ..lat = 9.876543
        ..lng = 3.456789;
      when(
        managers.fishingSpotManager.withinPreferenceRadius(any),
      ).thenReturn(fishingSpot);
      when(
        managers.fishingSpotManager.entity(fishingSpot.id),
      ).thenReturn(fishingSpot);
      when(
        managers.fishingSpotManager.entityExists(fishingSpot.id),
      ).thenReturn(true);
      await tapAndSettle(tester, find.byType(Image).first);
      await tapAndSettle(tester, find.text("NEXT"));

      verify(managers.fishingSpotManager.withinPreferenceRadius(any)).called(1);

      await tapAndSettle(tester, find.text("Steelhead"));

      expect(find.byType(FishingSpotMap), findsNothing);
      expect(find.byType(SaveCatchPage), findsOneWidget);
      expect(find.text("Spot 1"), findsOneWidget);
      expect(find.text("Lat: 9.876543, Lng: 3.456789"), findsOneWidget);
    },
  );

  testWidgets("Picked image uses location data to create new fishing spot", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Select first photo.
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    // Select species.
    await tapAndSettle(tester, find.text("Steelhead"));
    expect(find.byType(FishingSpotMap), findsOneWidget);

    await mapController.finishLoading(tester);
    expect(
      findFirstWithText<ActionButton>(tester, "NEXT").onPressed,
      isNotNull,
    );
    await tapAndSettle(tester, find.text("NEXT"));

    var saveCatchPage = findFirst<SaveCatchPage>(tester);
    expect(saveCatchPage.fishingSpot, isNotNull);
    expect(
      saveCatchPage.fishingSpot!.lat.toStringAsFixed(6),
      1.234567.toStringAsFixed(6),
    );
    expect(
      saveCatchPage.fishingSpot!.lng.toStringAsFixed(6),
      7.654321.toStringAsFixed(6),
    );
  });

  testWidgets("Picked image without location data shows fishing spot picker", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).at(1));
    await tapAndSettle(tester, find.text("NEXT"));

    verifyNever(managers.fishingSpotManager.withinPreferenceRadius(any));

    await tapAndSettle(tester, find.text("Steelhead"));
    await mapController.finishLoading(tester);

    expect(find.byType(FishingSpotMap), findsOneWidget);
    expect(
      findFirstWithText<ActionButton>(tester, "NEXT").onPressed,
      isNotNull,
    );
  });

  testWidgets("Saving catch pops entire journey", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));
    await tapAndSettle(tester, find.text("SAVE"));

    expect(find.byType(SaveCatchPage), findsNothing);
    expect(find.byType(FishingSpotMap), findsNothing);
    expect(find.byType(SpeciesListPage), findsNothing);
    expect(find.byType(ImagePickerPage), findsNothing);
  });

  testWidgets("Fishing spot is skipped when not tracking fishing spots", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdTimestamp, catchFieldIdSpecies]);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(false);
    when(managers.userPreferenceManager.isTrackingImages).thenReturn(false);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Steelhead"));

    expect(findFirst<SaveCatchPage>(tester).fishingSpot, isNull);
    expect(find.text("Fishing Spot"), findsNothing);
  });

  testWidgets("Fishing spot is skipped when spot already exists", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(SaveCatchPage), findsOneWidget);
  });

  testWidgets("Photo location is skipped when fishing spot is pre-picked", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.entity(any)).thenReturn(
      FishingSpot()
        ..id = randomId()
        ..name = "Test",
    );

    await showPresentedWidget(
      tester,
      (context) => present(
        context,
        AddCatchJourney(
          fishingSpot: managers.fishingSpotManager.entity(randomId()),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(SaveCatchPage), findsOneWidget);
    verifyNever(managers.fishingSpotManager.withinPreferenceRadius(any));
  });

  testWidgets("Fishing spot is not skipped when preferences is empty", (
    tester,
  ) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));
    await mapController.finishLoading(tester);

    expect(find.byType(FishingSpotMap), findsOneWidget);
  });

  testWidgets("Image picker is skipped when not tracking images", (
    tester,
  ) async {
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdTimestamp, catchFieldIdSpecies]);
    when(managers.userPreferenceManager.isTrackingImages).thenReturn(false);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImagePickerPage), findsNothing);
    expect(find.byType(SpeciesListPage), findsOneWidget);

    // Ensure a close button is still shown.
    // 1 for closing the journey, 1 for clearing the search bar.
    expect(find.byIcon(Icons.close), findsNWidgets(2));
  });

  testWidgets("Image picker is not skipped when preferences is empty", (
    tester,
  ) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);

    await showPresentedWidget(
      tester,
      (context) => present(context, const AddCatchJourney()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
