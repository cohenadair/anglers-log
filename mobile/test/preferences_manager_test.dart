import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

class MockAppManager extends Mock implements AppManager {}
class MockCustomEntityManager extends Mock implements CustomEntityManager {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockSpeciesListener extends Mock implements EntityListener<Species> {}

void main() {
  MockAppManager appManager;
  MockCustomEntityManager entityManager;
  MockDataManager dataManager;
  PreferencesManager preferencesManager;

  setUp(() async {
    appManager = MockAppManager();

    entityManager = MockCustomEntityManager();
    when(appManager.customEntityManager).thenReturn(entityManager);

    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    preferencesManager = PreferencesManager(appManager);
  });

  test("Test initialize", () async {
    when(dataManager.fetchAll("preference")).thenAnswer((_) =>
        Future.value([]));
    await preferencesManager.initialize();
    expect(preferencesManager.baitCustomEntityIds.isEmpty, true);
    expect(preferencesManager.catchCustomEntityIds.isEmpty, true);

    when(dataManager.fetchAll("preference")).thenAnswer((_) =>
        Future.value([
          {
            "id": "bait_custom_entity_ids",
            "value": jsonEncode(["id0", "id1"])
          },
          {
            "id": "catch_custom_entity_ids",
            "value": jsonEncode(["id2", "id3"])
          },
        ]));
    await preferencesManager.initialize();
    expect(preferencesManager.baitCustomEntityIds, ["id0", "id1"]);
    expect(preferencesManager.catchCustomEntityIds, ["id2", "id3"]);
  });

  test("String no values returns empty String list", () {
    expect(preferencesManager.baitCustomEntityIds.isEmpty, true);
  });

  test("Setting String list", () {
    when(dataManager.query(any, any)).thenAnswer((_) => Future.value([]));

    preferencesManager.baitCustomEntityIds = ["id0", "id1"];
    expect(preferencesManager.baitCustomEntityIds, ["id0", "id1"]);

    preferencesManager.catchCustomEntityIds = ["id2", "id3"];
    expect(preferencesManager.catchCustomEntityIds, ["id2", "id3"]);
  });

  test("Custom entity IDs are deleted from preferences when custom entity "
      "objects are deleted", () async
  {
    var deleteEntity = CustomEntity(
      id: "id0",
      name: "Size",
      type: InputType.number,
    );
    var realEntityManager = CustomEntityManager(appManager);
    await realEntityManager.addOrUpdate(deleteEntity);
    expect(realEntityManager.entityCount, 1);

    when(appManager.customEntityManager).thenReturn(realEntityManager);
    preferencesManager = PreferencesManager(appManager);
    preferencesManager.baitCustomEntityIds = ["id0", "id1"];
    preferencesManager.catchCustomEntityIds = ["id0"];

    // Delete custom entity.
    await realEntityManager.delete(deleteEntity);
    expect(preferencesManager.baitCustomEntityIds.length, 1);
    expect(preferencesManager.catchCustomEntityIds.isEmpty, true);
  });

  test("Preferences are cleared when database is reset", () async {
    var database = MockDatabase();
    when(database.insert(any, any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).thenAnswer((_) => Future.value(1));
    when(database.delete(any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(1));

    var realDataManager = DataManager();
    await realDataManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
      resetDatabase: () => Future.value(database),
    );

    when(appManager.dataManager).thenReturn(realDataManager);
    preferencesManager = PreferencesManager(appManager);
    preferencesManager.baitCustomEntityIds = ["id0", "id1"];
    preferencesManager.catchCustomEntityIds = ["id0"];

    // Reset database.
    await realDataManager.reset();
    expect(preferencesManager.baitCustomEntityIds.isEmpty, true);
    expect(preferencesManager.catchCustomEntityIds.isEmpty, true);
  });
}