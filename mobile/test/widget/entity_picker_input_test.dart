import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  var species = [
    Species(id: randomId(), name: "Trout"),
    Species(id: randomId(), name: "Catfish"),
    Species(id: randomId(), name: "Bass"),
  ];

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.speciesManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(species);
    when(managers.speciesManager.list(any)).thenReturn(species);
    when(managers.speciesManager.entityCount).thenReturn(0);
    when(
      managers.speciesManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(
      managers.speciesManager.idSet(),
    ).thenReturn({species[0].id, species[1].id, species[2].id});
    when(
      managers.speciesManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.id);
    when(managers.speciesManager.entityExists(any)).thenAnswer(
      (invocation) =>
          species.firstWhereOrNull(
            (e) => e.id == invocation.positionalArguments.first,
          ) !=
          null,
    );
    when(managers.speciesManager.entity(species[0].id)).thenReturn(species[0]);
    when(managers.speciesManager.entity(species[1].id)).thenReturn(species[1]);
    when(managers.speciesManager.entity(species[2].id)).thenReturn(species[2]);
  });

  testWidgets("Multi clears controller when isEmptyAll=true", (tester) async {
    var controller = SetInputController<Id>();
    controller.value = {randomId()};

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: controller,
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(controller.value, isNotEmpty);

    await tapAndSettle(tester, find.text("Trout"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(controller.value, isEmpty);
  });

  testWidgets("Multi updates controller when isEmptyAll=false", (tester) async {
    var controller = SetInputController<Id>();

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: controller,
        emptyValue: "Nothing selected",
        isEmptyAll: false,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(controller.value, isEmpty);

    await tapAndSettle(tester, find.text("Nothing selected"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(controller.value.length, 3);
  });

  testWidgets("Multi empty controller shows nothing", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: SetInputController<Id>(),
        emptyValue: "Nothing selected",
        isEmptyAll: false,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(find.text("Nothing selected"), findsOneWidget);
  });

  testWidgets("Multi non-empty controller shows values", (tester) async {
    var controller = SetInputController<Id>();
    controller.value = {species[0].id, species[1].id, species[2].id};

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: controller,
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(controller.value, isNotEmpty);

    expect(find.text("Trout"), findsOneWidget);
    expect(find.text("Catfish"), findsOneWidget);
    expect(find.text("Bass"), findsOneWidget);
  });

  testWidgets("Single onPicked invoked", (tester) async {
    Id? picked;

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: IdInputController(),
        onPicked: (pickedId) => picked = pickedId,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    await tapAndSettle(tester, find.text("Test"));
    await tapAndSettle(tester, find.text("Trout"));

    expect(picked, isNotNull);
    expect(picked, species[0].id);
  });

  testWidgets("Single updates controller value to non-null", (tester) async {
    var controller = IdInputController();

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    await tapAndSettle(tester, find.text("Test"));
    await tapAndSettle(tester, find.text("Trout"));
    expect(controller.hasValue, isTrue);
  });

  testWidgets("Single updates controller value to null", (tester) async {
    var controller = IdInputController();
    controller.value = species[0].id;

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    await tapAndSettle(tester, find.text("Test"));
    await tapAndSettle(tester, find.text("None"));
    expect(controller.hasValue, isFalse);
  });

  testWidgets("Single fetched value is empty if entity does not exist", (
    tester,
  ) async {
    var controller = IdInputController();
    controller.value = randomId();

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(find.text("Not Selected"), findsOneWidget);
  });

  testWidgets("Single fetched value has length=1 if entity exists", (
    tester,
  ) async {
    var controller = IdInputController();
    controller.value = species[0].id;

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(find.text("Trout"), findsOneWidget);
  });

  testWidgets("Hidden returns empty", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: IdInputController(),
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
        isHidden: true,
      ),
    );
    expect(find.byType(EntityListenerBuilder), findsNothing);
  });

  testWidgets("Multi widget updates when controller is updated", (
    tester,
  ) async {
    var controller = SetInputController<Id>();
    controller.value = {species[0].id, species[1].id, species[2].id};

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: controller,
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(controller.value, isNotEmpty);

    expect(find.text("Trout"), findsOneWidget);
    expect(find.text("Catfish"), findsOneWidget);
    expect(find.text("Bass"), findsOneWidget);

    controller.clear();
    await tester.pumpAndSettle();

    expect(find.text("Trout"), findsNothing);
    expect(find.text("Catfish"), findsNothing);
    expect(find.text("Bass"), findsNothing);
    expect(find.text("Nothing selected"), findsOneWidget);
  });

  testWidgets("Single widget updates when controller is updated", (
    tester,
  ) async {
    var controller = IdInputController();

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(find.text("Not Selected"), findsOneWidget);

    controller.value = species[0].id;
    await tester.pumpAndSettle();

    expect(find.text("Not Selected"), findsNothing);
    expect(find.text("Trout"), findsOneWidget);
  });

  testWidgets("displayNameOverride invoked", (tester) async {
    var controller = IdInputController();
    controller.value = species[0].id;

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.single(
        title: "Test",
        manager: managers.speciesManager,
        controller: controller,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
        displayNameOverride: (_) => "Overridden Name",
      ),
    );

    expect(find.text("Overridden Name"), findsOneWidget);
  });

  testWidgets("Only initial values are selected in picker", (tester) async {
    var controller = SetInputController<Id>();
    controller.value = {species[0].id, species[1].id};
    when(
      managers.speciesManager.list(any),
    ).thenReturn([species[0], species[1]]);

    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: controller,
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    expect(controller.value, isNotEmpty);

    expect(find.text("Trout"), findsOneWidget);
    expect(find.text("Catfish"), findsOneWidget);
    expect(find.text("Bass"), findsNothing);
  });

  testWidgets("customListPage is shown", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: SetInputController<Id>(),
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        customListPage: (onPicked, initialValues) =>
            const Scaffold(body: Text("CustomListPage")),
      ),
    );

    await tapAndSettle(tester, find.text("Nothing selected"));
    expect(find.text("CustomListPage"), findsOneWidget);
  });

  testWidgets("listPage is shown", (tester) async {
    await pumpContext(
      tester,
      (_) => EntityPickerInput<Species>.multi(
        manager: managers.speciesManager,
        controller: SetInputController<Id>(),
        emptyValue: "Nothing selected",
        isEmptyAll: true,
        listPage: (pickerSettings) =>
            SpeciesListPage(pickerSettings: pickerSettings),
      ),
    );

    await tapAndSettle(tester, find.text("Nothing selected"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
  });
}
