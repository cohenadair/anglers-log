import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockBatch extends Mock implements Batch {}

class MockDatabase extends Mock implements Database {}

class MockEntityListener extends Mock implements EntityListener<Species> {}

class MockSpeciesListener extends Mock implements EntityListener<Species> {}

class TestEntityManager extends EntityManager<Species> {
  bool firestoreEnabled = true;

  TestEntityManager(AppManager app) : super(app);

  @override
  bool get enableFirestore => firestoreEnabled;

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
  TestEntityManager entityManager;

  setUp(() async {
    appManager = MockAppManager(
      mockAppPreferenceManager: true,
      mockAuthManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
      mockFirestoreWrapper: true,
    );

    var stream = MockStream<void>();
    when(stream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => stream);

    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((realInvocation) => Future.value(true));
    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    entityManager = TestEntityManager(appManager);
  });

  test("Test initialize local data", () async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    var species0 = Species()..id = id0;
    var species1 = Species()..id = id1;
    var species2 = Species()..id = id2;

    when(appManager.mockLocalDatabaseManager.fetchAll("species")).thenAnswer(
      (_) => Future.value(
        [
          {
            "id": Uint8List.fromList(id0.bytes),
            "bytes": species0.writeToBuffer()
          },
          {
            "id": Uint8List.fromList(id1.bytes),
            "bytes": species1.writeToBuffer()
          },
          {
            "id": Uint8List.fromList(id2.bytes),
            "bytes": species2.writeToBuffer()
          },
        ],
      ),
    );
    await entityManager.initialize();
    expect(entityManager.entityCount, 3);
  });

  test("Test clear local data", () async {
    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    // Add.
    var speciesId0 = randomId();
    var speciesId1 = randomId();

    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");
    await entityManager.addOrUpdate(Species()
      ..id = speciesId1
      ..name = "Catfish");
    expect(entityManager.entityCount, 2);

    await entityManager.clearLocalData();
    verify(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .called(2);
    verifyNever(appManager.mockFirestoreWrapper.collection(any));
  });

  test("Test initialize Firestore", () async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    var snapshot = MockQuerySnapshot();
    when(snapshot.docChanges).thenReturn([]);

    // Mimic Firebase's behaviour by invoking listener immediately.
    var stream = MockStream<MockQuerySnapshot>();
    when(stream.listen(any)).thenAnswer(
        (invocation) => invocation.positionalArguments.first(snapshot));

    var collection = MockCollectionReference();
    when(collection.snapshots()).thenAnswer((_) => stream);

    when(appManager.mockFirestoreWrapper.collection(any))
        .thenReturn(collection);

    // Setup Firestore listener.
    await entityManager.initialize();
    verify(snapshot.docChanges).called(1);

    // In this test, we assume Firestore listeners work as expected, and we
    // capture the listener function passed to snapshots().listen and invoke it
    // manually.
    var result = verify(stream.listen(captureAny));
    result.called(1);

    var listener = result.captured.first;

    // No changes.
    listener(null);
    verifyNever(snapshot.docChanges);

    listener(snapshot);
    verify(snapshot.docChanges).called(1);

    // Bytes can't be parsed.
    var docSnapshot = MockDocumentSnapshot();
    when(docSnapshot.data()).thenReturn({});
    var docChange = MockDocumentChange();
    when(docChange.doc).thenReturn(docSnapshot);
    when(snapshot.docChanges).thenReturn([
      docChange,
    ]);
    listener(snapshot);
    verifyNever(docChange.type);

    when(docSnapshot.data()).thenReturn({
      "bytes": [],
    });
    listener(snapshot);
    verifyNever(docChange.type);

    when(docSnapshot.data()).thenReturn({
      "bytes": null,
    });
    listener(snapshot);
    verifyNever(docChange.type);

    // Document added.
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(docSnapshot.data()).thenReturn({
      "bytes": species.writeToBuffer(),
    });
    when(docChange.type).thenReturn(DocumentChangeType.added);
    listener(snapshot);
    verify(docChange.type).called(2);
    verify(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .called(1);

    // Document updated.
    when(docChange.type).thenReturn(DocumentChangeType.modified);
    listener(snapshot);
    verify(docChange.type).called(3);
    verify(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .called(1);

    // Document deleted.
    entityManager.firestoreEnabled = false;
    await entityManager.addOrUpdate(species);
    verify(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .called(1);

    when(docChange.type).thenReturn(DocumentChangeType.removed);
    listener(snapshot);
    verify(docChange.type).called(3);
    verifyNever(appManager.mockLocalDatabaseManager
        .insertOrUpdateEntity(any, any, any));
    verify(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .called(1);
  });

  test("Test add or update local", () async {
    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    var listener = MockSpeciesListener();
    when(listener.onAdd).thenReturn((_) {});
    when(listener.onDelete).thenReturn((_) {});
    when(listener.onUpdate).thenReturn((_) {});
    entityManager.addListener(listener);

    // Add.
    var speciesId0 = randomId();
    var speciesId1 = randomId();

    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId0
        ..name = "Bluegill"),
      true,
    );
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(speciesId0).name, "Bluegill");
    verify(listener.onAdd).called(1);

    // Update.
    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId0
        ..name = "Bass"),
      true,
    );
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(speciesId0).name, "Bass");
    verify(listener.onUpdate).called(1);

    // No notify.
    expect(
      await entityManager.addOrUpdate(
          Species()
            ..id = speciesId1
            ..name = "Catfish",
          notify: false),
      true,
    );
    expect(entityManager.entityCount, 2);
    expect(entityManager.entity(speciesId1).name, "Catfish");
    verifyNever(listener.onAdd);
    verifyNever(listener.onUpdate);
  });

  test("Add or update Firestore", () async {
    var collection = MockCollectionReference();
    var doc = MockDocumentReference();
    when(collection.doc(any)).thenReturn(doc);
    when(appManager.mockFirestoreWrapper.collection(any))
        .thenReturn(collection);
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Steelhead");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Catfish");

    verify(appManager.mockFirestoreWrapper.collection(any)).called(2);
  });

  test("Delete from Firestore", () async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Steelhead");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Catfish");

    expect(entityManager.entityCount, 2);
  });

  test("Delete locally", () async {
    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    var listener = MockSpeciesListener();
    when(listener.onAdd).thenReturn((_) {});
    when(listener.onDelete).thenReturn((_) {});
    when(listener.onUpdate).thenReturn((_) {});
    entityManager.addListener(listener);

    var speciesId0 = randomId();
    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");

    expect(await entityManager.delete(speciesId0), true);
    expect(entityManager.entityCount, 0);
    verify(listener.onDelete).called(1);
    verify(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .called(1);

    // If there's nothing to delete, the database shouldn't be queried and the
    // listener shouldn't be called.
    expect(await entityManager.delete(speciesId0), true);
    verifyNever(appManager.mockLocalDatabaseManager.deleteEntity(any, any));
    verifyNever(listener.onDelete);
  });

  test("Test delete locally with notify=false", () async {
    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var listener = MockSpeciesListener();
    when(listener.onAdd).thenReturn((_) {});
    when(listener.onDelete).thenReturn((_) {});
    when(listener.onUpdate).thenReturn((_) {});
    entityManager.addListener(listener);

    var speciesId0 = randomId();
    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");

    expect(await entityManager.delete(speciesId0, notify: false), true);
    expect(entityManager.entityCount, 0);
    verify(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .called(1);
    verifyNever(listener.onDelete);
  });

  test("Entity list by ID", () async {
    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    // Add.
    var speciesId0 = randomId();
    var speciesId1 = randomId();
    var speciesId2 = randomId();

    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId0
        ..name = "Bluegill"),
      true,
    );
    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId1
        ..name = "Catfish"),
      true,
    );
    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId2
        ..name = "Bass"),
      true,
    );
    expect(entityManager.entityCount, 3);
    expect(entityManager.list().length, 3);
    expect(entityManager.list([speciesId0, speciesId2]).length, 2);
  });

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

  test("Only items matching filter are returned", () async {
    // Nothing to test. matchesFilter is an abstract method and should be
    // tested in subclass tests.
  });
}
