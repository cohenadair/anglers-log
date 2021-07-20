import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;
  late MockCustomEntityManager customEntityManager;
  late MockLocalDatabaseManager dataManager;

  late BaitManager baitManager;
  late BaitCategoryManager baitCategoryManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    catchManager = appManager.catchManager;

    customEntityManager = appManager.customEntityManager;
    when(customEntityManager.matchesFilter(any, any)).thenReturn(true);

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    baitCategoryManager = BaitCategoryManager(appManager.app);
    when(appManager.app.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager.app);
  });

  test("When a bait category is deleted, existing baits are updated", () async {
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.replaceRows(any, any)).thenAnswer((_) => Future.value());

    var baitListener = MockEntityListener<Bait>();
    when(baitListener.onAdd).thenReturn((_) {});
    when(baitListener.onDelete).thenReturn((_) {});

    var updatedBaits = <Bait>[];
    when(baitListener.onUpdate).thenReturn((bait) => updatedBaits.add(bait));
    baitManager.addListener(baitListener);

    // Add a BaitCategory.
    var baitCategoryId0 = randomId();
    var category = BaitCategory()
      ..id = baitCategoryId0
      ..name = "Rapala";
    await baitCategoryManager.addOrUpdate(category);

    // Add a couple Baits that use the new category.
    var baitId0 = randomId();
    var baitId1 = randomId();
    await baitManager.addOrUpdate(Bait()
      ..id = baitId0
      ..name = "Test Bait"
      ..baitCategoryId = baitCategoryId0);
    await baitManager.addOrUpdate(Bait()
      ..id = baitId1
      ..name = "Test Bait 2"
      ..baitCategoryId = baitCategoryId0);
    verify(baitListener.onAdd).called(2);
    expect(baitManager.entity(baitId0)!.baitCategoryId, baitCategoryId0);
    expect(baitManager.entity(baitId1)!.baitCategoryId, baitCategoryId0);

    // Delete the bait category.
    await baitCategoryManager.delete(category.id);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(Duration(milliseconds: 50));

    // Verify listeners are notified and memory cache updated.
    verify(baitListener.onUpdate).called(2);
    expect(baitManager.entity(baitId0)!.hasBaitCategoryId(), false);
    expect(baitManager.entity(baitId1)!.hasBaitCategoryId(), false);
    expect(updatedBaits.length, 2);
  });

  test("Number of catches", () {
    var speciesId0 = randomId();

    var baitId0 = randomId();
    var baitId1 = randomId();
    var baitId2 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baitIds.add(baitId0),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baitIds.add(baitId1),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baitIds.add(baitId2),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baitIds.add(baitId0),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
    ]);

    expect(baitManager.numberOfCatches(null), 0);
    expect(baitManager.numberOfCatches(baitId0), 2);
    expect(baitManager.numberOfCatches(baitId1), 1);
    expect(baitManager.numberOfCatches(baitId2), 1);
  });

  test("Format bait name", () async {
    var baitCategoryId0 = randomId();
    await baitCategoryManager.addOrUpdate(BaitCategory()
      ..id = baitCategoryId0
      ..name = "Test Category");

    var bait = Bait()
      ..id = randomId()
      ..name = "Test"
      ..baitCategoryId = baitCategoryId0;
    await baitManager.addOrUpdate(bait);

    expect(baitManager.formatNameWithCategory(null), null);
    expect(
      baitManager.formatNameWithCategory(bait.id),
      "Test Category - Test",
    );

    bait = Bait()
      ..id = randomId()
      ..name = "Test";
    await baitManager.addOrUpdate(bait);
    expect(baitManager.formatNameWithCategory(bait.id), "Test");
  });

  test("Filtering", () async {
    var baitId0 = randomId();
    var baitId1 = randomId();

    expect(baitManager.matchesFilter(baitId0, ""), false);

    var bait = Bait()
      ..id = baitId1
      ..name = "Rapala";

    await baitManager.addOrUpdate(bait);
    expect(baitManager.matchesFilter(baitId1, ""), true);
    expect(baitManager.matchesFilter(baitId1, null), true);
    expect(baitManager.matchesFilter(baitId1, "Cut Bait"), false);
    expect(baitManager.matchesFilter(baitId1, "RAP"), true);

    // Bait category
    var category = BaitCategory()
      ..id = randomId()
      ..name = "Bugger";
    await baitCategoryManager.addOrUpdate(category);
    bait.baitCategoryId = category.id;
    await baitManager.addOrUpdate(bait);
    expect(baitManager.matchesFilter(baitId1, "Bug"), true);

    // Custom entity values
    bait.customEntityValues.add(CustomEntityValue()
      ..customEntityId = randomId()
      ..value = "Test");
    await baitManager.addOrUpdate(bait);
    expect(baitManager.matchesFilter(baitId1, "Test"), true);
  });

  group("duplicate", () {
    test("false if bait does not exist", () {
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Rapala"),
        isFalse,
      );
    });

    test("false if bait category IDs differ", () async {
      await baitManager.addOrUpdate(Bait()
        ..id = randomId()
        ..name = "Rapala"
        ..baitCategoryId = randomId());
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Rapala"
          ..baitCategoryId = randomId()),
        isFalse,
      );
    });

    test("false if bait category ID is null", () async {
      await baitManager.addOrUpdate(Bait()
        ..id = randomId()
        ..name = "Rapala");
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Rapala"
          ..baitCategoryId = randomId()),
        isFalse,
      );
    });

    test("false if names differ", () async {
      await baitManager.addOrUpdate(Bait()
        ..id = randomId()
        ..name = "Rapala");
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Bugger"),
        isFalse,
      );
    });

    test("false if custom entity values differ", () async {
      await baitManager.addOrUpdate(Bait()
        ..id = randomId()
        ..name = "Rapala");
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Bugger"),
        isFalse,
      );
    });

    test("false if IDs are equal", () async {
      var id = randomId();
      await baitManager.addOrUpdate(Bait()
        ..id = id
        ..name = "Rapala");
      expect(
        baitManager.duplicate(Bait()
          ..id = id
          ..name = "Rapala"),
        isFalse,
      );
    });

    test("true with all properties", () async {
      var value = CustomEntityValue()
        ..customEntityId = randomId()
        ..value = "10";
      var categoryId = randomId();

      var bait1 = Bait()
        ..id = randomId()
        ..name = "Rapala"
        ..baitCategoryId = categoryId;
      bait1.customEntityValues.add(value);

      var bait2 = Bait()
        ..id = randomId()
        ..name = "Rapala"
        ..baitCategoryId = categoryId;
      bait2.customEntityValues
          .add(CustomEntityValue.fromBuffer(value.writeToBuffer()));

      await baitManager.addOrUpdate(bait1);
      expect(baitManager.duplicate(bait2), isTrue);
    });

    test("true with no bait category ID", () async {
      await baitManager.addOrUpdate(Bait()
        ..id = randomId()
        ..name = "Rapala");
      expect(
        baitManager.duplicate(Bait()
          ..id = randomId()
          ..name = "Rapala"),
        isTrue,
      );
    });
  });

  group("deleteMessage", () {
    testWidgets("Singular", (tester) async {
      var bait = Bait()
        ..id = randomId()
        ..name = "Worm";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..baitIds.add(bait.id),
      ]);

      var context = await buildContext(tester);
      expect(
        baitManager.deleteMessage(context, bait),
        "Worm is associated with 1 catch; are you sure you want to delete it?"
        " This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var bait = Bait()
        ..id = randomId()
        ..name = "Worm";

      when(catchManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        baitManager.deleteMessage(context, bait),
        "Worm is associated with 0 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("Plural none zero", (tester) async {
      var bait = Bait()
        ..id = randomId()
        ..name = "Worm";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(0)
          ..speciesId = randomId()
          ..baitIds.add(bait.id),
        Catch()
          ..id = randomId()
          ..timestamp = Int64(5)
          ..speciesId = randomId()
          ..baitIds.add(bait.id),
      ]);

      var context = await buildContext(tester);
      expect(
        baitManager.deleteMessage(context, bait),
        "Worm is associated with 2 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("With bait category", (tester) async {
      var category = BaitCategory()
        ..id = randomId()
        ..name = "Live";
      baitCategoryManager.addOrUpdate(category);

      var bait = Bait()
        ..id = randomId()
        ..name = "Worm"
        ..baitCategoryId = category.id;
      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..timestamp = Int64(5)
          ..speciesId = randomId()
          ..baitIds.add(bait.id),
      ]);

      var context = await buildContext(tester);
      expect(
        baitManager.deleteMessage(context, bait),
        "Worm (Live) is associated with 1 catch; are you sure you want to "
        "delete it? This cannot be undone.",
      );
    });
  });
}
