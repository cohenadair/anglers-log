import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late CustomEntityManager customEntityManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    customEntityManager = CustomEntityManager(appManager.app);
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
