import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;
  MockAssetPathEntity allAlbum;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockCustomEntityManager: true,
      mockDataManager: true,
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
      mockPhotoManagerWrapper: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockFishingSpotManager.listSortedByName()).thenReturn([]);

    var mockAssets = [
      createMockAssetEntity(
        fileName: "android_logo.png",
        latLngLegacy: LatLng()
          ..latitude = 1.234567
          ..longitude = 7.654321,
        latLngAsync: LatLng()
          ..latitude = 1.234567
          ..longitude = 7.654321,
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
    when(appManager.mockPhotoManagerWrapper.getAllAssetPathEntity(any))
        .thenAnswer((_) => Future.value(allAlbum));

    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.mockPreferencesManager.catchFieldIds).thenReturn([
      catchFieldIdFishingSpot(),
    ]);

    when(appManager.mockSpeciesManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn([
      Species()
        ..id = randomId()
        ..name = "Steelhead"
    ]);
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
    when(appManager.mockFishingSpotManager.withinRadius(any, any))
        .thenReturn(fishingSpot);
    when(appManager.mockFishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);
    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    verify(appManager.mockFishingSpotManager.withinRadius(any, any)).called(1);

    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(FishingSpotPickerPage), findsNothing);
    expect(find.byType(SaveCatchPage), findsOneWidget);
    expect(find.text("Spot 1"), findsOneWidget);
    expect(find.text("Lat: 9.876543, Lng: 3.456789"), findsOneWidget);
  });

  testWidgets("Picked image uses location data to create new fishing spot",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).first);
    await tapAndSettle(tester, find.text("NEXT"));

    verify(appManager.mockFishingSpotManager.withinRadius(any, any)).called(1);

    var result =
        verify(appManager.mockFishingSpotManager.addOrUpdate(captureAny));
    result.called(1);
    var fishingSpot = result.captured.first as FishingSpot;
    when(appManager.mockFishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);

    await tapAndSettle(tester, find.text("Steelhead"));

    expect(find.byType(FishingSpotPickerPage), findsNothing);
    expect(find.byType(SaveCatchPage), findsOneWidget);
    expect(find.text("Lat: 1.234567, Lng: 7.654321"), findsOneWidget);
  });

  testWidgets("Picked image without location data shows fishing spot picker",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byType(Image).at(1));
    await tapAndSettle(tester, find.text("NEXT"));

    verifyNever(appManager.mockFishingSpotManager.withinRadius(any, any));

    await tapAndSettle(tester, find.text("Steelhead"));
    expect(find.byType(FishingSpotPickerPage), findsOneWidget);
    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);

    // TODO: Can't test any further; GoogleMap doesn't yet support gestures.
  });

  testWidgets("Saving catch pops entire journey", (tester) async {
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
    when(appManager.mockPreferencesManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp(),
      catchFieldIdSpecies(),
    ]);

    await tester.pumpWidget(Testable(
      (_) => AddCatchJourney(),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("NEXT"));
    await tapAndSettle(tester, find.text("Steelhead"));

    expect(findFirst<SaveCatchPage>(tester).fishingSpotId, isNull);
    expect(find.text("Fishing Spot"), findsNothing);
  });
}
