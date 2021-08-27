import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late BaitManager baitManager;

  var categoryId0 = randomId();
  var categoryId1 = randomId();

  var variantId0 = randomId();
  var variantId1 = randomId();

  var baitId0 = randomId();
  var baitId1 = randomId();
  var baitId2 = randomId();
  var baitId3 = randomId();
  var baitId4 = randomId();

  var baitCategories = [
    BaitCategory()
      ..id = categoryId0
      ..name = "Artificial",
    BaitCategory()
      ..id = categoryId1
      ..name = "Live",
  ];

  var baits = [
    Bait()
      ..id = baitId0
      ..name = "Bullhead Minnow"
      ..baitCategoryId = baitCategories[1].id
      ..imageName = "flutter_logo.png"
      ..variants.add(BaitVariant(
        id: variantId0,
        baseId: baitId0,
        color: "Silver",
      )),
    Bait()
      ..id = baitId1
      ..name = "Threadfin Shad"
      ..baitCategoryId = baitCategories[1].id,
    Bait()
      ..id = baitId2
      ..name = "Gizzard Shad"
      ..baitCategoryId = baitCategories[1].id,
    Bait()
      ..id = baitId3
      ..name = "Skunk Flatfish"
      ..baitCategoryId = baitCategories[0].id,
    Bait()
      ..id = baitId4
      ..name = "Countdown Rapala 7"
      ..baitCategoryId = baitCategories[0].id
      ..variants.add(BaitVariant(
        id: variantId1,
        baseId: baitId4,
        color: "Brown Trout",
      )),
  ];

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.baitCategoryManager.listSortedByName())
        .thenReturn(baitCategories);
    when(appManager.baitCategoryManager.matchesFilter(any, any))
        .thenReturn(false);
    when(appManager.baitCategoryManager.entity(any)).thenAnswer((invocation) =>
        baitCategories.firstWhereOrNull(
            (e) => e.id == invocation.positionalArguments.first));

    when(appManager.catchManager.list()).thenReturn([]);

    when(appManager.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("");

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    for (var bait in baits) {
      await baitManager.addOrUpdate(bait);
    }
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));
    expect(find.text("Baits (5)"), findsOneWidget);
  });

  testWidgets("Normal title when filtered", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => BaitListPage(),
      appManager: appManager,
    );
    expect(find.text("Baits (5)"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Shad");
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    expect(find.primaryText(context), findsNWidgets(2));
    expect(find.text("Baits (2)"), findsOneWidget);
  });

  testWidgets("Different item types are rendered", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => BaitListPage(),
      appManager: appManager,
    );

    var baitCategoryHeadings =
        tester.widgetList(find.listHeadingText(context)).toList();
    expect(baitCategoryHeadings.length, 2);
    expect((baitCategoryHeadings[0] as Text).data, "Artificial");
    expect((baitCategoryHeadings[1] as Text).data, "Live");

    var baitLabels = tester.widgetList(find.primaryText(context)).toList();
    expect(baitLabels.length, 5);
    expect((baitLabels[0] as Text).data, "Countdown Rapala 7");
    expect((baitLabels[1] as Text).data, "Skunk Flatfish");
    expect((baitLabels[2] as Text).data, "Bullhead Minnow");
    expect((baitLabels[3] as Text).data, "Gizzard Shad");
    expect((baitLabels[4] as Text).data, "Threadfin Shad");

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets("First category does not include a divider", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));

    var headings =
        tester.widgetList<HeadingDivider>(find.byType(HeadingDivider)).toList();
    expect(headings.length, 2);
    expect(headings[0].showDivider, isFalse);
    expect(headings[1].showDivider, isTrue);
  });

  testWidgets("Bait shows number of catches", (tester) async {
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        baits: [
          BaitAttachment(
            baitId: baitId0,
          ),
        ],
      )
    ]);

    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));

    expect(find.text("0 Catches"), findsNWidgets(4));
    expect(find.text("1 Catch"), findsOneWidget);
  });

  testWidgets("Bait shows photo", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));
    // Required to replace placeholder with image.
    await tester.pumpAndSettle();

    expect(find.byIcon(CustomIcons.catches), findsNWidgets(4));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Bait shows number of variants", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));

    expect(find.text("1 Variant"), findsNWidgets(2));
    expect(find.text("0 Variants"), findsNWidgets(3));
  });

  group("BaitPickerInput", () {
    testWidgets("Initial values are selected", (tester) async {
      var controller = SetInputController<BaitAttachment>();
      controller.value = {
        BaitAttachment(
          baitId: baitId0,
          variantId: variantId0,
        ),
        BaitAttachment(
          baitId: baitId1,
        ),
      };

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "",
        ),
        appManager: appManager,
      ));

      // Verify chips are shown.
      expect(find.text("Live - Threadfin Shad"), findsOneWidget);
      expect(find.text("Live - Bullhead Minnow (Silver)"), findsOneWidget);

      await tapAndSettle(tester, find.text("Live - Threadfin Shad"));
      expect(find.byType(BaitListPage), findsOneWidget);

      var baitCheckbox = tester.widget<PaddedCheckbox>(
        findManageableListItemCheckbox(
          tester,
          "Threadfin Shad",
          skipOffstage: false,
        ),
      );
      expect(baitCheckbox.checked, isTrue);

      var variantCheckbox = tester.widget<PaddedCheckbox>(
        findManageableListItemCheckbox(
          tester,
          "Silver",
          skipOffstage: false,
        ),
      );
      expect(variantCheckbox.checked, isTrue);

      var flatfishCheckbox = tester.widget<PaddedCheckbox>(
        findManageableListItemCheckbox(
          tester,
          "Skunk Flatfish",
          skipOffstage: false,
        ),
      );
      expect(flatfishCheckbox.checked, isFalse);
    });

    testWidgets("Variants are added/removed from selected values",
        (tester) async {
      var controller = SetInputController<BaitAttachment>();

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
        ),
        appManager: appManager,
      ));

      // Select variant.
      await tapAndSettle(tester, find.text("No baits"));
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(
          tester,
          "Silver",
          skipOffstage: false,
        ),
      );
      await tapAndSettle(tester, find.byType(BackButton));
      expect(controller.value.length, 1);
      expect(controller.value.last.variantId, variantId0);

      // De-select variant.
      await tapAndSettle(tester, find.text("Live - Bullhead Minnow (Silver)"));
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(
          tester,
          "Silver",
          skipOffstage: false,
        ),
      );
      await tapAndSettle(tester, find.byType(BackButton));
      expect(controller.value.isEmpty, isTrue);
    });

    testWidgets("Selecting all with isAllEmpty = false, sets controller",
        (tester) async {
      var controller = SetInputController<BaitAttachment>();

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: false,
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("No baits"));
      await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
      await tapAndSettle(tester, find.byType(BackButton));

      expect(controller.value.length, 5);
      expect(controller.value.where((e) => e.hasVariantId()).length, 2);
    });

    testWidgets("Selecting all with isAllEmpty = true, clears controller",
        (tester) async {
      var controller = SetInputController<BaitAttachment>();

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: true,
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("No baits"));

      // Verify all items are selected, and do not change. In this case,
      // controller should be cleared.
      var allCheckbox = tester.widget<PaddedCheckbox>(
          findManageableListItemCheckbox(tester, "All"));
      expect(allCheckbox.checked, isTrue);

      await tapAndSettle(tester, find.byType(BackButton));

      expect(controller.value.isEmpty, isTrue);
    });

    testWidgets("De-selecting all clears controller", (tester) async {
      var controller = SetInputController<BaitAttachment>();

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: false,
        ),
        appManager: appManager,
      ));

      // Select all.
      await tapAndSettle(tester, find.text("No baits"));
      await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
      await tapAndSettle(tester, find.byType(BackButton));
      expect(controller.value.length, 5);

      // De-select all.
      await tapAndSettle(tester, find.byType(BaitPickerInput));
      await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
      await tapAndSettle(tester, find.byType(BackButton));
      expect(controller.value.isEmpty, isTrue);
      expect(find.text("No baits"), findsOneWidget);
    });

    testWidgets("Only bait objects without variants are passed to picker",
        (tester) async {
      var controller = SetInputController<BaitAttachment>();
      controller.value = {
        BaitAttachment(
          baitId: baitId0,
          variantId: variantId0,
        ),
        BaitAttachment(
          baitId: baitId1,
        ),
      };

      await tester.pumpWidget(Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("Live - Threadfin Shad"));

      var pickerPage =
          tester.widget<ManageableListPage>(find.byType(ManageableListPage));
      expect(pickerPage.pickerSettings, isNotNull);
      expect(pickerPage.pickerSettings!.initialValues.length, 1);
      expect(pickerPage.pickerSettings!.initialValues.first is Bait, isTrue);
    });
  });
}
