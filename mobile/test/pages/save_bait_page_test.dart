import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.baitManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.baitManager.duplicate(any)).thenReturn(false);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.userPreferenceManager.baitVariantCustomIds).thenReturn([]);
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
  });

  testWidgets("Default values for new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage(),
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
      (_) => SaveBaitPage(),
      appManager: appManager,
    ));
    expect(find.text("New Bait"), findsOneWidget);
  });

  testWidgets("Selecting bait category updates state", (tester) async {
    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    when(appManager.baitCategoryManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn([baitCategory]);
    when(appManager.baitCategoryManager.entity(baitCategory.id))
        .thenReturn(baitCategory);

    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage(),
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
      (_) => SaveBaitPage(),
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
      ..baitCategoryId = categoryId;

    when(appManager.baitCategoryManager.entity(any)).thenReturn(baitCategory);
    when(appManager.baitManager.duplicate(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => SaveBaitPage.edit(bait),
      appManager: appManager,
    ));

    expect(find.text("Not Selected"), findsNothing);
    expect(find.text("Lure"), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Plug");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitManager.addOrUpdate(captureAny));
    result.called(1);

    Bait newBait = result.captured.first;
    expect(newBait.id, bait.id);
    expect(newBait.baitCategoryId, bait.baitCategoryId);
    expect(newBait.name, "Plug");
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
      (_) => SaveBaitPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Plug");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitManager.addOrUpdate(captureAny));
    result.called(1);

    Bait bait = result.captured.first;
    expect(bait.name, "Plug");
    expect(bait.hasBaitCategoryId(), isFalse);
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
}
