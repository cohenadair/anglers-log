import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late UserPreferenceManager preferenceManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());
    when(appManager.authManager.firestoreDocPath).thenAnswer((_) => "usr");

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    preferenceManager = UserPreferenceManager(appManager.app);
  });

  testWidgets(
      "Custom entity IDs are deleted from preferences when custom entity "
      "objects are deleted", (tester) async {
    var deleteEntity = CustomEntity()
      ..id = randomId()
      ..name = "Size"
      ..type = CustomEntity_Type.number;
    var realEntityManager = CustomEntityManager(appManager.app);
    await realEntityManager.addOrUpdate(deleteEntity);
    expect(realEntityManager.entityCount, 1);

    when(appManager.app.customEntityManager).thenReturn(realEntityManager);

    var doc = MockDocumentReference();

    var map = <String, dynamic>{};
    var snapshot = MockDocumentSnapshot();
    when(snapshot.data()).thenReturn(map);

    var stream = MockStream<MockDocumentSnapshot>();
    when(appManager.firestoreWrapper.doc(any)).thenReturn(doc);

    Function(DocumentSnapshot)? listener;
    when(stream.listen(any)).thenAnswer(((invocation) {
      listener = invocation.positionalArguments.first;
      listener!(snapshot);
      return MockStreamSubscription<MockDocumentSnapshot>();
    }));
    when(doc.snapshots()).thenAnswer((_) => stream);

    preferenceManager = UserPreferenceManager(appManager.app);
    await preferenceManager.initialize();

    // Verify Firestore listener is setup correctly.
    expect(listener, isNotNull);

    when(snapshot.exists).thenReturn(true);
    when(doc.get()).thenAnswer((_) => Future.value(snapshot));
    when(doc.update(any)).thenAnswer((invocation) {
      map..addAll(invocation.positionalArguments.first);
      return Future.value();
    });

    await preferenceManager
        .setBaitCustomEntityIds([deleteEntity.id, randomId()]);
    expect(map, isNotEmpty);

    // Trust Firestore listeners will work and invoke listener manually.
    listener!(snapshot);
    expect(preferenceManager.baitCustomEntityIds.length, 2);

    await preferenceManager.setCatchCustomEntityIds([deleteEntity.id]);
    expect(map, isNotEmpty);

    // Trust Firestore listeners will work and invoke listener manually.
    listener!(snapshot);
    expect(preferenceManager.catchCustomEntityIds.length, 1);

    await tester.runAsync(() async {
      // Delete custom entity.
      await realEntityManager.delete(deleteEntity.id);

      // Give some time for listeners to to be invoked.
      await Future.delayed(Duration(milliseconds: 50));

      // Trust Firestore listeners will work and invoke listener manually.
      listener!(snapshot);

      expect(preferenceManager.baitCustomEntityIds.length, 1);
      expect(preferenceManager.catchCustomEntityIds.isEmpty, true);
    });
  });
}
