import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.addOrUpdate(
      any,
      imageFile: anyNamed("imageFile"),
    )).thenAnswer((_) => Future.value(false));
    when(appManager.baitManager.duplicate(any)).thenReturn(false);
    when(appManager.baitManager.variantDisplayValue(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].color);

    when(appManager.baitCategoryManager.entityExists(any)).thenReturn(false);

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
  });

  testWidgets("Default values for new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));
    expect(find.text("Not Selected"), findsOneWidget);
    expect(findFirst<TextField>(tester).controller!.text, isEmpty);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage.edit(
        Bait()
          ..id = randomId()
          ..name = "Rapala",
      ),
      appManager: appManager,
    ));
    expect(find.text("Edit Bait"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));
    expect(find.text("New Bait"), findsOneWidget);
  });

  testWidgets("Selecting bait category updates state", (tester) async {
    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    when(appManager.baitCategoryManager
            .listSortedByDisplayName(any, filter: anyNamed("filter")))
        .thenReturn([baitCategory]);
    when(appManager.baitCategoryManager.entity(baitCategory.id))
        .thenReturn(baitCategory);
    when(appManager.baitCategoryManager.id(baitCategory))
        .thenReturn(baitCategory.id);
    when(appManager.baitCategoryManager.entityExists(baitCategory.id))
        .thenReturn(true);
    when(appManager.baitCategoryManager.displayName(any, baitCategory))
        .thenReturn(baitCategory.name);

    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Not Selected"));
    await tapAndSettle(tester, find.text("Lure"));

    expect(find.byType(BaitCategoryListPage), findsNothing);
    expect(find.text("Not Selected"), findsNothing);
    expect(find.text("Lure"), findsOneWidget);
  });

  testWidgets("Updating name updates save button state", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));

    expect(findFirst<ActionButton>(tester).onPressed, isNull);
    await enterTextAndSettle(tester, find.byType(TextField), "Rapala");
    expect(findFirst<ActionButton>(tester).onPressed, isNotNull);
    await enterTextAndSettle(tester, find.byType(TextField), "");
    expect(findFirst<ActionButton>(tester).onPressed, isNull);
  });

  testWidgets("Editing", (tester) async {
    var categoryId = randomId();
    var baitCategory = BaitCategory()
      ..id = categoryId
      ..name = "Lure";

    var bait = Bait()
      ..id = randomId()
      ..name = "Rapala"
      ..baitCategoryId = categoryId
      ..type = Bait_Type.live
      ..imageName = "flutter_logo.png"
      ..variants.addAll([
        BaitVariant(
          id: randomId(),
          color: "Red",
        ),
      ]);

    when(appManager.baitCategoryManager.entity(any)).thenReturn(baitCategory);
    when(appManager.baitCategoryManager.entityExists(baitCategory.id))
        .thenReturn(true);
    when(appManager.baitCategoryManager.displayName(any, baitCategory))
        .thenReturn(baitCategory.name);

    when(appManager.baitManager.duplicate(any)).thenReturn(false);

    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage.edit(bait),
      appManager: appManager,
    ));

    expect(find.text("Not Selected"), findsNothing);
    expect(find.text("Lure"), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);
    expect(
      tester.widget<RadioInput>(find.byType(RadioInput)).initialSelectedIndex,
      2,
    );
    expect(find.text("Red"), findsOneWidget);
    expect(
      tester
          .widget<SingleImageInput>(find.byType(SingleImageInput))
          .initialImageName,
      isNotEmpty,
    );

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Plug");
    await tapAndSettle(tester, find.text("Artificial"));

    await tapAndSettle(tester, find.text("Red"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Color"), "Green");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(find.text("Green"), findsOneWidget);
    expect(find.text("Red"), findsNothing);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitManager
        .addOrUpdate(captureAny, imageFile: anyNamed("imageFile")));
    result.called(1);

    Bait newBait = result.captured.first;
    expect(newBait.id, bait.id);
    expect(newBait.baitCategoryId, bait.baitCategoryId);
    expect(newBait.name, "Plug");
    expect(newBait.type, Bait_Type.artificial);
    expect(newBait.variants.length, 1);
    expect(newBait.variants.first.color, "Green");
    expect(newBait.variants.first.baseId, newBait.id);
  });

  testWidgets("Duplicate bait shows dialog", (tester) async {
    var categoryId = randomId();
    var baitCategory = BaitCategory()
      ..id = categoryId
      ..name = "Lure";

    var bait = Bait()
      ..id = randomId()
      ..name = "Rapala"
      ..baitCategoryId = categoryId;

    when(appManager.baitCategoryManager.entity(any)).thenReturn(baitCategory);
    when(appManager.baitCategoryManager.entityExists(baitCategory.id))
        .thenReturn(true);
    when(appManager.baitCategoryManager.displayName(any, baitCategory))
        .thenReturn(baitCategory.name);

    when(appManager.baitManager.duplicate(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage.edit(bait),
      appManager: appManager,
    ));

    expect(find.text("Not Selected"), findsNothing);
    expect(find.text("Lure"), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Plug");
    await tapAndSettle(tester, find.text("SAVE"));

    expect(find.text("Error"), findsOneWidget);
    verifyNever(appManager.baitManager.addOrUpdate(captureAny));
  });

  testWidgets("New saving minimum", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Plug");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitManager
        .addOrUpdate(captureAny, imageFile: anyNamed("imageFile")));
    result.called(1);

    Bait bait = result.captured.first;
    expect(bait.name, "Plug");
    expect(bait.hasBaitCategoryId(), isFalse);
    expect(bait.hasType(), isTrue);
    expect(bait.hasImageName(), isFalse);
  });

  /// https://github.com/cohenadair/anglers-log/issues/462
  testWidgets("Updates to selected bait category updates state",
      (tester) async {
    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Spoon";

    // Use real BaitManager to test listener notifications.
    var baitCategoryManager = BaitCategoryManager(appManager.app);
    baitCategoryManager.addOrUpdate(baitCategory);
    when(appManager.app.baitCategoryManager).thenReturn(baitCategoryManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveBaitPage.edit(Bait()
          ..id = randomId()
          ..baitCategoryId = baitCategory.id),
        appManager: appManager,
      ),
    );

    expect(find.text("Spoon"), findsOneWidget);

    // Edit the selected category.
    await tapAndSettle(tester, find.text("Spoon"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.text("Spoon"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Spoon 2");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new category name is shown.
    expect(find.text("Spoon 2"), findsOneWidget);
  });

  testWidgets("Selected image is attached to bait", (tester) async {
    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value(["image_name.png"]));

    await tester.pumpWidget(Testable(
      (_) => const SaveBaitPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Rapala");

    // Emulate picking an image by setting the controller's value directly.
    var imageController = tester
        .widget<SingleImageInput>(find.byType(SingleImageInput))
        .controller;
    imageController.value = PickedImage(
      originalFile: MockFile(),
    );

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitManager
        .addOrUpdate(any, imageFile: captureAnyNamed("imageFile")));
    result.called(1);

    var imageFile = result.captured.first;
    expect(imageFile, isNotNull);
  });
}
