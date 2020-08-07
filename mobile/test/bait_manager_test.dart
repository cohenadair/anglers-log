import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/catch.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitListener extends Mock implements EntityListener<Bait> {}
class MockCustomEntityValueManager extends Mock
    implements CustomEntityValueManager {}
class MockCatchManager extends Mock implements CatchManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockCatchManager catchManager;
  MockCustomEntityValueManager entityValueManager;
  MockDataManager dataManager;
  BaitManager baitManager;
  BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = MockAppManager();

    catchManager = MockCatchManager();
    when(appManager.catchManager).thenReturn(catchManager);

    entityValueManager = MockCustomEntityValueManager();
    when(appManager.customEntityValueManager).thenReturn(entityValueManager);
    when(entityValueManager.setValues(any, any)).thenAnswer((_) =>
        Future.value());

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);

    baitCategoryManager = BaitCategoryManager(appManager);
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager);
  });

  test("When a bait category is deleted, existing baits are updated", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockBaitListener baitListener = MockBaitListener();
    when(baitListener.onDelete).thenReturn((_) { });
    when(baitListener.onAddOrUpdate).thenReturn(() { });
    baitManager.addListener(baitListener);

    BaitCategory category = BaitCategory(id: "category_id", name: "Rapala");
    await baitCategoryManager.addOrUpdate(category);

    // Stub database has nothing to update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(false));

    // Verify listeners aren't notified.
    await baitCategoryManager.delete(category);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);
    verifyNever(baitListener.onAddOrUpdate);

    // Stub database does an update.
    when(dataManager.rawUpdate(any, any))
        .thenAnswer((_) => Future.value(true));

    await baitCategoryManager.addOrUpdate(category);
    await baitManager.addOrUpdate(Bait(
      id: "bait_id",
      name: "Test Bait",
      categoryId: "category_id",
    ));
    await baitManager.addOrUpdate(Bait(
      id: "bait_id_2",
      name: "Test Bait 2",
      categoryId: "category_id",
    ));
    verify(baitListener.onAddOrUpdate).called(2);
    expect(baitManager.entity(id: "bait_id").categoryId, "category_id");
    expect(baitManager.entity(id: "bait_id_2").categoryId, "category_id");

    await baitCategoryManager.delete(category);
    await untilCalled(dataManager.rawUpdate(any, any));
    verify(dataManager.rawUpdate(any, any)).called(1);

    // Verify listeners are notified and memory cache updated.
    verify(baitListener.onAddOrUpdate).called(1);
    expect(baitManager.entity(id: "bait_id").categoryId, isNull);
    expect(baitManager.entity(id: "bait_id_2").categoryId, isNull);
  });

  test("Number of catches", () {
    when(catchManager.entityList).thenReturn([
      Catch(timestamp: 0, speciesId: "species_1", baitId: "bait_1"),
      Catch(timestamp: 0, speciesId: "species_1", baitId: "bait_5"),
      Catch(timestamp: 0, speciesId: "species_1", baitId: "bait_4"),
      Catch(timestamp: 0, speciesId: "species_1", baitId: "bait_1"),
      Catch(timestamp: 0, speciesId: "species_1"),
    ]);

    expect(baitManager.numberOfCatches(null), 0);
    expect(baitManager.numberOfCatches(Bait(name: "Bait 1", id: "bait_1")), 2);
    expect(baitManager.numberOfCatches(Bait(name: "Bait 1", id: "bait_4")), 1);
    expect(baitManager.numberOfCatches(Bait(name: "Bait 1", id: "bait_5")), 1);
  });

  test("Format bait name", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    await baitCategoryManager.addOrUpdate(
        BaitCategory(name: "Test Category", id: "category_id"));

    expect(baitManager.formatNameWithCategory(null), null);
    expect(baitManager.formatNameWithCategory(
        Bait(name: "Test", categoryId: "category_id")), "Test Category - Test");
    expect(baitManager.formatNameWithCategory(Bait(name: "Test")), "Test");
  });

  test("Filtering", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    expect(baitManager.matchesFilter("invalid_id", ""), false);

    await baitManager.addOrUpdate(Bait(id: "id", name: "Rapala"));
    expect(baitManager.matchesFilter("id", ""), true);
    expect(baitManager.matchesFilter("id", null), true);
    expect(baitManager.matchesFilter("id", "Cut Bait"), false);
    expect(baitManager.matchesFilter("id", "RAP"), true);
  });
}