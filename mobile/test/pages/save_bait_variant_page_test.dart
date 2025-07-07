import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Only tracked fields are shown", (tester) async {
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([
      Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694", // Color
      Id()..uuid = "69feaeb1-4cb3-4858-a652-22d7a9a6cb97", // Size
    ]);

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
    );

    expect(find.text("Colour"), findsOneWidget);
    expect(find.text("Size"), findsOneWidget);
    expect(find.text("Model Number"), findsNothing);
    expect(find.text("Minimum Dive Depth"), findsNothing);
    expect(find.text("Maximum Dive Depth"), findsNothing);
    expect(find.text("Description"), findsNothing);
  });

  testWidgets("All fields shown when none are tracked", (tester) async {
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
    );
    // SingleImageInput uses a Future under the hood. Need to let it finish.
    await tester.pumpAndSettle();

    expect(find.text("Photo"), findsOneWidget);
    expect(find.text("Colour"), findsOneWidget);
    expect(find.text("Size"), findsOneWidget);
    expect(find.text("Model Number"), findsOneWidget);
    expect(find.text("Minimum Dive Depth"), findsOneWidget);
    expect(find.text("Maximum Dive Depth"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
  });

  testWidgets("Editing with all fields set", (tester) async {
    var customEntityId = randomId();
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([
      Id()..uuid = "00d85821-133b-4ddc-b7b0-c4220a4f2932",
      Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694",
      Id()..uuid = "749c62ee-2d91-47cc-8b59-d5fce1d4048a",
      Id()..uuid = "69feaeb1-4cb3-4858-a652-22d7a9a6cb97",
      Id()..uuid = "69fbdc83-a6b5-4e54-8e76-8fbd024618b1",
      Id()..uuid = "45e31486-af4b-48e4-8e3e-741a1df903ac",
      Id()..uuid = "3115c29d-b919-41e5-b19f-ec877e134dbe",
      customEntityId,
    ]);
    when(managers.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);
    when(managers.customEntityManager.entity(customEntityId))
        .thenReturn(CustomEntity(
      id: customEntityId,
      name: "Custom Field",
      type: CustomEntity_Type.text,
    ));
    when(managers.imageManager.save(any))
        .thenAnswer((_) => Future.value(["flutter_logo.png"]));
    await stubImage(managers, tester, "flutter_logo.png");

    var variant = BaitVariant(
      id: randomId(),
      imageName: "flutter_logo.png",
      color: "Red",
      modelNumber: "AB123",
      size: "Large",
      minDiveDepth: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 10,
        ),
      ),
      maxDiveDepth: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 15,
        ),
      ),
      description: "This is a description.",
      customEntityValues: [
        CustomEntityValue(
          customEntityId: customEntityId,
          value: "Custom Value",
        ),
      ],
    );

    BaitVariant? updatedVariant;
    await pumpContext(
      tester,
      (_) => SaveBaitVariantPage.edit(
        variant,
        onSave: (newVariant) => updatedVariant = newVariant,
      ),
    );

    expect(findFirst<SingleImageInput>(tester).controller.hasValue, isTrue);
    expect(find.text("Red"), findsOneWidget);
    expect(find.text("Large"), findsOneWidget);
    expect(find.text("AB123"), findsOneWidget);
    expect(find.text("10"), findsOneWidget);
    expect(find.text("15"), findsOneWidget);
    expect(find.text("This is a description."), findsOneWidget);
    expect(find.text("Custom Value"), findsOneWidget);

    await tapAndSettle(tester, find.text("SAVE"));

    expect(updatedVariant, isNotNull);
    expect(updatedVariant, variant);
  });

  testWidgets("Editing with no fields set invokes onSave with null value",
      (tester) async {
    BaitVariant? updatedVariant;
    await pumpContext(
      tester,
      (_) => SaveBaitVariantPage.edit(
        BaitVariant(),
        onSave: (newVariant) => updatedVariant = newVariant,
      ),
    );

    await tapAndSettle(tester, find.text("SAVE"));
    expect(updatedVariant, isNull);
  });

  testWidgets("Save button disabled when there's no input", (tester) async {
    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
    );

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNull);
  });

  testWidgets("Save button enabled with valid input", (tester) async {
    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
    );

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Colour"), "Red");

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets("Save button updates when custom value changes", (tester) async {
    var customEntityId = randomId();
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([
      customEntityId,
    ]);
    when(managers.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);
    when(managers.customEntityManager.entity(customEntityId))
        .thenReturn(CustomEntity(
      id: customEntityId,
      name: "Custom Field",
      type: CustomEntity_Type.text,
    ));

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
    );

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Custom Field"), "Red");

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNotNull);
  });
}
