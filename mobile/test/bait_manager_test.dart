import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}
class MockBaitListener extends Mock implements EntityListener<Bait> {}

void main() {
  MockAppManager appManager;
  MockDataManager dataManager;
  BaitManager baitManager;
  BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = MockAppManager();

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);

    baitCategoryManager = BaitCategoryManager.get(appManager);
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager.get(appManager);
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

    // BaitManager onDelete callback is async; wait to finish.
    await Future.delayed(Duration(milliseconds: 500), () {
      // Verify listeners are notified and memory cache updated.
      verify(dataManager.rawUpdate(any, any)).called(1);
      verify(baitListener.onAddOrUpdate).called(1);
      expect(baitManager.entity(id: "bait_id").categoryId, isNull);
      expect(baitManager.entity(id: "bait_id_2").categoryId, isNull);
    });
  });
}