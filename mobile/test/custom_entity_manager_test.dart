import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late CustomEntityManager customEntityManager;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    customEntityManager = CustomEntityManager(managers.app);
  });

  testWidgets("customValuesDisplayValue", (tester) async {
    var context = await buildContext(tester);

    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    await customEntityManager.addOrUpdate(CustomEntity(
      id: id0,
      name: "Entity 0",
      type: CustomEntity_Type.text,
    ));
    await customEntityManager.addOrUpdate(CustomEntity(
      id: id1,
      name: "Entity 1",
      type: CustomEntity_Type.text,
    ));
    await customEntityManager.addOrUpdate(CustomEntity(
      id: id2,
      name: "Entity 2",
      type: CustomEntity_Type.text,
    ));

    var values = <CustomEntityValue>[
      CustomEntityValue(
        customEntityId: id0,
        value: "Value 0",
      ),
      CustomEntityValue(
        customEntityId: randomId(),
        value: "Random Value",
      ),
      CustomEntityValue(
        customEntityId: id2,
        value: "Value 2",
      ),
    ];
    var displayValue =
        customEntityManager.customValuesDisplayValue(values, context);

    expect(displayValue, isNotEmpty);
    expect(displayValue, "Entity 0: Value 0, Entity 2: Value 2");
  });
}
