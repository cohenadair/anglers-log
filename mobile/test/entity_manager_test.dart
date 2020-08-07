import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/species.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

import 'test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBatch extends Mock implements Batch {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockEntityListener extends Mock implements EntityListener<Species> {}
class MockSpeciesListener extends Mock implements EntityListener<Species> {}

class TestEntityManager extends EntityManager<Species> {
  TestEntityManager(AppManager app) : super(app);

  @override
  Species entityFromMap(Map<String, dynamic> map) => Species.fromMap(map);

  @override
  String get tableName => "species";
}

void main() {
  MockAppManager appManager;
  MockDataManager dataManager;
  TestEntityManager entityManager;

  setUp(() async {
    appManager = MockAppManager();
    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    entityManager = TestEntityManager(appManager);
  });

  test("Test initialize", () async {
    when(dataManager.fetchAll("species")).thenAnswer((_) =>
        Future.value([
          Species(name: "Bass").toMap(),
          Species(name: "Bluegill").toMap(),
          Species(name: "Catfish").toMap(),
        ]));
    await entityManager.initialize();
    expect(entityManager.entityCount, 3);
  });

  test("Test add or update", () async {
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockSpeciesListener listener = MockSpeciesListener();
    when(listener.onAddOrUpdate).thenReturn(() {});
    when(listener.onDelete).thenReturn((_) {});
    entityManager.addListener(listener);

    // Add.
    expect(await entityManager.addOrUpdate(Species(
      id: "ID",
      name: "Bluegill",
    )), true);
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(id: "ID").name, "Bluegill");
    verify(listener.onAddOrUpdate).called(1);

    // Update.
    expect(await entityManager.addOrUpdate(Species(
      id: "ID",
      name: "Bass",
    )), true);
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(id: "ID").name, "Bass");
    verify(listener.onAddOrUpdate).called(1);

    // No notify.
    expect(await entityManager.addOrUpdate(Species(
      id: "ID2",
      name: "Catfish",
    ), notify: false), true);
    expect(entityManager.entityCount, 2);
    expect(entityManager.entity(id: "ID2").name, "Catfish");
    verifyNever(listener.onAddOrUpdate);
  });

  test("Test delete", () async {
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockSpeciesListener listener = MockSpeciesListener();
    when(listener.onAddOrUpdate).thenReturn(() {});
    when(listener.onDelete).thenReturn((_) {});
    entityManager.addListener(listener);
    await entityManager.addOrUpdate(Species(
      id: "ID",
      name: "Bluegill",
    ));

    expect(await entityManager.delete(Species(
      id: "ID",
      name: "Bluegill",
    )), true);
    expect(entityManager.entityCount, 0);
    verify(listener.onDelete).called(1);
  });

  test("Data is cleared and listeners notified when database is reset",
      () async
  {
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
    when(database.rawQuery(any, any)).thenAnswer((_) => Future.value([]));
    when(database.insert(any, any)).thenAnswer((_) => Future.value(1));

    var realDataManager = DataManager();
    await realDataManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
      resetDatabase: () => Future.value(database),
    );

    when(appManager.dataManager).thenReturn(realDataManager);
    entityManager = TestEntityManager(appManager);

    // Add some entities.
    await entityManager.addOrUpdate(Species(name: "Test"));
    expect(entityManager.entityCount, 1);

    // Setup listener.
    var listener = MockEntityListener();
    when(listener.onClear).thenReturn(() {});
    entityManager.addListener(listener);

    // Clear data.
    await realDataManager.reset();
    expect(entityManager.entityCount, 0);
    await untilCalled(listener.onClear);
    verify(listener.onClear).called(1);
  });
}