import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late UserPreferenceManager preferenceManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    preferenceManager = UserPreferenceManager(appManager.app);
  });

  test(
      "Custom entity IDs are deleted from preferences when custom entity "
      "objects are deleted", () async {
    var deleteEntity = CustomEntity()
      ..id = randomId()
      ..name = "Size"
      ..type = CustomEntity_Type.number;
    var realEntityManager = CustomEntityManager(appManager.app);
    await realEntityManager.addOrUpdate(deleteEntity);
    expect(realEntityManager.entityCount, 1);

    when(appManager.app.customEntityManager).thenReturn(realEntityManager);

    preferenceManager = UserPreferenceManager(appManager.app);
    preferenceManager.baitCustomEntityIds = [deleteEntity.id, randomId()];
    preferenceManager.catchCustomEntityIds = [deleteEntity.id];

    // Delete custom entity.
    await realEntityManager.delete(deleteEntity.id);
    expect(preferenceManager.baitCustomEntityIds.length, 1);
    expect(preferenceManager.catchCustomEntityIds.isEmpty, true);
  });
}
