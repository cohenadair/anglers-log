import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.baitCategoryManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage.edit(BaitCategory()),
      appManager: appManager,
    ));
    expect(find.text("Edit Bait Category"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitCategoryPage(),
      appManager: appManager,
    ));
    expect(find.text("New Bait Category"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBaitCategoryPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Lure");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory category = result.captured.first;
    expect(category.name, "Lure");
  });

  testWidgets("Editing", (tester) async {
    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage.edit(baitCategory),
      appManager: appManager,
    ));

    expect(find.text("Lure"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Bead");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.baitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory newBaitCategory = result.captured.first;
    expect(newBaitCategory.id, baitCategory.id);
    expect(newBaitCategory.name, "Bead");
  });

  testWidgets("Editing name that already exists", (tester) async {
    when(appManager.baitCategoryManager.nameExists(any)).thenReturn(true);

    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage.edit(baitCategory),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Rapala");
    expect(find.text("Bait category already exists"), findsOneWidget);
  });
}
