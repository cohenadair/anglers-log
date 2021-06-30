import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.customEntityManager.list()).thenReturn([]);
  });

  testWidgets("Save button disabled when isInputValid = false", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          isInputValid: false,
        ),
      ),
    );
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);
  });

  testWidgets("Save button enabled when isInputValid = true", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          isInputValid: true,
        ),
      ),
    );
    expect(
        findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNotNull);
  });

  testWidgets("Save button hidden", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          showSaveButton: false,
        ),
      ),
    );
    expect(find.text("SAVE"), findsNothing);
  });

  testWidgets("Custom save button text", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          isInputValid: true,
          saveButtonText: "DONE",
        ),
      ),
    );
    expect(find.text("SAVE"), findsNothing);
    expect(find.text("DONE"), findsOneWidget);
  });

  testWidgets("Show loading widget instead of save button", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          isInputValid: true,
          showLoadingOverSave: true,
        ),
      ),
    );
    expect(find.text("SAVE"), findsNothing);
    expect(find.byType(Loading), findsOneWidget);
  });

  testWidgets("Editable form shows overflow menu", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage(
          fieldBuilder: (_) => {},
          isInputValid: true,
        ),
      ),
    );
    expect(find.byIcon(FormPage.moreMenuIcon), findsOneWidget);
  });

  testWidgets("Immutable form does not show overflow menu", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage.immutable(
          fieldBuilder: (_) => {},
          isInputValid: true,
        ),
      ),
    );
    expect(find.byIcon(FormPage.moreMenuIcon), findsNothing);
  });

  testWidgets("All form fields are built", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FormPage.immutable(
          fieldBuilder: (context) => {
            randomId(): TextInput.name(
              context,
              controller: TextInputController(),
            ),
            randomId(): TextInput.description(
              context,
              controller: TextInputController(),
            ),
            randomId(): TextInput.number(
              context,
              controller: NumberInputController(),
              label: "Age",
            ),
            randomId(): CheckboxInput(
              label: "Enabled",
            ),
          },
          isInputValid: true,
        ),
      ),
    );

    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
    expect(find.text("Age"), findsOneWidget);
    expect(find.text("Enabled"), findsOneWidget);
    expect(find.byType(TextInput), findsNWidgets(3));
    expect(find.byType(PaddedCheckbox), findsOneWidget);
  });

  testWidgets("Null onSave pops page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: null,
      ),
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("SAVE"), findsNothing);
  });

  testWidgets("onSave returns false does not pop page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: (_) => false,
      ),
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("SAVE"), findsOneWidget);
  });

  testWidgets("onSave returns true pops page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: (_) => true,
      ),
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("SAVE"), findsNothing);
  });

  testWidgets("Form state validation failing does not invoke onSave",
      (tester) async {
    var onFormSaveCalled = false;
    var onTextFieldSavedCalled = false;
    var validateCalled = false;
    await tester.pumpWidget(
      Testable(
        (_) => FormPage.immutable(
          fieldBuilder: (context) => {
            randomId(): TextFormField(
              validator: (_) {
                validateCalled = true;
                return "Invalid value";
              },
              onSaved: (_) => onTextFieldSavedCalled = true,
            ),
          },
          isInputValid: true,
          onSave: (_) => onFormSaveCalled = true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("SAVE"));

    expect(validateCalled, isTrue);
    expect(onFormSaveCalled, isFalse);
    expect(onTextFieldSavedCalled, isFalse);
  });

  testWidgets("Selection page shows all options", (tester) async {
    var nameId = randomId();
    var descriptionId = randomId();
    var ageId = randomId();
    var enabledId = randomId();

    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId: TextInput.name(
            context,
            controller: TextInputController(),
          ),
          descriptionId: TextInput.description(
            context,
            controller: TextInputController(),
          ),
          ageId: TextInput.number(
            context,
            controller: NumberInputController(),
            label: "Age",
          ),
          enabledId: CheckboxInput(
            label: "Enabled",
          ),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            name: "Name",
            used: true,
          ),
          FormPageFieldOption(
            id: nameId,
            name: "Description",
          ),
          FormPageFieldOption(
            id: nameId,
            name: "Age",
            used: true,
          ),
          FormPageFieldOption(
            id: nameId,
            name: "Enabled",
            removable: false,
          ),
        ],
        isInputValid: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.text("Select Fields"), findsOneWidget);

    expect(find.text("Name"), findsOneWidget);
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Name").checked,
        isTrue);

    expect(find.text("Description"), findsOneWidget);
    expect(
        findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Description")
            .checked,
        isFalse);

    expect(find.text("Age"), findsOneWidget);
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Age").checked,
        isTrue);

    expect(find.text("Enabled"), findsOneWidget);
    expect(
        findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Enabled").checked,
        isFalse);
    expect(findFirstWithText<ListItem>(tester, "Enabled").enabled, isFalse);

    expect(find.byType(PaddedCheckbox), findsNWidgets(4));
  });

  testWidgets("Selection page invokes onAddFields", (tester) async {
    var nameId = randomId();
    Set<Id>? selectedIds;
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId: TextInput.name(
            context,
            controller: TextInputController(),
          ),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            name: "Name",
            used: true,
          ),
        ],
        isInputValid: true,
        onAddFields: (ids) => selectedIds = ids,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));
    await tapAndSettle(tester, find.byType(CloseButton));

    expect(selectedIds, isNotNull);
    expect(selectedIds, isNotEmpty);
    expect(selectedIds!.length, 1);
    expect(selectedIds!.first, nameId);
  });

  testWidgets("Toggling fields removes them from callback", (tester) async {
    var nameId = randomId();
    Set<Id>? selectedIds;
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId: TextInput.name(
            context,
            controller: TextInputController(),
          ),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            name: "Name",
            used: true,
          ),
        ],
        isInputValid: true,
        onAddFields: (ids) => selectedIds = ids,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox));
    await tapAndSettle(tester, find.byType(CloseButton));

    // Note that FormPage isn't responsible for refreshing the state of the form
    // when new fields are picked. That falls on the widget using the FormPage.
    expect(selectedIds, isNotNull);
    expect(selectedIds, isEmpty);
    expect(find.text("Select Fields"), findsNothing);
  });

  testWidgets("Selection page add button opens save entity page",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {},
        isInputValid: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));
    await tapAndSettle(tester, find.widgetWithIcon(IconButton, Icons.add));

    expect(find.byType(SaveCustomEntityPage), findsOneWidget);
  });

  testWidgets("Custom fields included in form are shown on selection page",
      (tester) async {
    var customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Name"
      ..type = CustomEntity_Type.text;
    when(appManager.customEntityManager.list()).thenReturn([customEntity]);
    when(appManager.customEntityManager.entity(customEntityId))
        .thenReturn(customEntity);
    var context = await pumpContext(
      tester,
      (_) => FormPage(
        fieldBuilder: (context) => {
          customEntityId: TextInput.name(
            context,
            controller: TextInputController(),
          ),
        },
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId,
            name: customEntity.name,
          ),
        ],
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.noteText(context), findsNothing);
    expect(find.text("Name"), findsOneWidget);
  });

  testWidgets("Custom fields not included in form are shown on selection page",
      (tester) async {
    var customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Name"
      ..type = CustomEntity_Type.text;
    when(appManager.customEntityManager.list()).thenReturn([customEntity]);
    when(appManager.customEntityManager.entity(customEntityId))
        .thenReturn(customEntity);
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {},
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId,
            name: customEntity.name,
          ),
        ],
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.byType(IconLabel), findsNothing);
    expect(find.text("Name"), findsOneWidget);
  });

  testWidgets("Selection page custom fields are in alphabetical order",
      (tester) async {
    var customEntityId1 = randomId();
    var customEntityId2 = randomId();
    var customEntity1 = CustomEntity()
      ..id = customEntityId1
      ..name = "Name"
      ..type = CustomEntity_Type.text;
    var customEntity2 = CustomEntity()
      ..id = customEntityId2
      ..name = "Address"
      ..type = CustomEntity_Type.text;

    when(appManager.customEntityManager.list()).thenReturn([
      customEntity1,
      customEntity2,
    ]);
    when(appManager.customEntityManager.entity(customEntityId1))
        .thenReturn(customEntity1);
    when(appManager.customEntityManager.entity(customEntityId2))
        .thenReturn(customEntity2);

    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {},
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId1,
            name: customEntity1.name,
          ),
          FormPageFieldOption(
            id: customEntityId2,
            name: customEntity2.name,
          ),
        ],
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(
      find.descendant(
        of: find.byType(ListItem).at(0),
        matching: find.text("Address"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ListItem).at(1),
        matching: find.text("Name"),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Selection page no custom fields shows note", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (_) => {},
        isInputValid: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.byType(IconLabel), findsOneWidget);
  });
}
