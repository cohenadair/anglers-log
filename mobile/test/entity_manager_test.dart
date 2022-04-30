import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:protobuf/protobuf.dart';
import 'package:mobile/widgets/widget.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

class TestEntityManager extends EntityManager<Species> {
  int addListenerCalls = 0;
  int removeListenerCalls = 0;

  bool matchesFilterResult = true;

  TestEntityManager(AppManager app) : super(app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species species) => species.id;

  @override
  String displayName(BuildContext context, Species entity) => entity.name;

  @override
  bool matchesFilter(Id id, String? filter) => matchesFilterResult;

  @override
  String get tableName => "species";

  @override
  Future<int> updateAll({
    required bool Function(Species) where,
    required Future<void> Function(Species entity) apply,
  }) {
    return super.updateAll(where: where, apply: apply);
  }

  @override
  int numberOf<T extends GeneratedMessage>(
          Id? id, List<T> items, bool Function(T) matches) =>
      super.numberOf<T>(id, items, matches);

  @override
  void addListener(EntityListener<Species> listener) {
    addListenerCalls++;
    super.addListener(listener);
  }

  @override
  void removeListener(EntityListener<Species> listener) {
    removeListenerCalls++;
    super.removeListener(listener);
  }
}

void main() {
  late StubbedAppManager appManager;
  late TestEntityManager entityManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .thenAnswer((realInvocation) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.commitTransaction(any)).thenAnswer(
        (invocation) => invocation.positionalArguments.first(MockBatch()));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    entityManager = TestEntityManager(appManager.app);
  });

  test("Test initialize local data", () async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    var species0 = Species()..id = id0;
    var species1 = Species()..id = id1;
    var species2 = Species()..id = id2;

    when(appManager.localDatabaseManager.fetchAll("species")).thenAnswer(
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

  test("Test add or update local", () async {
    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    var listener = MockEntityListener<Species>();
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
    expect(entityManager.entity(speciesId0)!.name, "Bluegill");
    verify(listener.onAdd).called(1);

    // Update.
    expect(
      await entityManager.addOrUpdate(Species()
        ..id = speciesId0
        ..name = "Bass"),
      true,
    );
    expect(entityManager.entityCount, 1);
    expect(entityManager.entity(speciesId0)!.name, "Bass");
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
    expect(entityManager.entity(speciesId1)!.name, "Catfish");
    verifyNever(listener.onAdd);
    verifyNever(listener.onUpdate);
  });

  test("updateAll", () async {
    await entityManager.addOrUpdate(Species(
      id: randomId(),
      name: "Bluegill",
    ));
    await entityManager.addOrUpdate(Species(
      id: randomId(),
      name: "Largemouth Bass",
    ));
    await entityManager.addOrUpdate(Species(
      id: randomId(),
      name: "Smallmouth Bass",
    ));
    expect(entityManager.entityCount, 3);

    var numberUpdated = await entityManager.updateAll(
      where: (species) => species.name.contains("Bass"),
      apply: (species) async => await entityManager.addOrUpdate(
        species..name = species.name += " 2",
      ),
    );
    expect(numberUpdated, 2);

    var species = List.of(entityManager.list())
      ..sort(
          (lhs, rhs) => ignoreCaseAlphabeticalComparator(lhs.name, rhs.name));
    expect(species[0].name, "Bluegill");
    expect(species[1].name, "Largemouth Bass 2");
    expect(species[2].name, "Smallmouth Bass 2");
  });

  test("Delete locally", () async {
    when(appManager.localDatabaseManager.deleteEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    var listener = MockEntityListener<Species>();
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
    verify(appManager.localDatabaseManager.deleteEntity(any, any)).called(1);

    // If there's nothing to delete, the database shouldn't be queried and the
    // listener shouldn't be called.
    expect(await entityManager.delete(speciesId0), true);
    verifyNever(appManager.localDatabaseManager.deleteEntity(any, any));
    verifyNever(listener.onDelete);
  });

  test("Test delete locally with notify=false", () async {
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var listener = MockEntityListener<Species>();
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
    verify(appManager.localDatabaseManager.deleteEntity(any, any)).called(1);
    verifyNever(listener.onDelete);
  });

  test("Entity list by ID", () async {
    when(appManager.localDatabaseManager.insertOrReplace(any, any))
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

  test("idsMatchFilter empty parameters", () async {
    expect(entityManager.idsMatchFilter([], null), isFalse);
    expect(entityManager.idsMatchFilter([], "Nothing"), isFalse);
  });

  test("idsMatchFilter normal use", () async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    await entityManager.addOrUpdate(Species()
      ..id = id0
      ..name = "Bluegill");
    await entityManager.addOrUpdate(Species()
      ..id = id1
      ..name = "Catfish");
    await entityManager.addOrUpdate(Species()
      ..id = id2
      ..name = "Bass");

    expect(entityManager.idsMatchFilter([id2], "Blue"), isTrue);
    expect(entityManager.idsMatchFilter([id0, id2], "fish"), isTrue);

    entityManager.matchesFilterResult = false;
    expect(entityManager.idsMatchFilter([id0, id2], "No match"), isFalse);
    expect(entityManager.idsMatchFilter([randomId()], "N/A"), isFalse);
  });

  test("numberOf returns 0 if input ID is null", () async {
    expect(entityManager.numberOf<Bait>(null, [], (_) => false), 0);
  });

  test("numberOf returns correct result", () async {
    var anglerId0 = randomId();
    var anglerId1 = randomId();
    var anglerId2 = randomId();
    var anglerId3 = randomId();

    var catches = <Catch>[
      Catch()
        ..id = randomId()
        ..anglerId = anglerId0,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId1,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId2,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId0,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId3,
      Catch()..id = randomId()
    ];

    expect(
      entityManager.numberOf<Catch>(
          anglerId0, catches, (cat) => cat.anglerId == anglerId0),
      2,
    );
    expect(
      entityManager.numberOf<Catch>(
          anglerId1, catches, (cat) => cat.anglerId == anglerId1),
      1,
    );
    expect(
      entityManager.numberOf<Catch>(
          anglerId2, catches, (cat) => cat.anglerId == anglerId2),
      1,
    );
    expect(
      entityManager.numberOf<Catch>(
          anglerId3, catches, (cat) => cat.anglerId == anglerId3),
      1,
    );
  });

  test("idsMatchesFilter returns true", () {
    entityManager.matchesFilterResult = true;
    expect(
      entityManager.idsMatchesFilter([randomId(), randomId()], "Any"),
      isTrue,
    );
  });

  test("idsMatchesFilter returns false", () {
    entityManager.matchesFilterResult = false;
    expect(
      entityManager.idsMatchesFilter([randomId(), randomId()], "Any"),
      isFalse,
    );
  });

  test("idSet with empty input returns all IDs", () async {
    await entityManager.addOrUpdate(Species(id: randomId(), name: "Test 1"));
    await entityManager.addOrUpdate(Species(id: randomId(), name: "Test 2"));

    expect(entityManager.idSet().length, 2);
  });

  test("idSet with input returns only input IDs", () async {
    var ids = [
      randomId(),
      randomId(),
    ];
    await entityManager.addOrUpdate(Species(id: ids[0], name: "Test 1"));
    await entityManager.addOrUpdate(Species(id: ids[1], name: "Test 2"));

    expect(entityManager.idSet(ids: [ids[0]]).length, 1);
  });

  test("idSet with input returns only input entities", () async {
    var entities = [
      Species(id: randomId(), name: "Test 1"),
      Species(id: randomId(), name: "Test 2")
    ];
    await entityManager.addOrUpdate(entities[0]);
    await entityManager.addOrUpdate(entities[1]);

    expect(entityManager.idSet(entities: [entities[0]]).length, 1);
  });

  testWidgets("Stream listeners are managed", (tester) async {
    var subscription1 = MockStreamSubscription();
    when(subscription1.cancel()).thenAnswer((_) => Future.value(null));
    var stream1 = MockStream();
    when(stream1.listen(any)).thenReturn(subscription1);

    var subscription2 = MockStreamSubscription();
    when(subscription2.cancel()).thenAnswer((_) => Future.value(null));
    var stream2 = MockStream();
    when(stream2.listen(any)).thenReturn(subscription2);

    await pumpContext(
      tester,
      (_) => DisposableTester(
        child: EntityListenerBuilder(
          managers: const [],
          streams: [stream1, stream2],
          builder: (_) => const Empty(),
        ),
      ),
    );

    verify(stream1.listen(any)).called(1);
    verify(stream2.listen(any)).called(1);

    var state =
        tester.firstState<DisposableTesterState>(find.byType(DisposableTester));
    state.removeChild();
    await tester.pumpAndSettle();

    verify(subscription1.cancel()).called(1);
    verify(subscription2.cancel()).called(1);
  });

  testWidgets("Stream listeners are notified", (tester) async {
    var controller = StreamController<void>.broadcast(sync: true);

    var builderCalls = 0;
    await pumpContext(
      tester,
      (_) => EntityListenerBuilder(
        managers: const [],
        streams: [controller.stream],
        builder: (_) {
          builderCalls++;
          return const Empty();
        },
      ),
    );

    expect(builderCalls, 1);

    controller.add(null);
    await tester.pumpAndSettle();

    expect(builderCalls, 2);
  });

  testWidgets("EntityListenerBuilder listeners are managed", (tester) async {
    await pumpContext(
      tester,
      (_) => DisposableTester(
        child: EntityListenerBuilder(
          managers: [entityManager],
          builder: (_) => const Empty(),
        ),
      ),
    );

    expect(entityManager.addListenerCalls, 1);

    var state =
        tester.firstState<DisposableTesterState>(find.byType(DisposableTester));
    state.removeChild();
    await tester.pumpAndSettle();

    expect(entityManager.removeListenerCalls, 1);
  });

  testWidgets("EntityListenerBuilder onDeleteEnabled is false", (tester) async {
    bool onDeleteInvoked = false;
    await pumpContext(
      tester,
      (_) => EntityListenerBuilder(
        managers: [entityManager],
        builder: (_) => const Empty(),
        onDelete: (_) => onDeleteInvoked = true,
        onDeleteEnabled: false,
      ),
    );

    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var speciesId0 = randomId();
    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");

    expect(await entityManager.delete(speciesId0, notify: true), isTrue);
    expect(onDeleteInvoked, isFalse);
  });

  testWidgets("EntityListenerBuilder onDeleteEnabled is true", (tester) async {
    bool onDeleteInvoked = false;
    await pumpContext(
      tester,
      (_) => EntityListenerBuilder(
        managers: [entityManager],
        builder: (_) => const Empty(),
        onDelete: (_) => onDeleteInvoked = true,
        onDeleteEnabled: true,
      ),
    );

    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    var speciesId0 = randomId();
    await entityManager.addOrUpdate(Species()
      ..id = speciesId0
      ..name = "Bluegill");

    expect(await entityManager.delete(speciesId0, notify: true), isTrue);
    expect(onDeleteInvoked, isTrue);
  });

  testWidgets("EntityListenerBuilder changesUpdatesState is false",
      (tester) async {
    int builderCallCount = 0;
    await pumpContext(
      tester,
      (_) => EntityListenerBuilder(
        managers: [entityManager],
        changesUpdatesState: false,
        builder: (_) {
          builderCallCount++;
          return const Empty();
        },
      ),
    );
    builderCallCount = 0; // Reset after initial build.

    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bluegill");
    await tester.pumpAndSettle();

    expect(builderCallCount, 0);
  });

  testWidgets("EntityListenerBuilder changesUpdatesState is true",
      (tester) async {
    int builderCallCount = 0;
    await pumpContext(
      tester,
      (_) => EntityListenerBuilder(
        managers: [entityManager],
        changesUpdatesState: true,
        builder: (_) {
          builderCallCount++;
          return const Empty();
        },
      ),
    );
    builderCallCount = 0; // Reset after initial build.

    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bluegill");
    await tester.pumpAndSettle();

    expect(builderCallCount, 1);
  });

  testWidgets("displayNameFromId entity doesn't exist", (tester) async {
    var context = await buildContext(tester);
    expect(
      entityManager.displayNameFromId(context, randomId()),
      isNull,
    );
    expect(
      entityManager.displayNameFromId(context, null),
      isNull,
    );
  });

  testWidgets("displayNameFromId entity exists", (tester) async {
    var id = randomId();
    await entityManager.addOrUpdate(Species(
      id: id,
      name: "Bluegill",
    ));

    expect(
      entityManager.displayNameFromId(await buildContext(tester), id),
      "Bluegill",
    );
  });
}
