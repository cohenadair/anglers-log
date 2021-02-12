import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
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
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
    );

    var stream = MockStream<AuthState>();
    when(stream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => stream);

    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
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
}
