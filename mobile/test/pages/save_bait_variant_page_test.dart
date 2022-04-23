import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isFree).thenReturn(false);

    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Only tracked fields are shown", (tester) async {
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([
      Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694", // Color
      Id()..uuid = "69feaeb1-4cb3-4858-a652-22d7a9a6cb97", // Size
    ]);

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
      appManager: appManager,
    );

    expect(find.text("Color"), findsOneWidget);
    expect(find.text("Size"), findsOneWidget);
    expect(find.text("Model Number"), findsNothing);
    expect(find.text("Minimum Dive Depth"), findsNothing);
    expect(find.text("Maximum Dive Depth"), findsNothing);
    expect(find.text("Description"), findsNothing);
  });

  testWidgets("All fields shown when none are tracked", (tester) async {
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
      appManager: appManager,
    );

    expect(find.text("Color"), findsOneWidget);
    expect(find.text("Size"), findsOneWidget);
    expect(find.text("Model Number"), findsOneWidget);
    expect(find.text("Minimum Dive Depth"), findsOneWidget);
    expect(find.text("Maximum Dive Depth"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
  });

  testWidgets("Editing with all fields set", (tester) async {
    var customEntityId = randomId();
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([
      Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694",
      Id()..uuid = "749c62ee-2d91-47cc-8b59-d5fce1d4048a",
      Id()..uuid = "69feaeb1-4cb3-4858-a652-22d7a9a6cb97",
      Id()..uuid = "69fbdc83-a6b5-4e54-8e76-8fbd024618b1",
      Id()..uuid = "45e31486-af4b-48e4-8e3e-741a1df903ac",
      Id()..uuid = "3115c29d-b919-41e5-b19f-ec877e134dbe",
      customEntityId,
    ]);
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);
    when(appManager.customEntityManager.entity(customEntityId))
        .thenReturn(CustomEntity(
      id: customEntityId,
      name: "Custom Field",
      type: CustomEntity_Type.text,
    ));

    var variant = BaitVariant(
      id: randomId(),
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
      appManager: appManager,
    );

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
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("SAVE"));
    expect(updatedVariant, isNull);
  });

  testWidgets("Save button disabled when there's no input", (tester) async {
    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
      appManager: appManager,
    );

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNull);
  });

  testWidgets("Save button enabled with valid input", (tester) async {
    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
      appManager: appManager,
    );

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Color"), "Red");

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets("Save button updates when custom value changes", (tester) async {
    var customEntityId = randomId();
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([
      customEntityId,
    ]);
    when(appManager.customEntityManager.entityExists(customEntityId))
        .thenReturn(true);
    when(appManager.customEntityManager.entity(customEntityId))
        .thenReturn(CustomEntity(
      id: customEntityId,
      name: "Custom Field",
      type: CustomEntity_Type.text,
    ));

    await pumpContext(
      tester,
      (_) => const SaveBaitVariantPage(),
      appManager: appManager,
    );

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Custom Field"), "Red");

    var saveButton = findFirstWithText<ActionButton>(tester, "SAVE");
    expect(saveButton.onPressed, isNotNull);
  });
}
