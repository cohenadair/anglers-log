import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockDataManager extends Mock implements DataManager {}
class MockCatchListener extends Mock implements EntityListener<Catch> {}

void main() {
  MockAppManager appManager;
  MockBaitCategoryManager baitCategoryManager;
  MockDataManager dataManager;
  BaitManager baitManager;
  FishingSpotManager fishingSpotManager;
  CatchManager catchManager;

  setUp(() {
    appManager = MockAppManager();

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);

    baitCategoryManager = MockBaitCategoryManager();
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);

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
}