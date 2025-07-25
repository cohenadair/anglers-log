import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/bait_variant_list_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
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
      ..variants.add(
        BaitVariant(id: variantId0, baseId: baitId0, color: "Silver"),
      ),
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
      ..variants.add(
        BaitVariant(id: variantId1, baseId: baitId4, color: "Brown Trout"),
      ),
  ];

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.baitCategoryManager.listSortedByDisplayName(any),
    ).thenReturn(baitCategories);
    when(
      managers.baitCategoryManager.matchesFilter(any, any, any),
    ).thenReturn(false);
    when(managers.baitCategoryManager.entity(any)).thenAnswer(
      (invocation) => baitCategories.firstWhereOrNull(
        (e) => e.id == invocation.positionalArguments.first,
      ),
    );
    when(
      managers.baitCategoryManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    when(managers.catchManager.list()).thenReturn([]);

    when(
      managers.customEntityManager.customValuesDisplayValue(any, any),
    ).thenReturn("");

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    baitManager = BaitManager(managers.app);
    when(managers.app.baitManager).thenReturn(baitManager);

    for (var bait in baits) {
      await baitManager.addOrUpdate(bait);
    }
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable((_) => const BaitListPage()));
    expect(find.text("Baits (5)"), findsOneWidget);
  });

  testWidgets("Normal title when filtered", (tester) async {
    var context = await pumpContext(tester, (_) => const BaitListPage());
    expect(find.text("Baits (5)"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Shad");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.primaryText(context), findsNWidgets(2));
    expect(find.text("Baits (2)"), findsOneWidget);
  });

  testWidgets("Different item types are rendered", (tester) async {
    var context = await pumpContext(tester, (_) => const BaitListPage());

    var baitCategoryHeadings = tester
        .widgetList(find.listHeadingText(context))
        .toList();
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
    await tester.pumpWidget(Testable((_) => const BaitListPage()));

    var headings = tester
        .widgetList<HeadingDivider>(find.byType(HeadingDivider))
        .toList();
    expect(headings.length, 2);
    expect(headings[0].showDivider, isFalse);
    expect(headings[1].showDivider, isTrue);
  });

  testWidgets("Bait shows number of catches", (tester) async {
    when(managers.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        baits: [BaitAttachment(baitId: baitId0)],
      ),
    ]);

    await tester.pumpWidget(Testable((_) => const BaitListPage()));

    expect(find.text("0 Catches"), findsNWidgets(4));
    expect(find.text("1 Catch"), findsOneWidget);
  });

  testWidgets("Bait shows photo", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable((_) => const BaitListPage()));
    // Required to replace placeholder with image.
    await tester.pumpAndSettle();

    expect(find.byIcon(CustomIcons.catches), findsNWidgets(4));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Bait falls back on variant photo", (tester) async {
    // Setup a variant image fallback.
    await baitManager.addOrUpdate(
      baits.first.deepCopy()
        ..clearImageName()
        ..variants.add(
          BaitVariant(id: randomId(), imageName: "flutter_logo.png"),
        ),
    );
    await stubImage(managers, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable((_) => const BaitListPage()));
    // Required to replace placeholder with image.
    await tester.pumpAndSettle();

    expect(find.byIcon(CustomIcons.catches), findsNWidgets(4));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Bait shows number of variants", (tester) async {
    await tester.pumpWidget(Testable((_) => const BaitListPage()));

    expect(find.text("1 Variant"), findsNWidgets(2));
    expect(find.text("0 Variants"), findsNWidgets(3));
  });

  testWidgets("Variant shows chip for normal text size", (tester) async {
    await tester.pumpWidget(Testable((_) => const BaitListPage()));
    expect(find.byType(MinChip), findsNWidgets(5));
    expect(find.text("1 Variant"), findsNWidgets(2));
    expect(find.text("0 Variants"), findsNWidgets(3));
  });

  testWidgets("Variant shows subtitle for large text size", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const BaitListPage(),
        mediaQueryData: const MediaQueryData(
          textScaler: TextScaler.linear(maxTextScale),
        ),
      ),
    );
    expect(find.byType(MinChip), findsNothing);
    expect(find.text("1 Variant"), findsNWidgets(2));
    expect(find.text("0 Variants"), findsNWidgets(3));
  });

  testWidgets("Initial values are selected", (tester) async {
    var controller = SetInputController<BaitAttachment>();
    controller.value = {
      BaitAttachment(baitId: baitId0, variantId: variantId0),
      BaitAttachment(baitId: baitId1),
    };

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(controller: controller, emptyValue: (_) => ""),
      ),
    );

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
      findManageableListItemCheckbox(tester, "Silver", skipOffstage: false),
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

  testWidgets("Variants are added/removed from selected values", (
    tester,
  ) async {
    var controller = SetInputController<BaitAttachment>();

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
        ),
      ),
    );

    // Select variant.
    await tapAndSettle(tester, find.text("No baits"));
    await tapAndSettle(
      tester,
      findManageableListItemCheckbox(tester, "Silver", skipOffstage: false),
    );
    await tapAndSettle(tester, find.byType(BackButton));
    expect(controller.value.length, 1);
    expect(controller.value.last.variantId, variantId0);

    // De-select variant.
    await tapAndSettle(tester, find.text("Live - Bullhead Minnow (Silver)"));
    await tapAndSettle(
      tester,
      findManageableListItemCheckbox(tester, "Silver", skipOffstage: false),
    );
    await tapAndSettle(tester, find.byType(BackButton));
    expect(controller.value.isEmpty, isTrue);
  });

  testWidgets("Selecting all with isAllEmpty = false, sets controller", (
    tester,
  ) async {
    var controller = SetInputController<BaitAttachment>();

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: false,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("No baits"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(controller.value.length, 5);
    expect(controller.value.where((e) => e.hasVariantId()).length, 2);
  });

  testWidgets("Selecting all with isAllEmpty = true, clears controller", (
    tester,
  ) async {
    var controller = SetInputController<BaitAttachment>();

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("No baits"));

    // Verify all items are selected, and do not change. In this case,
    // controller should be cleared.
    var allCheckbox = tester.widget<PaddedCheckbox>(
      findManageableListItemCheckbox(tester, "All"),
    );
    expect(allCheckbox.checked, isTrue);

    await tapAndSettle(tester, find.byType(BackButton));

    expect(controller.value.isEmpty, isTrue);
  });

  testWidgets("De-selecting all clears controller", (tester) async {
    var controller = SetInputController<BaitAttachment>();

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
          isAllEmpty: false,
        ),
      ),
    );

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

  testWidgets("Only bait objects without variants are passed to picker", (
    tester,
  ) async {
    var controller = SetInputController<BaitAttachment>();
    controller.value = {
      BaitAttachment(baitId: baitId0, variantId: variantId0),
      BaitAttachment(baitId: baitId1),
    };

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Live - Threadfin Shad"));

    var pickerPage = tester.widget<ManageableListPage>(
      find.byType(ManageableListPage),
    );
    expect(pickerPage.pickerSettings, isNotNull);
    expect(pickerPage.pickerSettings!.initialValues.length, 1);
    expect(pickerPage.pickerSettings!.initialValues.first is Bait, isTrue);
  });

  testWidgets("Single picker picks variant", (tester) async {
    Set<BaitAttachment> pickedAttachments = {};

    await tester.pumpWidget(
      Testable(
        (_) => BaitListPage(
          pickerSettings: BaitListPagePickerSettings(
            onPicked: (_, attachments) {
              pickedAttachments = attachments;
              return true;
            },
            initialValues: {
              BaitAttachment(baitId: baitId0, variantId: variantId0),
            },
            isMulti: false,
          ),
        ),
      ),
    );

    // There's only one BaitVariantListInput that has a checkmark, since only
    // one initial value is set.
    var variantListFinder = find.ancestor(
      of: find.byIcon(Icons.check),
      matching: find.byType(BaitVariantListInput),
    );
    expect(variantListFinder, findsOneWidget);

    var variantList = tester.widget<BaitVariantListInput>(variantListFinder);
    expect(variantList.onCheckboxChanged, isNull);
    expect(variantList.onPicked, isNotNull);

    await tapAndSettle(tester, find.text("Silver"));

    expect(pickedAttachments.length, 1);
    expect(pickedAttachments.first.baitId, baitId0);
    expect(pickedAttachments.first.variantId, variantId0);
    expect(find.byType(BaitListPage), findsNothing); // Page was popped.
  });

  testWidgets("Single picker picks bait", (tester) async {
    Set<BaitAttachment> pickedAttachments = {};

    await tester.pumpWidget(
      Testable(
        (_) => BaitListPage(
          pickerSettings: BaitListPagePickerSettings(
            onPicked: (_, attachments) {
              pickedAttachments = attachments;
              return true;
            },
            initialValues: {},
            isMulti: false,
          ),
        ),
      ),
    );

    var shadText = find.text("Threadfin Shad", skipOffstage: false);
    await ensureVisibleAndSettle(tester, shadText);
    await tapAndSettle(tester, shadText);

    expect(pickedAttachments.length, 1);
    expect(pickedAttachments.first.baitId, baitId1);
    expect(pickedAttachments.first.hasVariantId(), isFalse);
    expect(find.byType(BaitListPage), findsNothing); // Page was popped.
  });

  testWidgets("Multi picker picks bait and variants", (tester) async {
    var controller = SetInputController<BaitAttachment>();
    controller.value = {BaitAttachment(baitId: baitId0, variantId: variantId0)};

    await tester.pumpWidget(
      Testable(
        (_) => BaitPickerInput(
          controller: controller,
          emptyValue: (_) => "No baits",
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Live - Bullhead Minnow (Silver)"));

    var variantList = findFirst<BaitVariantListInput>(tester);
    expect(variantList.onCheckboxChanged, isNotNull);
    expect(variantList.onPicked, isNull);

    // Uncheck selected variant.
    await tapAndSettle(
      tester,
      findManageableListItemCheckbox(tester, "Silver"),
    );

    // Select a bait and a different variant.
    var shadCheckbox = findManageableListItemCheckbox(
      tester,
      "Threadfin Shad",
      skipOffstage: false,
    );
    await ensureVisibleAndSettle(tester, shadCheckbox);
    await tapAndSettle(tester, shadCheckbox);
    await tapAndSettle(
      tester,
      findManageableListItemCheckbox(tester, "Brown Trout"),
    );

    // Trigger onPicked callback.
    findFirst<WillPopScope>(tester).onWillPop!.call();
    await tester.pumpAndSettle();

    expect(controller.value.length, 2);
    expect(controller.value.first.baitId, baitId1);
    expect(controller.value.first.hasVariantId(), isFalse);
    expect(controller.value.last.baitId, baitId4);
    expect(controller.value.last.variantId, variantId1);
    expect(find.byType(BaitListPage), findsNothing); // Page was popped.
  });

  testWidgets(
    "Single picker selected variant not passed to ManageableListPage",
    (tester) async {
      var controller = SetInputController<BaitAttachment>();
      controller.value = {
        BaitAttachment(baitId: baitId0, variantId: variantId0),
      };

      await tester.pumpWidget(
        Testable(
          (_) => BaitListPage(
            pickerSettings: BaitListPagePickerSettings(
              onPicked: (_, __) => true,
              initialValues: {
                BaitAttachment(baitId: baitId0, variantId: variantId0),
              },
              isMulti: false,
            ),
          ),
        ),
      );

      // Verify that the only initial value (that has a variant) is not passed
      // to the ManageableListPage.
      var pickerPage = tester.widget<ManageableListPage>(
        find.byType(ManageableListPage),
      );
      expect(pickerPage.pickerSettings, isNotNull);
      expect(pickerPage.pickerSettings!.initialValues, isEmpty);
    },
  );
}
