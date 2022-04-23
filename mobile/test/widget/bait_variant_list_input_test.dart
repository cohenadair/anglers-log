import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/bait_variant_list_input.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.variantDisplayValue(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].color);

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  test("Invalid input", () {
    expect(
        () => BaitVariantListInput(
              controller: ListInputController(),
              onCheckboxChanged: (_, __) {},
              onPicked: (_) {},
            ),
        throwsAssertionError);
  });

  testWidgets("Items reset when controller value changes", (tester) async {
    var redId = randomId();
    var greenId = randomId();

    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: redId,
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      // Use _ParentRebuildTester here so didUpdateWidget on
      // BaitVariantListInput can be invoked by calling setState on
      // _ParentRebuildTester.
      (_) => _ParentRebuildTester(controller),
      appManager: appManager,
    );

    expect(find.text("Red"), findsOneWidget);

    controller.value = [
      BaitVariant(
        id: redId,
        color: "Red",
      ),
      BaitVariant(
        id: greenId,
        color: "Green",
      ),
    ];
    await tapAndSettle(tester, find.widgetWithText(Button, "TEST"));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text("Red"), findsOneWidget);
    expect(find.text("Green"), findsOneWidget);
  });

  testWidgets("Editing shows add button", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: ListInputController<BaitVariant>(),
        isEditing: true,
        showHeader: true,
      ),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("Static hides add button", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListInput.static(
        [
          BaitVariant(
            color: "Red",
          )
        ],
      ),
      appManager: appManager,
    );
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Header is shown", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: ListInputController<BaitVariant>(),
        showHeader: true,
      ),
    );
    expect(find.text("Variants"), findsOneWidget);
  });

  testWidgets("Header is hidden", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: ListInputController<BaitVariant>(),
        showHeader: false,
      ),
      appManager: appManager,
    );
    expect(find.text("Variants"), findsNothing);
  });

  testWidgets("Checkbox is shown", (tester) async {
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: randomId(),
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
        onCheckboxChanged: (_, __) {},
      ),
      appManager: appManager,
    );

    expect(find.byType(PaddedCheckbox), findsOneWidget);
  });

  testWidgets("Checkbox is hidden", (tester) async {
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: randomId(),
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
      ),
      appManager: appManager,
    );

    expect(find.byType(PaddedCheckbox), findsNothing);
  });

  testWidgets("Checked icon is showing for single picker", (tester) async {
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: randomId(),
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
        onPicked: (_) {},
        selectedItems: {controller.value.first},
      ),
      appManager: appManager,
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets("Checked icon is hidden for single picker", (tester) async {
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: randomId(),
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
        onPicked: (_) {},
      ),
      appManager: appManager,
    );

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets("Adding duplicate variant is a no-op", (tester) async {
    var id = randomId();
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: id,
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
      ),
      appManager: appManager,
    );

    expect(controller.value.length, 1);
    expect(controller.value.first.color, "Red");
    expect(controller.value.first.id, id);

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("SAVE"));

    // Verify nothing changed.
    expect(controller.value.length, 1);
    expect(controller.value.first.color, "Red");
    expect(controller.value.first.id, id);
  });

  testWidgets("Editing a variant replaces item", (tester) async {
    var id = randomId();
    var controller = ListInputController<BaitVariant>();
    controller.value = [
      BaitVariant(
        id: id,
        color: "Red",
      ),
    ];

    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
      ),
      appManager: appManager,
    );

    expect(controller.value.length, 1);
    expect(controller.value.first.color, "Red");
    expect(controller.value.first.id, id);

    await tapAndSettle(tester, find.text("EDIT"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Color"), "Green");
    await tapAndSettle(tester, find.text("SAVE"));

    // Verify variant was updated.
    expect(controller.value.length, 1);
    expect(controller.value.first.color, "Green");
    expect(controller.value.first.id, id);
  });

  testWidgets("Adding a variant inserts item", (tester) async {
    var controller = ListInputController<BaitVariant>();
    await pumpContext(
      tester,
      (_) => BaitVariantListInput(
        controller: controller,
      ),
      appManager: appManager,
    );

    expect(controller.value.isEmpty, isTrue);

    await tapAndSettle(tester, find.byIcon(Icons.add));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Color"), "Green");
    await tapAndSettle(tester, find.text("SAVE"));

    // Verify variant was added.
    expect(controller.value.length, 1);
    expect(controller.value.first.color, "Green");
  });
}

class _ParentRebuildTester extends StatefulWidget {
  final ListInputController<BaitVariant> controller;

  const _ParentRebuildTester(this.controller);

  @override
  _ParentRebuildTesterState createState() => _ParentRebuildTesterState();
}

class _ParentRebuildTesterState extends State<_ParentRebuildTester> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Button(
          text: "Test",
          onPressed: () => setState(() {}),
        ),
        BaitVariantListInput(
          controller: widget.controller,
        ),
      ],
    );
  }
}
