import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBaitManager extends Mock implements BaitManager {}
class MockDataManager extends Mock implements DataManager {}

void main() {
  MockAppManager appManager;
  MockBaitManager baitManager;
  MockDataManager dataManager;

  BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = MockAppManager();

    baitManager = MockBaitManager();
    when(appManager.baitManager).thenReturn(baitManager);

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.addListener(any)).thenAnswer((_) {});

    baitCategoryManager = BaitCategoryManager(appManager);
  });

  test("Number of baits", () {
    when(baitManager.entityList).thenReturn([
      Bait(name: "Bait 1", categoryId: "category_1"),
      Bait(name: "Bait 1", categoryId: "category_5"),
      Bait(name: "Bait 1", categoryId: "category_4"),
      Bait(name: "Bait 1", categoryId: "category_1"),
      Bait(name: "Bait 1"),
    ]);

    expect(baitCategoryManager.numberOfBaits(null), 0);
    expect(baitCategoryManager.numberOfBaits(
        BaitCategory(name: "Category 1", id: "category_1")), 2);
    expect(baitCategoryManager.numberOfBaits(
        BaitCategory(name: "Category 1", id: "category_5")), 1);
    expect(baitCategoryManager.numberOfBaits(
        BaitCategory(name: "Category 1", id: "category_4")), 1);
  });
}