import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/model/custom_entity_value.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBatch extends Mock implements Batch {}
class MockBaitCategoryManager extends Mock implements BaitCategoryManager {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockFishingSpotManager extends Mock implements FishingSpotManager {}
class MockImageManager extends Mock implements ImageManager {}

void main() {
  MockAppManager appManager;
  MockBaitCategoryManager baitCategoryManager;
  MockDataManager dataManager;
  MockFishingSpotManager fishingSpotManager;
  MockImageManager imageManager;

  BaitManager baitManager;
  CatchManager catchManager;
  CustomEntityManager entityManager;

  CustomEntityValueManager entityValueManager;

  setUp(() {
    appManager = MockAppManager();

    baitCategoryManager = MockBaitCategoryManager();
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);
    when(baitCategoryManager.addListener(any)).thenAnswer((_) {});

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any)).thenAnswer((_) =>
        Future.value(true));
    when(dataManager.commitBatch(any)).thenAnswer((_) => Future.value([]));
    when(dataManager.insertOrUpdateEntity(any, any)).thenAnswer((_) =>
        Future.value(true));
    when(dataManager.rawUpdate(any, any)).thenAnswer((realInvocation) =>
        Future.value(true));

    fishingSpotManager = MockFishingSpotManager();
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);
    when(fishingSpotManager.addListener(any)).thenAnswer((_) {});

    imageManager = MockImageManager();
    when(appManager.imageManager).thenReturn(imageManager);
    when(imageManager.save(any, any)).thenAnswer((_) => null);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);

    catchManager = CatchManager(appManager);
    when(appManager.catchManager).thenReturn(catchManager);

    entityManager = CustomEntityManager(appManager);
    when(appManager.customEntityManager).thenReturn(entityManager);

    entityValueManager = CustomEntityValueManager(appManager);
    when(appManager.customEntityValueManager).thenReturn(entityValueManager);
  });

  test("Test initialize", () async {
    when(dataManager.fetchAll(any)).thenAnswer((_) => Future.value([
      CustomEntityValue(
        entityId: "id0",
        customEntityId: "cid0",
        textValue: "Value One",
        entityType: EntityType.bait,
      ).toMap(),
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "cid1",
        textValue: "Value Two",
        entityType: EntityType.bait,
      ).toMap(),
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "cid2",
        textValue: "Value Three",
        entityType: EntityType.bait,
      ).toMap(),
    ]));

    await entityValueManager.initialize();
    expect(entityValueManager.values(entityId: "id0").length, 1);
    expect(entityValueManager.values(entityId: "id1").length, 2);
  });

  test("Entity values are set and deleted when adding and deleting catches",
      () async
  {
    Catch cat = Catch(
      id: "catch_id",
      timestamp: 1,
      speciesId: "species_id",
    );

    // Test adding.
    await catchManager.addOrUpdate(
      cat,
      customEntityValues: [
        CustomEntityValue(
          entityId: "catch_id",
          customEntityId: "custom_id",
          textValue: "Test Value",
          entityType: EntityType.bait,
        ),
        CustomEntityValue(
          entityId: "catch_id",
          customEntityId: "custom_id_1",
          textValue: "Test Value 2",
          entityType: EntityType.bait,
        ),
      ],
    );

    expect(entityValueManager.values(entityId: "catch_id").length, 2);

    // Test remove custom entity value.
    await catchManager.addOrUpdate(
      cat,
      customEntityValues: [
        CustomEntityValue(
          entityId: "catch_id",
          customEntityId: "custom_id_1",
          textValue: "Test Value 2",
          entityType: EntityType.bait,
        ),
      ],
    );

    expect(entityValueManager.values(entityId: "catch_id").length, 1);

    // Delete catch.
    await catchManager.delete(cat);
    expect(entityValueManager.values(entityId: "catch_id").isEmpty, true);
  });

  test("Test initialize", () async {
    when(dataManager.fetchAll(any)).thenAnswer((_) => Future.value([
      CustomEntityValue(
        entityId: "id0",
        customEntityId: "cid0",
        textValue: "Value One",
        entityType: EntityType.bait,
      ).toMap(),
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "cid1",
        textValue: "Value Two",
        entityType: EntityType.bait,
      ).toMap(),
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "cid2",
        textValue: "Value Three",
        entityType: EntityType.bait,
      ).toMap(),
    ]));

    await entityValueManager.initialize();
    expect(entityValueManager.values(entityId: "id0").length, 1);
    expect(entityValueManager.values(entityId: "id1").length, 2);
  });

  test("Entity values are set and deleted when adding and deleting baits",
      () async
  {
    Bait bait = Bait(
      id: "bait_id",
      name: "Bait One",
    );

    // Test adding.
    await baitManager.addOrUpdate(
      bait,
      customEntityValues: [
        CustomEntityValue(
          entityId: "bait_id",
          customEntityId: "custom_id",
          textValue: "Test Value",
          entityType: EntityType.bait,
        ),
        CustomEntityValue(
          entityId: "bait_id",
          customEntityId: "custom_id_1",
          textValue: "Test Value 2",
          entityType: EntityType.bait,
        ),
      ],
    );

    expect(entityValueManager.values(entityId: "bait_id").length, 2);

    // Test remove custom entity value.
    await baitManager.addOrUpdate(
      bait,
      customEntityValues: [
        CustomEntityValue(
          entityId: "baitId",
          customEntityId: "custom_id_1",
          textValue: "Test Value 2",
          entityType: EntityType.bait,
        ),
      ],
    );

    expect(entityValueManager.values(entityId: "bait_id").length, 1);

    // Delete bait.
    await baitManager.delete(bait);
    expect(entityValueManager.values(entityId: "bait_id").isEmpty, true);
  });

  test("Entity values are deleted when CustomEntity objects are deleted",
      () async
  {
    var deleteEntity = CustomEntity(
      id: "field_id_1",
      name: "Field 1",
      type: InputType.number,
    );

    // Add custom entities.
    await entityManager.addOrUpdate(deleteEntity);
    await entityManager.addOrUpdate(CustomEntity(
      id: "field_id_2",
      name: "Field 2",
      type: InputType.number,
    ));
    await entityManager.addOrUpdate(CustomEntity(
      id: "field_id_3",
      name: "Field 2",
      type: InputType.number,
    ));
    expect(entityManager.entityCount, 3);

    // Add custom entity values.
    await entityValueManager.setValues("ID1", [
      CustomEntityValue(
        entityId: "ID1",
        customEntityId: "field_id_1",
        entityType: EntityType.bait,
        textValue: "Value 1",
      ),
      CustomEntityValue(
        entityId: "ID1",
        customEntityId: "field_id_2",
        entityType: EntityType.bait,
        textValue: "Value 2",
      ),
    ]);
    await entityValueManager.setValues("ID2", [
      CustomEntityValue(
        entityId: "ID2",
        customEntityId: "field_id_1",
        entityType: EntityType.bait,
        textValue: "Value 1",
      ),
    ]);

    // Delete custom entity.
    await entityManager.delete(deleteEntity);
    expect(entityValueManager.values(entityId: "ID1").length, 1);
    expect(entityValueManager.values(entityId: "ID2").isEmpty, true);
  });

  test("Entity values are cleared when database is reset", () async {
    // Setup real DataManager to initiate callback.
    var batch = MockBatch();
    when(batch.commit()).thenAnswer((_) => Future.value([]));
    when(batch.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) {});
    when(batch.insert(any, any)).thenAnswer((_) {});

    var database = MockDatabase();
    when(database.batch()).thenReturn(batch);
    when(database.rawQuery(any, any)).thenAnswer((_) => Future.value([]));

    var realDataManager = DataManager();
    await realDataManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
      resetDatabase: () => Future.value(database),
    );

    when(appManager.dataManager).thenReturn(realDataManager);
    entityValueManager = CustomEntityValueManager(appManager);

    // Add custom entity values.
    await entityValueManager.setValues("ID1", [
      CustomEntityValue(
        entityId: "ID1",
        customEntityId: "field_id_1",
        entityType: EntityType.bait,
        textValue: "Value 1",
      ),
      CustomEntityValue(
        entityId: "ID1",
        customEntityId: "field_id_2",
        entityType: EntityType.bait,
        textValue: "Value 2",
      ),
    ]);
    await entityValueManager.setValues("ID2", [
      CustomEntityValue(
        entityId: "ID2",
        customEntityId: "field_id_1",
        entityType: EntityType.bait,
        textValue: "Value 1",
      ),
    ]);
    expect(entityValueManager.values(entityId: "ID1").length, 2);
    expect(entityValueManager.values(entityId: "ID2").length, 1);

    // Clear data.
    await realDataManager.reset();
    expect(entityValueManager.values(entityId: "ID1").isEmpty, true);
    expect(entityValueManager.values(entityId: "ID2").isEmpty, true);
  });

  test("Catch and bait value counts are calculated correctly", () async {
    await entityValueManager.setValues("id0", [
      CustomEntityValue(
        entityId: "id0",
        customEntityId: "field_id_1",
        entityType: EntityType.bait,
        textValue: "Value 1",
      ),
      CustomEntityValue(
        entityId: "id0",
        customEntityId: "field_id_2",
        entityType: EntityType.fishCatch,
        textValue: "Value 2",
      ),
    ]);

    await entityValueManager.setValues("id1", [
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "field_id_1",
        entityType: EntityType.fishingSpot,
        textValue: "Value 1",
      ),
      CustomEntityValue(
        entityId: "id1",
        customEntityId: "field_id_2",
        entityType: EntityType.fishCatch,
        textValue: "Value 2",
      ),
    ]);

    expect(entityValueManager.baitValueCount("field_id_1"), 1);
    expect(entityValueManager.catchValueCount("field_id_2"), 2);
  });
}