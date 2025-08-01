import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late MockQuantityPickerInputDelegate<Species, Trip_CatchesPerEntity> delegate;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.speciesManager.listSortedByDisplayName(any)).thenReturn([
      Species(id: randomId(), name: "Trout"),
      Species(id: randomId(), name: "Catfish"),
      Species(id: randomId(), name: "Bass"),
    ]);

    delegate =
        MockQuantityPickerInputDelegate<Species, Trip_CatchesPerEntity>();
  });

  stubDefaultDelegate() {
    var controller = SetInputController<Trip_CatchesPerEntity>();
    controller.value = {Trip_CatchesPerEntity(entityId: randomId(), value: 5)};

    when(delegate.controller).thenReturn(controller);
    when(delegate.inputTypeHasValue(any)).thenReturn(true);
    when(delegate.inputTypeValue(any)).thenReturn(5);
    when(delegate.inputTypeEntityExists(any)).thenReturn(true);
    when(delegate.inputTypeEntityDisplayName(any, any)).thenReturn("Name");
    when(delegate.pickerTypeInitialValues).thenReturn(<Species>{});
    when(delegate.pickerPage(any)).thenAnswer(
      (invocation) =>
          SpeciesListPage(pickerSettings: invocation.positionalArguments.first),
    );
  }

  testWidgets("Empty controller shows list item; hides divider", (
    tester,
  ) async {
    when(
      delegate.controller,
    ).thenReturn(SetInputController<Trip_CatchesPerEntity>());

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    var children = findFirst<Column>(tester).children;
    expect(children.length, 3);
    expect(children[0] is SizedBox, isTrue);
    expect(((children[1] as ListItem).title as Text).style, isNull);
    expect(children[2] is SizedBox, isTrue);
  });

  testWidgets("Non-empty controller heading; divider; content", (tester) async {
    stubDefaultDelegate();

    var context = await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    var children = findFirst<Column>(tester).children;
    expect(children.length, 3);
    expect(children[0] is MinDivider, isTrue);
    expect(
      ((children[1] as ListItem).title as Text).style,
      styleListHeading(context),
    );
    expect(children[2] is Padding, isTrue);
  });

  testWidgets("Delegate has no value; shows placeholder", (tester) async {
    stubDefaultDelegate();
    when(delegate.inputTypeValue(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    expect(find.widgetWithText(TextInput, "0"), findsOneWidget);
  });

  testWidgets("Invalid label shows Empty widget", (tester) async {
    stubDefaultDelegate();
    when(delegate.inputTypeEntityDisplayName(any, any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    var children = findFirst<Column>(tester).children;
    expect(children.length, 3);
    expect(
      ((children[2] as Padding).child as Column).children[0] is SizedBox,
      isTrue,
    );
  });

  testWidgets("Entering non-number sets controller to null", (tester) async {
    stubDefaultDelegate();

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    await enterTextAndSettle(tester, find.byType(TextInput), "Non-number");
    verify(delegate.clearValue(any)).called(1);
    verifyNever(delegate.updateValue(any, any));
  });

  testWidgets("Entering number updates controller", (tester) async {
    stubDefaultDelegate();

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    await enterTextAndSettle(tester, find.byType(TextInput), "50");
    verifyNever(delegate.clearValue(any));
    verify(delegate.updateValue(any, any)).called(1);
  });

  testWidgets("Delegate inputTypeEntityExists=false shows Unknown label", (
    tester,
  ) async {
    stubDefaultDelegate();
    when(delegate.inputTypeEntityExists(any)).thenReturn(false);

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    expect(find.text("Unknown"), findsOneWidget);
  });

  testWidgets("Delegate inputTypeEntityExists=true shows correct label", (
    tester,
  ) async {
    stubDefaultDelegate();
    when(
      delegate.inputTypeEntityDisplayName(any, any),
    ).thenReturn("Correct Label");

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    expect(find.text("Correct Label"), findsOneWidget);
  });

  testWidgets("Re-picking items keeps previous values", (tester) async {
    stubDefaultDelegate();

    var catchesPerEntity = Trip_CatchesPerEntity(
      entityId: randomId(),
      value: 5,
    );
    when(delegate.existingInputItem(any)).thenReturn(catchesPerEntity);
    when(delegate.newInputItem(any)).thenReturn(catchesPerEntity);
    when(delegate.inputTypeHasValue(any)).thenReturn(true);

    await pumpContext(
      tester,
      (_) => QuantityPickerInput(title: "Title", delegate: delegate),
    );

    await tapAndSettle(tester, find.text("Title"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "Trout"));
    await tapAndSettle(tester, find.byType(BackButton));

    verify(delegate.updateValue(any, any)).called(1);
    expect(delegate.controller.value.length, 1);
    expect(delegate.controller.value.first.value, 5);
  });

  group("EntityQuantityPickerInputDelegate", () {
    test("pickerTypeInitialValues returns empty Set", () {
      var delegate = EntityQuantityPickerInputDelegate<Species>(
        manager: managers.speciesManager,
        controller: SetInputController<Trip_CatchesPerEntity>(),
        listPageBuilder: (_) => const SizedBox(),
      );
      expect(delegate.pickerTypeInitialValues, isEmpty);
    });

    test("pickerTypeInitialValues returns non-empty Set", () {
      when(managers.speciesManager.list(any)).thenReturn([]);

      var delegate = EntityQuantityPickerInputDelegate<Species>(
        manager: managers.speciesManager,
        controller: SetInputController<Trip_CatchesPerEntity>()
          ..value = {Trip_CatchesPerEntity(entityId: randomId(), value: 5)},
        listPageBuilder: (_) => const SizedBox(),
      );

      expect(delegate.pickerTypeInitialValues, isEmpty);

      var result = verify(managers.speciesManager.list(captureAny));
      result.called(1);

      var idArg = result.captured.first.first;
      expect(idArg, delegate.controller.value.first.entityId);
    });

    test("didUpdateValue is invoked", () {
      when(managers.speciesManager.list(any)).thenReturn([]);

      var catchesPerEntity = Trip_CatchesPerEntity(
        entityId: randomId(),
        value: 5,
      );

      var invoked = false;
      var delegate = EntityQuantityPickerInputDelegate<Species>(
        manager: managers.speciesManager,
        controller: SetInputController<Trip_CatchesPerEntity>()
          ..value = {catchesPerEntity},
        listPageBuilder: (_) => const SizedBox(),
        didUpdateValue: () => invoked = true,
      );

      expect(delegate.inputTypeValue(catchesPerEntity), 5);
      delegate.updateValue(catchesPerEntity, 10);

      expect(delegate.inputTypeValue(catchesPerEntity), 10);
      expect(invoked, isTrue);
    });
  });

  group("BaitQuantityPickerInputDelegate", () {
    test("inputTypeEntityExists with variant", () {
      when(managers.baitManager.variantFromAttachment(any)).thenReturn(null);

      var delegate = BaitQuantityPickerInputDelegate(
        baitManager: managers.baitManager,
        controller: SetInputController<Trip_CatchesPerBait>(),
      );

      expect(
        delegate.inputTypeEntityExists(
          Trip_CatchesPerBait(
            attachment: BaitAttachment(variantId: randomId()),
          ),
        ),
        isFalse,
      );
      verify(managers.baitManager.variantFromAttachment(any)).called(1);
    });

    test("inputTypeEntityExists without variant", () {
      when(managers.baitManager.entityExists(any)).thenReturn(false);

      var delegate = BaitQuantityPickerInputDelegate(
        baitManager: managers.baitManager,
        controller: SetInputController<Trip_CatchesPerBait>(),
      );

      expect(delegate.inputTypeEntityExists(Trip_CatchesPerBait()), isFalse);
      verify(managers.baitManager.entityExists(any)).called(1);
    });
  });
}
