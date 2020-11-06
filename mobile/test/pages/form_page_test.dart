import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockCustomEntityManager: true,
    );

    when(appManager.mockCustomEntityManager.list()).thenReturn([]);
  });

  testWidgets("Save button disabled when isInputValid = false",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable((_) => FormPage(
      fieldBuilder: (_) => {},
      isInputValid: false,
    )));
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);
  });

  testWidgets("Save button enabled when isInputValid = true",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable((_) => FormPage(
      fieldBuilder: (_) => {},
      isInputValid: true,
    )));
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed,
        isNotNull);
  });

  testWidgets("Custom save button text", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FormPage(
      fieldBuilder: (_) => {},
      isInputValid: true,
      saveButtonText: "DONE",
    )));
    expect(find.text("SAVE"), findsNothing);
    expect(find.text("DONE"), findsOneWidget);
  });

  testWidgets("Editable form shows overflow menu", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FormPage(
      fieldBuilder: (_) => {},
      isInputValid: true,
    )));
    expect(find.byIcon(FormPage.moreMenuIcon), findsOneWidget);
  });

  testWidgets("Immutable form does not show overflow menu",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable((_) => FormPage.immutable(
      fieldBuilder: (_) => {},
      isInputValid: true,
    )));
    expect(find.byIcon(FormPage.moreMenuIcon), findsNothing);
  });

  testWidgets("All form fields are built", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FormPage.immutable(
      fieldBuilder: (context) => {
        randomId() : TextInput.name(context),
        randomId() : TextInput.description(context),
        randomId() : TextInput.number(
          context,
          label: "Age",
        ),
        randomId() : CheckboxInput(
          label: "Enabled",
        ),
      },
      isInputValid: true,
    )));

    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
    expect(find.text("Age"), findsOneWidget);
    expect(find.text("Enabled"), findsOneWidget);
    expect(find.byType(TextInput), findsNWidgets(3));
    expect(find.byType(PaddedCheckbox), findsOneWidget);
  });

  testWidgets("Null onSave does pops page", (WidgetTester tester) async {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: null,
      ),
      navigatorObserver: navObserver,
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    verify(navObserver.didPop(any, any)).called(1);
  });

  testWidgets("onSave returns false does not pop page", (WidgetTester tester)
      async
  {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: (_) => false,
      ),
      navigatorObserver: navObserver,
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    verifyNever(navObserver.didPop(any, any));
  });

  testWidgets("onSave returns true pops page", (WidgetTester tester) async {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FormPage.immutable(
        fieldBuilder: (_) => {},
        isInputValid: true,
        onSave: (_) => true,
      ),
      navigatorObserver: navObserver,
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    verify(navObserver.didPop(any, any)).called(1);
  });

  testWidgets("Form state validation failing does not invoke onSave",
      (WidgetTester tester) async
  {
    bool onFormSaveCalled = false;
    bool onTextFieldSavedCalled = false;
    bool validateCalled = false;
    await tester.pumpWidget(Testable((_) => FormPage.immutable(
      fieldBuilder: (context) => {
        randomId() : TextFormField(
          validator: (_) {
            validateCalled =  true;
            return "Invalid value";
          },
          onSaved: (_) => onTextFieldSavedCalled = true,
        ),
      },
      isInputValid: true,
      onSave: (_) => onFormSaveCalled = true,
    )));

    await tapAndSettle(tester, find.text("SAVE"));

    expect(validateCalled, isTrue);
    expect(onFormSaveCalled, isFalse);
    expect(onTextFieldSavedCalled, isFalse);
  });

  testWidgets("Selection page shows all options", (WidgetTester tester) async {
    Id nameId = randomId();
    Id descriptionId = randomId();
    Id ageId = randomId();
    Id enabledId = randomId();

    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId : TextInput.name(context),
          descriptionId : TextInput.description(context),
          ageId : TextInput.number(
            context,
            label: "Age",
          ),
          enabledId : CheckboxInput(
            label: "Enabled",
          ),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Name",
            used: true,
          ),
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Description",
          ),
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Age",
            used: true,
          ),
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Enabled",
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
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Description")
        .checked, isFalse);

    expect(find.text("Age"), findsOneWidget);
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Age").checked,
        isTrue);

    expect(find.text("Enabled"), findsOneWidget);
    expect(findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Enabled")
        .checked, isFalse);
    expect(findFirstWithText<ListItem>(tester, "Enabled").enabled, isFalse);

    expect(find.byType(PaddedCheckbox), findsNWidgets(4));
  });

  testWidgets("Selection page invokes onAddFields", (WidgetTester tester) async
  {
    Id nameId = randomId();
    Set<Id> selectedIds;
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId : TextInput.name(context),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Name",
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
    await tapAndSettle(tester, find.text("DONE"));

    expect(selectedIds, isNotNull);
    expect(selectedIds, isNotEmpty);
    expect(selectedIds.length, 1);
    expect(selectedIds.first, nameId);
  });

  testWidgets("Toggling fields removes them from callback",
      (WidgetTester tester) async
  {
    Id nameId = randomId();
    Set<Id> selectedIds;
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          nameId : TextInput.name(context),
        },
        addFieldOptions: [
          FormPageFieldOption(
            id: nameId,
            userFacingName: "Name",
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
    await tapAndSettle(tester, find.text("DONE"));

    // Note that FormPage isn't responsible for refreshing the state of the form
    // when new fields are picked. That falls on the widget using the FormPage.
    expect(selectedIds, isNotNull);
    expect(selectedIds, isEmpty);
    expect(find.text("Select Fields"), findsNothing);
  });

  testWidgets("Selection page add button opens save entity page",
      (WidgetTester tester) async
  {
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
      (WidgetTester tester) async
  {
    Id customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Name"
      ..type = CustomEntity_Type.TEXT;
    when(appManager.mockCustomEntityManager.list()).thenReturn([
      customEntity
    ]);
    when(appManager.mockCustomEntityManager.entity(customEntityId))
        .thenReturn(customEntity);
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {
          customEntityId: TextInput.name(context),
        },
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId,
            userFacingName: customEntity.name,
          ),
        ],
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.byType(NoteLabel), findsNothing);
    expect(find.text("Name"), findsOneWidget);
  });

  testWidgets("Custom fields not included in form are shown on selection page",
      (WidgetTester tester) async
  {
    Id customEntityId = randomId();
    var customEntity = CustomEntity()
      ..id = customEntityId
      ..name = "Name"
      ..type = CustomEntity_Type.TEXT;
    when(appManager.mockCustomEntityManager.list()).thenReturn([
      customEntity
    ]);
    when(appManager.mockCustomEntityManager.entity(customEntityId))
        .thenReturn(customEntity);
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {},
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId,
            userFacingName: customEntity.name,
          ),
        ],
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.byType(IconNoteLabel), findsNothing);
    expect(find.text("Name"), findsOneWidget);
  });

  testWidgets("Selection page custom fields are in alphabetical order",
      (WidgetTester tester) async
  {
    Id customEntityId1 = randomId();
    Id customEntityId2 = randomId();
    var customEntity1 = CustomEntity()
      ..id = customEntityId1
      ..name = "Name"
      ..type = CustomEntity_Type.TEXT;
    var customEntity2 = CustomEntity()
      ..id = customEntityId2
      ..name = "Address"
      ..type = CustomEntity_Type.TEXT;

    when(appManager.mockCustomEntityManager.list()).thenReturn([
      customEntity1, customEntity2,
    ]);
    when(appManager.mockCustomEntityManager.entity(customEntityId1))
        .thenReturn(customEntity1);
    when(appManager.mockCustomEntityManager.entity(customEntityId2))
        .thenReturn(customEntity2);

    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (context) => {},
        isInputValid: true,
        addFieldOptions: [
          FormPageFieldOption(
            id: customEntityId1,
            userFacingName: customEntity1.name,
          ),
          FormPageFieldOption(
            id: customEntityId2,
            userFacingName: customEntity2.name,
          ),
        ],
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.descendant(
      of: find.byType(ListItem).at(0),
      matching: find.text("Address"),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(ListItem).at(1),
      matching: find.text("Name"),
    ), findsOneWidget);
  });

  testWidgets("Selection page no custom fields shows note",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => FormPage(
        fieldBuilder: (_) => {},
        isInputValid: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Manage Fields"));

    expect(find.byType(IconNoteLabel), findsOneWidget);
  });
}