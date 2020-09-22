import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitListener extends Mock implements EntityListener<Bait> {}
class MockCatchManager extends Mock implements CatchManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockDataManager dataManager;
  BaitManager baitManager;
  BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = MockAppManager();

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);

    baitCategoryManager = BaitCategoryManager(appManager);
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager);
  });

  test("When a bait category is deleted, existing baits are updated", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    MockBaitListener baitListener = MockBaitListener();
    when(baitListener.onDelete).thenReturn((_) { });
    when(baitListener.onAddOrUpdate).thenReturn(() { });
    baitManager.addListener(baitListener);

    // Add a BaitCategory.
    Id baitCategoryId0 = randomId();
    BaitCategory category = BaitCategory()
      ..id = baitCategoryId0
      ..name = "Rapala";
    await baitCategoryManager.addOrUpdate(category);

    // Add a couple Baits that use the new category.
    Id baitId0 = randomId();
    Id baitId1 = randomId();
    await baitManager.addOrUpdate(Bait()
      ..id = baitId0
      ..name = "Test Bait"
      ..baitCategoryId = baitCategoryId0);
    await baitManager.addOrUpdate(Bait()
      ..id = baitId1
      ..name = "Test Bait 2"
      ..baitCategoryId = baitCategoryId0);
    verify(baitListener.onAddOrUpdate).called(2);
    expect(baitManager.entity(baitId0).baitCategoryId, baitCategoryId0);
    expect(baitManager.entity(baitId1).baitCategoryId, baitCategoryId0);

    // Delete the bait category.
    await baitCategoryManager.delete(category.id);

    // Verify listeners are notified and memory cache updated.
    verify(baitListener.onAddOrUpdate).called(1);
    expect(baitManager.entity(baitId0).hasBaitCategoryId(), false);
    expect(baitManager.entity(baitId1).hasBaitCategoryId(), false);
  });

  test("Number of catches", () {
    Id speciesId0 = randomId();

    Id baitId0 = randomId();
    Id baitId1 = randomId();
    Id baitId2 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0
        ..baitId = baitId0,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0
        ..baitId = baitId1,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0
        ..baitId = baitId2,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0
        ..baitId = baitId0,
      Catch()
        ..id = randomId()
        ..timestamp = timestampFromMillis(0)
        ..speciesId = speciesId0,
    ]);

    expect(baitManager.numberOfCatches(null), 0);
    expect(baitManager.numberOfCatches(Bait()..id = baitId0), 2);
    expect(baitManager.numberOfCatches(Bait()..id = baitId1), 1);
    expect(baitManager.numberOfCatches(Bait()..id = baitId2), 1);
  });

  test("Format bait name", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id baitCategoryId0 = randomId();
    await baitCategoryManager.addOrUpdate(BaitCategory()
      ..id = baitCategoryId0
      ..name = "Test Category");

    expect(baitManager.formatNameWithCategory(null), null);
    expect(baitManager.formatNameWithCategory(Bait()
      ..name = "Test"
      ..baitCategoryId = baitCategoryId0), "Test Category - Test");
    expect(baitManager.formatNameWithCategory(Bait()..name = "Test"), "Test");
  });

  test("Filtering", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    Id baitId0 = randomId();
    Id baitId1 = randomId();

    expect(baitManager.matchesFilter(baitId0, ""), false);

    await baitManager.addOrUpdate(Bait()
      ..id = baitId1
      ..name = "Rapala");
    expect(baitManager.matchesFilter(baitId1, ""), true);
    expect(baitManager.matchesFilter(baitId1, null), true);
    expect(baitManager.matchesFilter(baitId1, "Cut Bait"), false);
    expect(baitManager.matchesFilter(baitId1, "RAP"), true);

    // TODO: Test filter with and without baitCategoryId
    // TODO: Test filter with and without customEntityValues
  });

  // TODO: Test duplicate
}