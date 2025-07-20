import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/custom_entity_values.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Empty input", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const CustomEntityValues(values: [])),
    );
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Value ID doesn't exist in manager", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CustomEntityValues(
          values: [CustomEntityValue()..customEntityId = randomId()],
        ),
      ),
    );
    when(managers.customEntityManager.entity(any)).thenReturn(null);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Normal use case", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    var id3 = randomId();

    when(managers.customEntityManager.entity(id1)).thenReturn(
      CustomEntity()
        ..name = "Entity 1"
        ..type = CustomEntity_Type.text,
    );
    when(managers.customEntityManager.entity(id2)).thenReturn(
      CustomEntity()
        ..name = "Entity 2"
        ..type = CustomEntity_Type.boolean,
    );
    when(managers.customEntityManager.entity(id3)).thenReturn(
      CustomEntity()
        ..name = "Entity 3"
        ..type = CustomEntity_Type.number,
    );

    await tester.pumpWidget(
      Testable(
        (_) => CustomEntityValues(
          values: [
            CustomEntityValue()
              ..customEntityId = id1
              ..value = "Test 1",
            CustomEntityValue()
              ..customEntityId = id2
              ..value = "true",
            CustomEntityValue()
              ..customEntityId = id3
              ..value = "150",
          ],
        ),
      ),
    );

    expect(find.byType(LabelValue), findsNWidgets(3));
    expect(find.text("Entity 1"), findsOneWidget);
    expect(find.text("Entity 2"), findsOneWidget);
    expect(find.text("Entity 3"), findsOneWidget);
    expect(find.text("Test 1"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("150"), findsOneWidget);
  });

  testWidgets("Condensed", (tester) async {
    var id1 = randomId();
    when(managers.customEntityManager.entity(id1)).thenReturn(
      CustomEntity()
        ..name = "Entity 1"
        ..type = CustomEntity_Type.text,
    );
    when(
      managers.customEntityManager.customValuesDisplayValue(any, any),
    ).thenReturn("Entity 1: Test 1");

    var context = await pumpContext(
      tester,
      (_) => CustomEntityValues(
        values: [
          CustomEntityValue()
            ..customEntityId = id1
            ..value = "Test 1",
        ],
        isSingleLine: true,
      ),
    );

    expect(find.byType(LabelValue), findsNothing);
    expect(
      find.subtitleText(context, text: "Entity 1: Test 1"),
      findsOneWidget,
    );
  });
}
