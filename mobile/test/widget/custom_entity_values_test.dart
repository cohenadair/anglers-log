import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/custom_entity_values.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockCustomEntityManager: true,
    );
  });

  testWidgets("Null input", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => CustomEntityValues(null),
        appManager: appManager));
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Empty input", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => CustomEntityValues([]),
        appManager: appManager));
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Value ID doesn't exist in manager", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => CustomEntityValues([
      CustomEntityValue()..customEntityId = randomId(),
    ]), appManager: appManager));
    when(appManager.mockCustomEntityManager.entity(any)).thenReturn(null);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Normal use case", (WidgetTester tester) async {
    Id id1 = randomId();
    Id id2 = randomId();
    Id id3 = randomId();

    when(appManager.mockCustomEntityManager.entity(id1)).thenReturn(
        CustomEntity()
          ..name = "Entity 1"
          ..type = CustomEntity_Type.TEXT);
    when(appManager.mockCustomEntityManager.entity(id2)).thenReturn(
        CustomEntity()
          ..name = "Entity 2"
          ..type = CustomEntity_Type.BOOL);
    when(appManager.mockCustomEntityManager.entity(id3)).thenReturn(
        CustomEntity()
          ..name = "Entity 3"
          ..type = CustomEntity_Type.NUMBER);

    await tester.pumpWidget(Testable((_) => CustomEntityValues([
      CustomEntityValue()
        ..customEntityId = id1
        ..value = "Test 1",
      CustomEntityValue()
        ..customEntityId = id2
        ..value = "1",
      CustomEntityValue()
        ..customEntityId = id3
        ..value = "150",
    ]), appManager: appManager));

    expect(find.byType(LabelValue), findsNWidgets(3));
    expect(find.text("Entity 1"), findsOneWidget);
    expect(find.text("Entity 2"), findsOneWidget);
    expect(find.text("Entity 3"), findsOneWidget);
    expect(find.text("Test 1"), findsOneWidget);
    expect(find.text("Yes"), findsOneWidget);
    expect(find.text("150"), findsOneWidget);
  });
}