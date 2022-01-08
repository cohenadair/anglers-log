import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockBaitManager baitManager;

  late BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = StubbedAppManager();

    baitManager = appManager.baitManager;

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    baitCategoryManager = BaitCategoryManager(appManager.app);
  });

  test("Number of baits", () {
    var baitCategoryId0 = randomId();
    var baitCategoryId1 = randomId();
    var baitCategoryId2 = randomId();
    var baitCategoryId3 = randomId();

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
    testWidgets("Singular", (tester) async {
      var category = BaitCategory()
        ..id = randomId()
        ..name = "Live";

      when(baitManager.list()).thenReturn([
        Bait()
          ..id = randomId()
          ..name = "Bait 1"
          ..baitCategoryId = category.id,
      ]);

      var context = await buildContext(tester);
      expect(
        baitCategoryManager.deleteMessage(context, category),
        "Live is associated with 1 bait; are you sure you want to delete it? "
        "This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var category = BaitCategory()
        ..id = randomId()
        ..name = "Live";
      when(baitManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        baitCategoryManager.deleteMessage(context, category),
        "Live is associated with 0 baits; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });

    testWidgets("Plural not zero", (tester) async {
      var category = BaitCategory()
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

      var context = await buildContext(tester);
      expect(
        baitCategoryManager.deleteMessage(context, category),
        "Live is associated with 2 baits; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });
  });
}
