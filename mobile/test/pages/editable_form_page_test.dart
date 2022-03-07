import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/pro_overlay.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.customEntityManager.list()).thenReturn([]);
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);
  });

  testWidgets("Custom fields hidden", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        allowCustomEntities: false,
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = randomId()
            ..value = "Test",
        ],
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsNothing);
    expect(find.widgetWithText(TextField, "Test"), findsNothing);
  });

  testWidgets("Note shows when there are no custom values", (tester) async {
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);
    await tester.pumpWidget(Testable(
      (_) => const EditableFormPage(),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsOneWidget);
  });

  testWidgets("Custom fields without values", (tester) async {
    var customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Custom Field 1"
      ..type = CustomEntity_Type.text;
    when(appManager.customEntityManager.entity(any)).thenReturn(customEntity);
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        trackedFieldIds: [
          customEntity.id,
        ],
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);
    expect(find.byType(ProOverlay), findsOneWidget);
  });

  testWidgets("CustomEntityValue that doesn't exist in fields is still added",
      (tester) async {
    var customEntityId = randomId();
    when(appManager.customEntityManager.entity(any)).thenReturn(
      CustomEntity()
        ..id = customEntityId
        ..name = "Custom Field 1"
        ..type = CustomEntity_Type.text,
    );
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = customEntityId
            ..value = "Test",
        ],
        trackedFieldIds: [
          customEntityId,
        ],
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);
    expect(find.widgetWithText(TextField, "Test"), findsOneWidget);
  });

  testWidgets("Hidden fields are not shown", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        fields: {
          id1: Field(
            id: id1,
            controller: TextInputController(),
            name: (_) => "Input 1",
            isShowing: false,
          ),
          id2: Field(
            id: id2,
            controller: TextInputController(),
            name: (_) => "Input 2",
            isShowing: true,
          ),
        },
        onBuildField: (id) => Text(id.toString()),
      ),
      appManager: appManager,
    ));

    expect(find.text(id1.toString()), findsNothing);
    expect(find.text(id2.toString()), findsOneWidget);
  });

  testWidgets("Field selection excludes fake fields", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        fields: {
          id1: Field(
            id: id1,
            controller: TextInputController(),
            name: (_) => "Input 1",
            isShowing: true,
          ),
          id2: Field(
            id: id2,
            controller: TextInputController(),
            name: (_) => "Input 2",
            isShowing: true,
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
          id1: Field(
            id: id1,
            controller: TextInputController(),
            name: (_) => "Input 1",
            isShowing: false,
          ),
          id2: Field(
            id: id2,
            controller: TextInputController(),
            name: (_) => "Input 2",
            isShowing: true,
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
    await tapAndSettle(tester, find.byType(CloseButton));

    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsNothing);
  });

  testWidgets("Adding a new custom field updates state and shows field",
      (tester) async {
    var customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Custom Field 1"
      ..type = CustomEntity_Type.boolean;
    when(appManager.customEntityManager.list()).thenReturn([
      customEntity,
    ]);
    when(appManager.customEntityManager.entity(customEntityId))
        .thenReturn(customEntity);
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);

    var called = false;
    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        onAddFields: (_) => called = true,
      ),
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
    await tapAndSettle(tester, find.byType(CloseButton));

    expect(called, isTrue);
    expect(
      find.widgetWithText(CheckboxInput, "Custom Field 1"),
      findsOneWidget,
    );

    var padding = tester.widget<Padding>(find
        .ancestor(
          of: find.byType(CheckboxInput),
          matching: find.byType(Padding),
        )
        .first);
    expect(padding.padding, insetsZero);
  });

  testWidgets("Callback invoked with correct values", (tester) async {
    var customEntityId = randomId();
    when(appManager.customEntityManager.entity(any)).thenReturn(
      CustomEntity()
        ..id = customEntityId
        ..name = "Custom Field 1"
        ..type = CustomEntity_Type.text,
    );
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);

    Map<Id, dynamic>? onSaveMap;

    await tester.pumpWidget(Testable(
      (_) => EditableFormPage(
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = customEntityId
            ..value = "Test",
        ],
        trackedFieldIds: [
          customEntityId,
        ],
        onSave: (result) {
          onSaveMap = result;
          return false;
        },
      ),
      appManager: appManager,
    ));

    expect(find.byType(IconLabel), findsNothing);
    expect(find.widgetWithText(TextField, "Custom Field 1"), findsOneWidget);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Test"), "Test 2");
    await tapAndSettle(tester, find.text("SAVE"));

    expect(onSaveMap, isNotNull);
    expect(onSaveMap!.values.first is String, isTrue);
    expect(onSaveMap!.values.first, "Test 2");
  });

  testWidgets("Field descriptions are rendered", (tester) async {
    var custom1 = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field 1"
      ..description = "A test description."
      ..type = CustomEntity_Type.text;
    var custom2 = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field 2"
      ..type = CustomEntity_Type.text;

    when(appManager.customEntityManager.entity(custom1.id)).thenReturn(custom1);
    when(appManager.customEntityManager.entity(custom2.id)).thenReturn(custom2);
    when(appManager.customEntityManager.entityExists(custom1.id))
        .thenReturn(true);
    when(appManager.customEntityManager.entityExists(custom2.id))
        .thenReturn(true);

    var id1 = randomId();
    var id2 = randomId();
    var id3 = randomId();

    var context = await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: {
          // Shows "Required" subtitle.
          id1: Field(
            id: id1,
            controller: TextInputController(),
            name: (_) => "Input 1",
            isRemovable: false,
          ),
          // Shows "Input 2 description" subtitle.
          id2: Field(
            id: id2,
            controller: TextInputController(),
            name: (_) => "Input 2",
            description: (_) => "Input 2 description.",
            isRemovable: true,
          ),
          // Shows no subtitle.
          id3: Field(
            id: id3,
            controller: TextInputController(),
            name: (_) => "Input 3",
          ),
        },
        onBuildField: (id) => Text(id.toString()),
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = custom1.id
            ..value = "Test 1",
          CustomEntityValue()
            ..customEntityId = custom2.id
            ..value = "Test 2",
        ],
      ),
      appManager: appManager,
    );

    // Open field picker.
    await tapAndSettle(
        tester, find.widgetWithIcon(IconButton, Icons.more_vert));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.subtitleText(context), findsNWidgets(3));
    expect(find.text("Required"), findsOneWidget);
    expect(find.text("Input 2 description."), findsOneWidget);
    expect(find.text("A test description."), findsOneWidget);
  });

  testWidgets("onCustomFieldChanged invoked", (tester) async {
    var custom1 = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field"
      ..type = CustomEntity_Type.boolean;
    when(appManager.customEntityManager.entity(custom1.id)).thenReturn(custom1);
    when(appManager.customEntityManager.entityExists(custom1.id))
        .thenReturn(true);

    var invoked = false;
    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: const {},
        onBuildField: (id) => Text(id.toString()),
        customEntityValues: [
          CustomEntityValue()
            ..customEntityId = custom1.id
            ..value = "true",
        ],
        onCustomFieldChanged: (_) => invoked = true,
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byType(PaddedCheckbox));
    expect(invoked, isTrue);
  });

  testWidgets("Custom field header shows note when editable", (tester) async {
    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: const {},
        onBuildField: (_) => const Empty(),
        isEditable: true,
      ),
      appManager: appManager,
    );
    expect(find.byType(HeadingNoteDivider), findsOneWidget);
  });

  testWidgets("Custom field header hides note when editable", (tester) async {
    var custom1 = CustomEntity()
      ..id = randomId()
      ..name = "Custom Field"
      ..type = CustomEntity_Type.text;
    when(appManager.customEntityManager.entity(custom1.id)).thenReturn(custom1);
    when(appManager.customEntityManager.entityExists(custom1.id))
        .thenReturn(true);

    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: const {},
        onBuildField: (id) => Text(id.toString()),
        trackedFieldIds: [
          custom1.id,
        ],
        isEditable: false,
      ),
      appManager: appManager,
    );

    expect(find.byType(HeadingNoteDivider), findsNothing);
    expect(find.byType(HeadingDivider), findsOneWidget);
  });

  testWidgets("No custom fields hides header", (tester) async {
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: const {},
        onBuildField: (id) => Text(id.toString()),
        isEditable: false,
      ),
      appManager: appManager,
    );

    expect(find.byType(HeadingNoteDivider), findsNothing);
    expect(find.byType(HeadingDivider), findsNothing);
  });

  testWidgets("All fields show if trackedFieldIds is empty", (tester) async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: {
          id0: Field(
            id: id0,
            controller: InputController(),
          ),
          id1: Field(
            id: id1,
            controller: InputController(),
          ),
          id2: Field(
            id: id2,
            controller: InputController(),
          ),
        },
        onBuildField: (id) => Text(id.toString()),
        trackedFieldIds: const [],
      ),
      appManager: appManager,
    );

    expect(find.text(id0.toString()), findsOneWidget);
    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsOneWidget);
  });

  testWidgets("Only fields trackedFieldIds are shown", (tester) async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: {
          id0: Field(
            id: id0,
            controller: InputController(),
          ),
          id1: Field(
            id: id1,
            controller: InputController(),
          ),
          id2: Field(
            id: id2,
            controller: InputController(),
          ),
        },
        onBuildField: (id) => Text(id.toString()),
        trackedFieldIds: [
          id1,
          id2,
        ],
      ),
      appManager: appManager,
    );

    expect(find.text(id0.toString()), findsNothing);
    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsOneWidget);
  });

  testWidgets("Field.isShowing=false hides fields", (tester) async {
    var id0 = randomId();
    var id1 = randomId();
    var id2 = randomId();

    await pumpContext(
      tester,
      (_) => EditableFormPage(
        fields: {
          id0: Field(
            id: id0,
            controller: InputController(),
            isShowing: false,
          ),
          id1: Field(
            id: id1,
            controller: InputController(),
          ),
          id2: Field(
            id: id2,
            controller: InputController(),
          ),
        },
        onBuildField: (id) => Text(id.toString()),
        trackedFieldIds: const [],
      ),
      appManager: appManager,
    );

    expect(find.text(id0.toString()), findsNothing);
    expect(find.text(id1.toString()), findsOneWidget);
    expect(find.text(id2.toString()), findsOneWidget);
  });
}
