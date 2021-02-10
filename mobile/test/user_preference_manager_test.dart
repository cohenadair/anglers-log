import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

void main() {
  MockAppManager appManager;

  UserPreferenceManager preferenceManager;

  setUp(() async {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockCustomEntityManager: true,
      mockDataManager: true,
      mockSubscriptionManager: true,
    );

    var stream = MockStream<DataManagerEvent>();
    when(stream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => stream);

    stream = MockStream<DataManagerEvent>();
    when(stream.listen(any)).thenReturn(null);
    when(appManager.mockDataManager.stream).thenAnswer((_) => stream);
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    preferenceManager = UserPreferenceManager(appManager);
  });

  test(
      "Custom entity IDs are deleted from preferences when custom entity "
      "objects are deleted", () async {
    var deleteEntity = CustomEntity()
      ..id = randomId()
      ..name = "Size"
      ..type = CustomEntity_Type.NUMBER;
    var realEntityManager = CustomEntityManager(appManager);
    await realEntityManager.addOrUpdate(deleteEntity);
    expect(realEntityManager.entityCount, 1);

    when(appManager.customEntityManager).thenReturn(realEntityManager);

    preferenceManager = UserPreferenceManager(appManager);
    preferenceManager.baitCustomEntityIds = [deleteEntity.id, randomId()];
    preferenceManager.catchCustomEntityIds = [deleteEntity.id];

    // Delete custom entity.
    await realEntityManager.delete(deleteEntity.id);
    expect(preferenceManager.baitCustomEntityIds.length, 1);
    expect(preferenceManager.catchCustomEntityIds.isEmpty, true);
  });

  test("Preferences are cleared when database is reset", () async {
    var database = MockDatabase();
    when(database.close()).thenAnswer((_) => Future.value());
    when(database.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).thenAnswer((_) => Future.value(1));
    when(database.delete(
      any,
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

    var id0 = randomId();
    var id1 = randomId();
    preferenceManager = UserPreferenceManager(appManager);
    preferenceManager.baitCustomEntityIds = [id0, id1];
    preferenceManager.catchCustomEntityIds = [id0];
    preferenceManager.baitFieldIds = [id1, id0];
    preferenceManager.catchFieldIds = [id1];
    preferenceManager.rateTimerStartedAt = 10000;
    preferenceManager.didRateApp = true;
    preferenceManager.didOnboard = true;
    preferenceManager.selectedReportId = id0;

    // Reset database.
    expectLater(realDataManager.stream, emits(DataManagerEvent.reset));
    await realDataManager.reset();

    // Use a delayed future to wait for the stream listener to finish.
    await Future.delayed(Duration(milliseconds: 100));

    expect(preferenceManager.baitCustomEntityIds, isEmpty);
    expect(preferenceManager.catchCustomEntityIds, isEmpty);
    expect(preferenceManager.baitFieldIds, isEmpty);
    expect(preferenceManager.catchFieldIds, isEmpty);
    expect(preferenceManager.rateTimerStartedAt, isNotNull);
    expect(preferenceManager.didRateApp, isTrue);
    expect(preferenceManager.didOnboard, isTrue);
    expect(preferenceManager.selectedReportId, isNull);
  });
}
