import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockCustomEntityManager: true,
    );

    when(appManager.mockCustomEntityManager.list()).thenReturn([]);
  });

  testWidgets("Note shows when there are no custom values",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(),
      appManager: appManager,
    ));
    expect(find.byType(IconNoteLabel), findsOneWidget);
  });

  testWidgets("Custom fields without values", (tester) async {
    var customEntity = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field 1"
      ..type = CustomEntity_Type.TEXT;
    when(appManager.mockCustomEntityManager.entity(any))
        .thenReturn(customEntity);

    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        customEntityIds: [
          customEntity.id,
        ],
      ),
      appManager: appManager,
    ));
    expect(find.byType(IconNoteLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);
  });

  testWidgets("CustomEntityValue that doesn't exist in fields is still added",
      (tester) async {
    when(appManager.mockCustomEntityManager.entity(any)).thenReturn(
      CustomEntity()
        ..id = randomId()
        ..name = "Custom Field 1"
        ..type = CustomEntity_Type.TEXT,
    );
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = randomId()
            ..value = "Test",
        ],
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconNoteLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);
    expect(find.widgetWithText(TextField, "Test"), findsOneWidget);
  });

  testWidgets("Hidden fields are not shown", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        fields: {
          id1: InputData(
            id: id1,
            controller: TextInputController(),
            label: (_) => "Input 1",
            showing: false,
          ),
          id2: InputData(
            id: id2,
            controller: TextInputController(),
            label: (_) => "Input 2",
            showing: true,
          ),
        },
        onBuildField: (id) => Text(id.toString()),
      ),
      appManager: appManager,
    ));

    expect(find.text(id1.toString()), findsNothing);
    expect(find.text(id2.toString()), findsOneWidget);
  });

  testWidgets("Field selection excludes fake InputData", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        fields: {
          id1: InputData(
            id: id1,
            controller: TextInputController(),
            label: (_) => "Input 1",
            showing: true,
          ),
          id2: InputData(
            id: id2,
            controller: TextInputController(),
            label: (_) => "Input 2",
            showing: true,
          ),
        },
        onBuildField: (id) => Text(id.toString()),
      ),
      appManager: appManager,
    ));

    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsOneWidget);
    expect(find.text("Custom Fields"), findsOneWidget);

    await tapAndSettle(
        tester, find.widgetWithIcon(IconButton, Icons.more_vert));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.text("Input 1"), findsOneWidget);
    expect(find.text("Input 2"), findsOneWidget);
    expect(find.byType(ListItem), findsNWidgets(2));
  });

  testWidgets("Selecting hidden field updates state to show field",
      (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        fields: {
          id1: InputData(
            id: id1,
            controller: TextInputController(),
            label: (_) => "Input 1",
            showing: false,
          ),
          id2: InputData(
            id: id2,
            controller: TextInputController(),
            label: (_) => "Input 2",
            showing: true,
          ),
        },
        onBuildField: (id) => Text(id.toString()),
      ),
      appManager: appManager,
    ));

    expect(find.text(id1.toString()), findsNothing);
    expect(find.text(id2.toString()), findsOneWidget);

    await tapAndSettle(
        tester, find.widgetWithIcon(IconButton, Icons.more_vert));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.text("Input 1"), findsOneWidget);
    expect(find.text("Input 2"), findsOneWidget);

    // Select and deselect items.
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "Input 1"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "Input 2"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.text("DONE"));

    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsNothing);
  });

  testWidgets("Adding a new custom field updates state and shows field",
      (tester) async {
    var customEntity = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field 1"
      ..type = CustomEntity_Type.TEXT;
    when(appManager.mockCustomEntityManager.list()).thenReturn([
      customEntity,
    ]);
    when(appManager.mockCustomEntityManager.entity(any))
        .thenReturn(customEntity);

    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(),
      appManager: appManager,
    ));

    // Select a custom field that doesn't already exist in the form.
    await tapAndSettle(
        tester, find.widgetWithIcon(IconButton, Icons.more_vert));
    await tapAndSettle(tester, find.text("Manage Fields"));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "Custom Field 1"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.text("DONE"));

    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);
  });

  testWidgets("Callback invoked with correct values",
      (tester) async {
    Map<Id, dynamic> onSaveMap;
    when(appManager.mockCustomEntityManager.entity(any)).thenReturn(
      CustomEntity()
        ..id = randomId()
        ..name = "Custom Field 1"
        ..type = CustomEntity_Type.TEXT,
    );
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = randomId()
            ..value = "Test",
        ],
        onSave: (result) {
          onSaveMap = result;
          return false;
        },
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconNoteLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Test"), "Test 2");
    await tapAndSettle(tester, find.text("SAVE"));

    expect(onSaveMap, isNotNull);
    expect(onSaveMap.values.first is String, isTrue);
    expect(onSaveMap.values.first, "Test 2");
  });
}
