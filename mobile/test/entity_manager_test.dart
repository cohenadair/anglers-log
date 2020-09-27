import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

class MockAppManager extends Mock implements AppManager {}
class MockBatch extends Mock implements Batch {}
class MockDatabase extends Mock implements Database {}
class MockDataManager extends Mock implements DataManager {}
class MockEntityListener extends Mock implements EntityListener<Species> {}
class MockSpeciesListener extends Mock implements EntityListener<Species> {}

class TestEntityManager extends EntityManager<Species> {
  TestEntityManager(AppManager app) : super(app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species species) => species.id;

  @override
  bool matchesFilter(Id id, String filter) => true;

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
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    entityManager = TestEntityManager(appManager);
  });

  test("Test initialize", () async {
    Id id0 = randomId();
    Id id1 = randomId();
    Id id2 = randomId();

    Species species0 = Species()..id = id0;
    Species species1 = Species()..id = id1;
    Species species2 = Species()..id = id2;

    when(dataManager.fetchAll("species")).thenAnswer((_) => Future.value([
      {"id": Uint8List.fromList(id0.bytes), "bytes": species0.writeToBuffer()},
      {"id": Uint8List.fromList(id1.bytes), "bytes": species1.writeToBuffer()},
      {"id": Uint8List.fromList(id2.bytes), "bytes": species2.writeToBuffer()},
    ]));
    await entityManager.initialize();
    expect(entityManager.entityCount, 3);
  });

  test("Test add or update", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    MockSpeciesListener listener = MockSpeciesListener();
    when(listener.onAddOrUpdate).thenReturn(() {});
    when(listener.onDelete).thenReturn((_) {});
    entityManager.addListener(listener);

    // Add.
    Id speciesId0 = randomId();
    Id speciesId1 = randomId();

    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill"), true);
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(speciesId0).name, "Bluegill");
    verify(listener.onAddOrUpdate).called(1);

    // Update.
    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bass"), true);
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(speciesId0).name, "Bass");
    verify(listener.onAddOrUpdate).called(1);

    // No notify.
    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId1
      ..name = "Catfish", notify: false), true);
    expect(entityManager.entityCount, 2);
    expect(entityManager.entity(speciesId1).name, "Catfish");
    verifyNever(listener.onAddOrUpdate);
  });

  test("Test delete", () async {
    when(dataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    MockSpeciesListener listener = MockSpeciesListener();
    when(listener.onAddOrUpdate).thenReturn(() {});
    when(listener.onDelete).thenReturn((_) {});
    entityManager.addListener(listener);

    Id speciesId0 = randomId();
    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");

    expect(await entityManager.delete(speciesId0), true);
    expect(entityManager.entityCount, 0);
    verify(listener.onDelete).called(1);

    // If there's nothing to delete, the listener shouldn't be called.
    expect(await entityManager.delete(speciesId0), true);
    verifyNever(listener.onDelete);
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
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Test");
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

  test("Entity list by ID", () async {
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    // Add.
    Id speciesId0 = randomId();
    Id speciesId1 = randomId();
    Id speciesId2 = randomId();

    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill"), true);
    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId1
      ..name = "Catfish"), true);
    expect(await entityManager.addOrUpdate(Species()
      ..id = speciesId2
      ..name = "Bass"), true);
    expect(entityManager.entityCount, 3);
    expect(entityManager.list().length, 3);
    expect(entityManager.list([speciesId0, speciesId2]).length, 2);
  });

  group("filteredList", () {
    test("Empty filter always returns all entities", () async {
      await entityManager.addOrUpdate(Species()
        ..id = randomId()
        ..name = "Bluegill");
      await entityManager.addOrUpdate(Species()
        ..id = randomId()
        ..name = "Catfish");
      await entityManager.addOrUpdate(Species()
        ..id = randomId()
        ..name = "Bass");

      expect(entityManager.filteredList(null).length, 3);
      expect(entityManager.filteredList("").length, 3);
    });
  });
}