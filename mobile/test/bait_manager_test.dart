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

    catchManager = appManager.catchManager;

    customEntityManager = appManager.customEntityManager;
    when(customEntityManager.matchesFilter(any, any, any)).thenReturn(true);
    when(customEntityManager.customValuesDisplayValue(any, any)).thenReturn("");

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
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
    baitManager.listen(baitListener);

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
    await untilCalled(baitListener.onAdd);
    await untilCalled(baitListener.onAdd);
    verify(baitListener.onAdd).called(2);
    expect(baitManager.entity(baitId0)!.baitCategoryId, baitCategoryId0);
    expect(baitManager.entity(baitId1)!.baitCategoryId, baitCategoryId0);

    // Delete the bait category.
    await baitCategoryManager.delete(category.id);

    // Wait for addOrUpdate calls to finish.
    await Future.delayed(const Duration(milliseconds: 50));

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

    var baitAttachment0 = BaitAttachment(baitId: baitId0);
    var baitAttachment1 = BaitAttachment(baitId: baitId1);
    var baitAttachment2 = BaitAttachment(baitId: baitId2);

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment0),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment1),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment2),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment0),
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

  test("Number of catches with quantity", () {
    var speciesId0 = randomId();

    var baitId0 = randomId();
    var baitId1 = randomId();
    var baitId2 = randomId();

    var baitAttachment0 = BaitAttachment(baitId: baitId0);
    var baitAttachment1 = BaitAttachment(baitId: baitId1);
    var baitAttachment2 = BaitAttachment(baitId: baitId2);

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment0)
        ..quantity = 3,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment1)
        ..quantity = 5,
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment2),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0
        ..baits.add(baitAttachment0),
      Catch()
        ..id = randomId()
        ..timestamp = Int64(0)
        ..speciesId = speciesId0,
    ]);

    expect(baitManager.numberOfCatchQuantities(null), 0);
    expect(baitManager.numberOfCatchQuantities(baitId0), 4);
    expect(baitManager.numberOfCatchQuantities(baitId1), 5);
    expect(baitManager.numberOfCatchQuantities(baitId2), 1);
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

  testWidgets("Filtering", (tester) async {
    var baitId0 = randomId();
    var baitId1 = randomId();

    var context = await buildContext(tester);
    expect(baitManager.matchesFilter(baitId0, context, ""), false);

    var bait = Bait()
      ..id = baitId1
      ..name = "Rapala"
      ..type = Bait_Type.artificial;

    await baitManager.addOrUpdate(bait);
    expect(baitManager.matchesFilter(baitId1, context, ""), true);
    expect(baitManager.matchesFilter(baitId1, context, null), true);
    expect(baitManager.matchesFilter(baitId1, context, "Cut Bait"), false);
    expect(baitManager.matchesFilter(baitId1, context, "RAP"), true);

    // Bait category
    var category = BaitCategory()
      ..id = randomId()
      ..name = "Bugger";
    await baitCategoryManager.addOrUpdate(category);
    bait.baitCategoryId = category.id;
    await baitManager.addOrUpdate(bait);
    expect(baitManager.matchesFilter(baitId1, context, "Bug"), true);

    // Type
    expect(baitManager.matchesFilter(baitId1, context, "artificial"), true);

    // Remove type
    await baitManager.addOrUpdate(Bait()
      ..id = baitId1
      ..name = "Rapala");
    expect(baitManager.matchesFilter(baitId1, context, "artificial"), false);
  });

  testWidgets("Filtering by bait variant", (tester) async {
    var baitId = randomId();
    var baitVariant = BaitVariant(
      baseId: baitId,
      color: "Red",
      modelNumber: "AB123",
      size: "Large",
      minDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      ),
      maxDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 20,
        ),
      ),
      description: "This is a test bait",
    );
    var bait = Bait()
      ..id = baitId
      ..name = "Rapala"
      ..variants.add(baitVariant);

    await baitManager.addOrUpdate(bait);

    var context = await buildContext(tester);
    expect(baitManager.matchesFilter(baitId, context, "lure"), false);
    expect(baitManager.matchesFilter(baitId, context, "red"), true);
    expect(baitManager.matchesFilter(baitId, context, "AB"), true);
    expect(baitManager.matchesFilter(baitId, context, "large"), true);
    expect(baitManager.matchesFilter(baitId, context, "10"), true);
    expect(baitManager.matchesFilter(baitId, context, "20"), true);
    expect(baitManager.matchesFilter(baitId, context, "test bait"), true);
  });

  testWidgets("Filtering by bait variant custom entity values", (tester) async {
    var baitId = randomId();
    var customEntityId = randomId();
    var baitVariant = BaitVariant(
      baseId: baitId,
      customEntityValues: [
        CustomEntityValue(
          customEntityId: customEntityId,
          // Value doesn't matter. CustomEntityManager is stubbed to always
          // return true.
          value: 10.toString(),
        ),
      ],
    );
    var bait = Bait()
      ..id = baitId
      ..name = "Rapala"
      ..variants.add(baitVariant);

    when(appManager.customEntityManager.matchesFilter(any, any, any))
        .thenReturn(true);

    await baitManager.addOrUpdate(bait);
    expect(
      baitManager.matchesFilter(baitId, await buildContext(tester), "10"),
      isTrue,
    );
  });

  testWidgets("attachmentsMatchesFilter", (tester) async {
    var id0 = randomId();
    var id1 = randomId();
    await baitManager.addOrUpdate(Bait()
      ..id = id0
      ..name = "Rapala");
    await baitManager.addOrUpdate(Bait()
      ..id = id1
      ..name = "Spoon");

    var context = await buildContext(tester);
    var attachments = <BaitAttachment>[
      BaitAttachment(baitId: id0),
      BaitAttachment(baitId: id1),
    ];

    expect(
      baitManager.attachmentsMatchesFilter(attachments, "Live", context),
      isFalse,
    );
    expect(
      baitManager.attachmentsMatchesFilter(attachments, "Spoon", context),
      isTrue,
    );
    expect(
      baitManager.attachmentsMatchesFilter(attachments, "Rapala", context),
      isTrue,
    );
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
      var categoryId = randomId();

      var bait1 = Bait()
        ..id = randomId()
        ..name = "Rapala"
        ..baitCategoryId = categoryId;

      var bait2 = Bait()
        ..id = randomId()
        ..name = "Rapala"
        ..baitCategoryId = categoryId;

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
          ..baits.add(BaitAttachment(baitId: bait.id)),
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
          ..baits.add(BaitAttachment(baitId: bait.id)),
        Catch()
          ..id = randomId()
          ..timestamp = Int64(5)
          ..speciesId = randomId()
          ..baits.add(BaitAttachment(baitId: bait.id)),
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
          ..baits.add(BaitAttachment(baitId: bait.id)),
      ]);

      var context = await buildContext(tester);
      expect(
        baitManager.deleteMessage(context, bait),
        "Worm (Live) is associated with 1 catch; are you sure you want to "
        "delete it? This cannot be undone.",
      );
    });
  });

  test("numberOfCatches", () {
    var baitId0 = randomId();
    var baitId1 = randomId();

    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(baitId: baitId0),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(baitId: baitId1),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(baitId: baitId0),
        ],
      ),
    ]);

    expect(baitManager.numberOfCatches(baitId0), 2);
    expect(baitManager.numberOfCatches(baitId1), 1);
    expect(baitManager.numberOfCatches(randomId()), 0);
  });

  test("numberOfVariantCatches", () {
    var baitId0 = randomId();
    var baitId1 = randomId();
    var variantId0 = randomId();
    var variantId1 = randomId();

    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId0,
            variantId: variantId0,
          ),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId1,
            variantId: variantId1,
          ),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId0,
            variantId: variantId0,
          ),
        ],
      ),
    ]);

    expect(baitManager.numberOfVariantCatches(variantId0), 2);
    expect(baitManager.numberOfVariantCatches(variantId1), 1);
    expect(baitManager.numberOfVariantCatches(randomId()), 0);
  });

  test("numberOfCustomEntityValues", () async {
    var customId0 = randomId();
    var customId1 = randomId();
    var customId2 = randomId();

    Bait bait(Id customId) {
      return Bait(
        id: randomId(),
        variants: [
          BaitVariant(
            baseId: randomId(),
            customEntityValues: [
              CustomEntityValue(
                customEntityId: customId,
              )
            ],
          ),
        ],
      );
    }

    var baits = <Bait>[
      Bait(id: randomId()),
      bait(customId0),
      Bait(id: randomId()),
      bait(customId2),
      bait(customId0),
      bait(customId1),
      Bait(
        id: randomId(),
        variants: [
          BaitVariant(),
          BaitVariant(),
        ],
      ),
      bait(customId0),
      bait(customId2),
      Bait(
        id: randomId(),
        variants: [
          BaitVariant(),
        ],
      ),
    ];

    for (var bait in baits) {
      await baitManager.addOrUpdate(bait);
    }

    expect(baitManager.numberOfCustomEntityValues(customId0), 3);
    expect(baitManager.numberOfCustomEntityValues(customId1), 1);
    expect(baitManager.numberOfCustomEntityValues(customId2), 2);
    expect(baitManager.numberOfCustomEntityValues(randomId()), 0);
  });

  test("baitAttachmentList", () async {
    expect(baitManager.entityCount, 0);
    expect(baitManager.attachmentList().length, 0);

    Bait baitWithVariant() {
      return Bait(
        id: randomId(),
        variants: [
          BaitVariant(
            id: randomId(),
            baseId: randomId(),
          ),
        ],
      );
    }

    var baits = <Bait>[
      Bait(id: randomId()),
      baitWithVariant(),
      Bait(id: randomId()),
      baitWithVariant(),
      baitWithVariant(),
      baitWithVariant(),
      Bait(
        id: randomId(),
        variants: [
          BaitVariant(id: randomId()),
          BaitVariant(id: randomId()),
        ],
      ),
      baitWithVariant(),
      baitWithVariant(),
      Bait(id: randomId()),
    ];

    for (var bait in baits) {
      await baitManager.addOrUpdate(bait);
    }

    expect(baitManager.entityCount, 10);

    var attachments = baitManager.attachmentList();
    expect(attachments.length, 11);
  });

  test("variantFromAttachment bait doesn't exist", () async {
    expect(baitManager.variantFromAttachment(BaitAttachment()), isNull);
  });

  test("variantFromAttachment variant doesn't exist", () async {
    var baitId = randomId();
    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
    ));

    expect(
        baitManager.variantFromAttachment(BaitAttachment(
          baitId: baitId,
          variantId: randomId(),
        )),
        isNull);
  });

  test("variantFromAttachment success", () async {
    var baitId = randomId();
    var variantId = randomId();

    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
      variants: [
        BaitVariant(
          id: variantId,
          color: "Blue",
        ),
      ],
    ));

    expect(
        baitManager.variantFromAttachment(BaitAttachment(
          baitId: baitId,
          variantId: variantId,
        )),
        isNotNull);
  });

  testWidgets("attachmentDisplayValue bait doesn't exist", (tester) async {
    var context = await buildContext(tester);
    expect(
      baitManager.attachmentDisplayValue(context, BaitAttachment()),
      "Unknown Bait",
    );
  });

  testWidgets("attachmentDisplayValue variant doesn't exist", (tester) async {
    var context = await buildContext(tester);
    var baitId = randomId();
    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
    ));

    expect(
      baitManager.attachmentDisplayValue(
        context,
        BaitAttachment(
          baitId: baitId,
          variantId: randomId(),
        ),
      ),
      "Test",
    );
  });

  testWidgets("attachmentDisplayValue variant display value is empty",
      (tester) async {
    var context = await buildContext(tester);
    var baitId = randomId();
    var variantId = randomId();
    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
      variants: [
        BaitVariant(id: variantId),
      ],
    ));

    expect(
      baitManager.attachmentDisplayValue(
        context,
        BaitAttachment(
          baitId: baitId,
          variantId: variantId,
        ),
      ),
      "Test",
    );
  });

  testWidgets("attachmentDisplayValue showAllVariantsLabel is true",
      (tester) async {
    var context = await buildContext(tester);
    var baitId = randomId();
    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
    ));

    expect(
      baitManager.attachmentDisplayValue(
        context,
        BaitAttachment(
          baitId: baitId,
          variantId: randomId(),
        ),
        showAllVariantsLabel: true,
      ),
      "Test (All Variants)",
    );
  });

  testWidgets("attachmentDisplayValue variant exists", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("");

    var context = await buildContext(tester);
    var baitId = randomId();
    var variantId = randomId();

    await baitManager.addOrUpdate(Bait(
      id: baitId,
      name: "Test",
      variants: [
        BaitVariant(
          id: variantId,
          color: "Blue",
        ),
      ],
    ));

    expect(
      baitManager.attachmentDisplayValue(
        context,
        BaitAttachment(
          baitId: baitId,
          variantId: variantId,
        ),
      ),
      "Test (Blue)",
    );
  });

  testWidgets("attachmentsDisplayValues", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("");

    var context = await buildContext(tester);
    var baitId0 = randomId();
    var baitId1 = randomId();
    var variantId0 = randomId();
    var variantId1 = randomId();

    await baitManager.addOrUpdate(Bait(
      id: baitId0,
      name: "Test",
      variants: [
        BaitVariant(
          id: variantId0,
          color: "Blue",
        ),
      ],
    ));
    await baitManager.addOrUpdate(Bait(
      id: baitId1,
      name: "Test 2",
      variants: [
        BaitVariant(
          id: variantId1,
          color: "Red",
        ),
      ],
    ));
    await baitManager.addOrUpdate(Bait(
      id: randomId(),
      name: "Test 3",
      variants: [
        BaitVariant(
          id: randomId(),
          color: "Green",
        ),
      ],
    ));

    expect(
      baitManager.attachmentsDisplayValues(
        context,
        [
          BaitAttachment(
            baitId: baitId0,
            variantId: variantId0,
          ),
          BaitAttachment(
            baitId: baitId1,
            variantId: variantId1,
          ),
          BaitAttachment(
            baitId: randomId(),
            variantId: randomId(),
          ),
        ],
      ),
      [
        "Test (Blue)",
        "Test 2 (Red)",
        "Unknown Bait",
      ],
    );
  });

  testWidgets("variantDisplayValue all fields", (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      color: "Red",
      modelNumber: "AB123",
      size: "Small",
      minDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 5,
        ),
      ),
      maxDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      ),
    );

    expect(
      baitManager.variantDisplayValue(context, variant),
      "Red, AB123, Small, 5 m - 10 m",
    );
  });

  testWidgets("variantDisplayValue min dive depth", (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      minDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 5,
        ),
      ),
    );

    expect(
      baitManager.variantDisplayValue(context, variant),
      "\u2265 5 m",
    );
  });

  testWidgets("variantDisplayValue max dive depth", (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      maxDiveDepth: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.meters,
          value: 5,
        ),
      ),
    );

    expect(
      baitManager.variantDisplayValue(context, variant),
      "\u2264 5 m",
    );
  });

  testWidgets("variantDisplayValue include custom values", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("Tag: 12, Label: Value");

    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      color: "Red",
    );

    expect(
      baitManager.variantDisplayValue(
        context,
        variant,
        includeCustomValues: true,
      ),
      "Red, Tag: 12, Label: Value",
    );
  });

  testWidgets("variantDisplayValue exclude custom values", (tester) async {
    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("Tag: 12, Label: Value");

    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      color: "Red",
    );

    expect(
      baitManager.variantDisplayValue(
        context,
        variant,
        includeCustomValues: false,
      ),
      "Red",
    );
  });

  testWidgets(
      "variantDisplayValue includes description if all others are empty",
      (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      description: "Test description.",
    );
    expect(
      baitManager.variantDisplayValue(context, variant),
      "Test description.",
    );
  });

  testWidgets("variantDisplayValue includes description with custom values",
      (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      description: "Test description.",
    );
    expect(
      baitManager.variantDisplayValue(context, variant,
          includeCustomValues: true),
      "Test description.",
    );
  });

  testWidgets(
      "variantDisplayValue excludes description if others are not empty",
      (tester) async {
    var context = await buildContext(tester);
    var variant = BaitVariant(
      id: randomId(),
      color: "Red",
      description: "Test description.",
    );
    expect(
      baitManager.variantDisplayValue(context, variant),
      "Red",
    );
  });

  testWidgets("deleteVariantMessage", (tester) async {
    var context = await buildContext(tester);
    var baitId0 = randomId();
    var baitId1 = randomId();
    var variantId0 = randomId();
    var variantId1 = randomId();

    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId0,
            variantId: variantId0,
          ),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId1,
            variantId: variantId1,
          ),
        ],
      ),
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId0,
            variantId: variantId0,
          ),
        ],
      ),
    ]);

    expect(
      baitManager.deleteVariantMessage(context, BaitVariant(id: variantId0)),
      "This variant is associated with 2 catches; are you sure you want "
      "to delete it? This cannot be undone.",
    );
    expect(
      baitManager.deleteVariantMessage(context, BaitVariant(id: variantId1)),
      "This variant is associated with 1 catch; are you sure you want "
      "to delete it? This cannot be undone.",
    );
  });

  test("baitAttachmentComparator", () async {
    var categoryId = randomId();
    await baitCategoryManager.addOrUpdate(BaitCategory(
      id: categoryId,
      name: "Live",
    ));

    var baitId0 = randomId();
    var baitId1 = randomId();
    var baitId2 = randomId();
    var baitId3 = randomId();
    var baits = <Bait>[
      Bait(
        id: baitId0,
        name: "C",
        baitCategoryId: categoryId,
      ),
      Bait(
        id: baitId1,
        name: "D",
      ),
      Bait(
        id: baitId2,
        name: "A",
      ),
      Bait(
        id: baitId3,
        name: "B",
      ),
    ];
    for (var bait in baits) {
      await baitManager.addOrUpdate(bait);
    }

    var attachments = <BaitAttachment>[
      BaitAttachment(baitId: baitId0),
      BaitAttachment(baitId: baitId1),
      BaitAttachment(baitId: baitId2),
      BaitAttachment(baitId: baitId3),
    ];

    attachments.sort(baitManager.attachmentComparator);

    expect(baitManager.entity(attachments[0].baitId)!.name, "A");
    expect(baitManager.entity(attachments[1].baitId)!.name, "B");
    expect(baitManager.entity(attachments[2].baitId)!.name, "D");

    // Bait "C" has category "Live", so the sorting value is "Live - C" and
    // therefore, is last in the list.
    expect(baitManager.entity(attachments[3].baitId)!.name, "C");
  });
}
