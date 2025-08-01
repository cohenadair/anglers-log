import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.customEntityManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(false));
    when(managers.customEntityManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveCustomEntityPage()));
    expect(find.text("New Field"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveCustomEntityPage.edit(CustomEntity()..id = randomId()),
      ),
    );
    expect(find.text("Edit Field"), findsOneWidget);
  });

  testWidgets("Save button state updates when name changes", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveCustomEntityPage()));

    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "Water Depth",
    );
    expect(
      findFirstWithText<ActionButton>(tester, "SAVE").onPressed,
      isNotNull,
    );
  });

  testWidgets("All type options are rendered", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveCustomEntityPage()));

    expect(find.text("Number"), findsOneWidget);
    expect(find.text("Checkbox"), findsOneWidget);
    expect(find.text("Text"), findsOneWidget);
  });

  testWidgets("Editing", (tester) async {
    var entity = CustomEntity()
      ..id = randomId()
      ..name = "Water Depth"
      ..description = "How deep the water is."
      ..type = CustomEntity_Type.number;

    await tester.pumpWidget(Testable((_) => SaveCustomEntityPage.edit(entity)));

    expect(find.widgetWithText(TextField, "Water Depth"), findsOneWidget);
    expect(
      find.widgetWithText(TextField, "How deep the water is."),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(InkWell, "Number"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Description"),
      "A description.",
    );
    await tapAndSettle(tester, find.text("Checkbox"));
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.customEntityManager.addOrUpdate(captureAny));
    result.called(1);

    CustomEntity newEntity = result.captured.first;
    expect(newEntity.id, entity.id);
    expect(newEntity.name, "Water Depth");
    expect(newEntity.type, CustomEntity_Type.boolean);
    expect(newEntity.description, "A description.");
  });

  testWidgets("New with minimum properties", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveCustomEntityPage()));

    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Name"),
      "A Name",
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.customEntityManager.addOrUpdate(captureAny));
    result.called(1);

    CustomEntity newEntity = result.captured.first;
    expect(newEntity.name, "A Name");
    expect(newEntity.type, CustomEntity_Type.number);
    expect(newEntity.hasDescription(), isFalse);
  });
}
