import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
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
    Id baitCategoryId0 = Id.random();
    Id baitCategoryId1 = Id.random();
    Id baitCategoryId2 = Id.random();
    Id baitCategoryId3 = Id.random();

    when(baitManager.list()).thenReturn([
      Bait()
        ..id = Id.random().bytes
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId0.bytes,
      Bait()
        ..id = Id.random().bytes
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId1.bytes,
      Bait()
        ..id = Id.random().bytes
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId2.bytes,
      Bait()
        ..id = Id.random().bytes
        ..name = "Bait 2"
        ..baitCategoryId = baitCategoryId0.bytes,
      Bait()
        ..id = Id.random().bytes
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId3.bytes,
    ]);

    expect(baitCategoryManager.numberOfBaits(null), 0);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId0), 2);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId1), 1);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId2), 1);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId3), 1);

    // TODO: Test Bait with no baitCategoryId
  });
}