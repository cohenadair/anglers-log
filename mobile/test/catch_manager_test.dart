import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockCatchListener extends Mock implements EntityListener<Catch> {}
class MockDataManager extends Mock implements DataManager {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockImageManager extends Mock implements ImageManager {}
class MockSpeciesManager extends Mock implements SpeciesManager {}

void main() {
  MockAppManager appManager;
  MockBaitCategoryManager baitCategoryManager;
  MockDataManager dataManager;
  MockImageManager imageManager;
  MockSpeciesManager speciesManager;
  BaitManager baitManager;
  CatchManager catchManager;
  FishingSpotManager fishingSpotManager;

  setUp(() {
    appManager = MockAppManager();

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);

    baitCategoryManager = MockBaitCategoryManager();
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    imageManager = MockImageManager();
    when(appManager.imageManager).thenReturn(imageManager);
    when(imageManager.save(any, any)).thenAnswer((realInvocation) => null);

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);
    
    speciesManager = MockSpeciesManager();
    when(appManager.speciesManager).thenReturn(speciesManager);

    catchManager = CatchManager(appManager);
  });

  test("When a bait is deleted, existing catches are updated", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) { });
    when(catchListener.onAddOrUpdate).thenReturn(() { });
    catchManager.addListener(catchListener);

    Bait bait = Bait(id: "bait_id", name: "Rapala");
    await baitManager.addOrUpdate(bait);

    // Stub database has nothing to update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(false));

    // Verify listeners aren't notified.
    await baitManager.delete(bait);
    verify(dataManager.rawUpdate(any, any)).called(1);
    verifyNever(catchListener.onAddOrUpdate);

    // Stub database does an update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(true));

    await baitManager.addOrUpdate(bait);
    await catchManager.addOrUpdate(Catch(
      id: "catch_id",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "catch_id_2",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id_2",
    ));
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(id: "catch_id").baitId, "bait_id");
    expect(catchManager.entity(id: "catch_id_2").baitId, "bait_id");

    await baitManager.delete(bait);

    // CatchManager onDelete callback is async; wait to finish.
    await Future.delayed(Duration(milliseconds: 500), () {
      // Verify listeners are notified and memory cache updated.
      verify(dataManager.rawUpdate(any, any)).called(1);
      verify(catchListener.onAddOrUpdate).called(1);
      expect(catchManager.entity(id: "catch_id").baitId, isNull);
      expect(catchManager.entity(id: "catch_id_2").baitId, isNull);
    });
  });

  test("When a fishing spot is deleted, existing catches are updated", () async
  {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockCatchListener catchListener = MockCatchListener();
    when(catchListener.onDelete).thenReturn((_) { });
    when(catchListener.onAddOrUpdate).thenReturn(() { });
    catchManager.addListener(catchListener);

    FishingSpot fishingSpot = FishingSpot(
      id: "fishing_spot_id",
      lat: 0.0,
      lng: 0.0,
    );
    await fishingSpotManager.addOrUpdate(fishingSpot);

    // Stub database has nothing to update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(false));

    // Verify listeners aren't notified.
    await fishingSpotManager.delete(fishingSpot);
    verify(dataManager.rawUpdate(any, any)).called(1);
    verifyNever(catchListener.onAddOrUpdate);

    // Stub database does an update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(true));

    await fishingSpotManager.addOrUpdate(fishingSpot);
    await catchManager.addOrUpdate(Catch(
      id: "catch_id",
      timestamp: 5,
      baitId: "bait_id",
      speciesId: "species_id",
      fishingSpotId: "fishing_spot_id",
    ));
    await catchManager.addOrUpdate(Catch(
      id: "catch_id_2",
      timestamp: 5,
      baitId: "bait_id_2",
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_id",
    ));
    verify(catchListener.onAddOrUpdate).called(2);
    expect(catchManager.entity(id: "catch_id").fishingSpotId,
        "fishing_spot_id");
    expect(catchManager.entity(id: "catch_id_2").fishingSpotId,
        "fishing_spot_id");

    await fishingSpotManager.delete(fishingSpot);

    // CatchManager onDelete callback is async; wait to finish.
    await Future.delayed(Duration(milliseconds: 500), () {
      // Verify listeners are notified and memory cache updated.
      verify(dataManager.rawUpdate(any, any)).called(1);
      verify(catchListener.onAddOrUpdate).called(1);
      expect(catchManager.entity(id: "catch_id").fishingSpotId, isNull);
      expect(catchManager.entity(id: "catch_id_2").fishingSpotId, isNull);
    });
  });

  testWidgets("Filtering", (WidgetTester tester) async {
    var mockFishingSpotManager = MockFishingSpotManager();
    when(mockFishingSpotManager.addOrUpdate(any)).thenAnswer((_) => null);
    when(appManager.fishingSpotManager).thenReturn(mockFishingSpotManager);

    var mockBaitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(mockBaitManager);

    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      speciesId: "species_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 4, 4).millisecondsSinceEpoch,
      speciesId: "species_id_2",
    ));

    when(speciesManager.entity(id: argThat(equals("species_id_1"),
      named: "id",
    ))).thenReturn(Species(name: "Smallmouth Bass"));
    when(speciesManager.entity(id: argThat(equals("species_id_2"),
      named: "id",
    ))).thenReturn(Species(name: "Blue Catfish"));

    BuildContext context = await buildContext(tester);

    List<Catch> catches = catchManager.filteredCatches(context, "");
    expect(catches.length, 2);

    catches = catchManager.filteredCatches(context, "Bluegill");
    expect(true, catches.isEmpty);

    catches = catchManager.filteredCatches(context, "bass");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "BLUE");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "janua");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "april");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "4");
    expect(catches.length, 1);

    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 1, 1).millisecondsSinceEpoch,
      speciesId: "species_id_1",
      fishingSpotId: "fishing_spot_id_1",
      baitId: "bait_id_1",
    ));
    await catchManager.addOrUpdate(Catch(
      timestamp: DateTime(2020, 2, 2).millisecondsSinceEpoch,
      speciesId: "species_id_2",
      fishingSpotId: "fishing_spot_id_2",
      baitId: "bait_id_2",
    ));

    when(mockFishingSpotManager.entity(id: argThat(equals("fishing_spot_id_1"),
      named: "id",
    ))).thenReturn(FishingSpot(name: "Tennessee River", lat: 0.0, lng: 0.0));
    when(mockFishingSpotManager.entity(id: argThat(equals("fishing_spot_id_2"),
      named: "id",
    ))).thenReturn(FishingSpot(name: "9 Mile River", lat: 0.0, lng: 0.0));

    when(mockBaitManager.matchesFilter("bait_id_1", any)).thenReturn(false);

    when(mockBaitManager.matchesFilter(any, any)).thenReturn(true);
    catches = catchManager.filteredCatches(context, "RAP");
    expect(catches.length, 2);

    when(mockBaitManager.matchesFilter(any, any)).thenReturn(false);
    catches = catchManager.filteredCatches(context, "test");
    expect(true, catches.isEmpty);

    catches = catchManager.filteredCatches(context, "9 mile");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "Tennessee");
    expect(catches.length, 1);

    catches = catchManager.filteredCatches(context, "River");
    expect(catches.length, 2);
  });
}