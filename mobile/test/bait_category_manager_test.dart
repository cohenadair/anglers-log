import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

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
    Id baitCategoryId0 = randomId();
    Id baitCategoryId1 = randomId();
    Id baitCategoryId2 = randomId();
    Id baitCategoryId3 = randomId();

    when(baitManager.list()).thenReturn([
      Bait()
        ..id = randomId()
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId0,
      Bait()
        ..id = randomId()
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId1,
      Bait()
        ..id = randomId()
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId2,
      Bait()
        ..id = randomId()
        ..name = "Bait 2"
        ..baitCategoryId = baitCategoryId0,
      Bait()
        ..id = randomId()
        ..name = "Bait 1"
        ..baitCategoryId = baitCategoryId3,
      Bait()
        ..id = randomId()
        ..name = "Bait 1",
    ]);

    expect(baitCategoryManager.numberOfBaits(null), 0);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId0), 2);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId1), 1);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId2), 1);
    expect(baitCategoryManager.numberOfBaits(baitCategoryId3), 1);
  });

  group("deleteMessage", () {
    testWidgets("Invalid input", (WidgetTester tester) async {
      expect(() => baitCategoryManager.deleteMessage(null, BaitCategory()
        ..id = randomId()
        ..name = "Live"), throwsAssertionError);

      BuildContext context = await buildContext(tester);
      expect(() => baitCategoryManager.deleteMessage(context, null),
          throwsAssertionError);
    });

    testWidgets("Singular", (WidgetTester tester) async {
      BaitCategory category = BaitCategory()
        ..id = randomId()
        ..name = "Live";

      when(baitManager.list()).thenReturn([
        Bait()
          ..id = randomId()
          ..name = "Bait 1"
          ..baitCategoryId = category.id,
      ]);

      BuildContext context = await buildContext(tester);
      expect(baitCategoryManager.deleteMessage(context, category),
          "Live is associated with 1 bait; are you sure you want to delete it? "
              "This cannot be undone.");
    });

    testWidgets("Plural zero", (WidgetTester tester) async {
      BaitCategory category = BaitCategory()
        ..id = randomId()
        ..name = "Live";
      when(baitManager.list()).thenReturn([]);

      BuildContext context = await buildContext(tester);
      expect(baitCategoryManager.deleteMessage(context, category),
          "Live is associated with 0 baits; are you sure you want to delete it?"
              " This cannot be undone.");
    });

    testWidgets("Plural not zero", (WidgetTester tester) async {
      BaitCategory category = BaitCategory()
        ..id = randomId()
        ..name = "Live";
      when(baitManager.list()).thenReturn([
        Bait()
          ..id = randomId()
          ..name = "Bait 1"
          ..baitCategoryId = category.id,
        Bait()
          ..id = randomId()
          ..name = "Bait 2"
          ..baitCategoryId = category.id,
      ]);

      BuildContext context = await buildContext(tester);
      expect(baitCategoryManager.deleteMessage(context, category),
          "Live is associated with 2 baits; are you sure you want to delete it?"
              " This cannot be undone.");
    });
  });
}