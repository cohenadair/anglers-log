import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
    );

    when(appManager.mockBaitCategoryManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage.edit(BaitCategory()),
      appManager: appManager,
    ));
    expect(find.text("Edit Bait Category"), findsOneWidget);
  });

  testWidgets("New title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage(),
      appManager: appManager,
    ));
    expect(find.text("New Bait Category"), findsOneWidget);
  });

  testWidgets("Save new", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBaitCategoryPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Lure");
    await tapAndSettle(tester, find.text("SAVE"));

    VerificationResult result =
        verify(appManager.mockBaitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory category = result.captured.first;
    expect(category.name, "Lure");
  });

  testWidgets("Editing", (WidgetTester tester) async {
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

    VerificationResult result =
        verify(appManager.mockBaitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory newBaitCategory = result.captured.first;
    expect(newBaitCategory.id, baitCategory.id);
    expect(newBaitCategory.name, "Bead");
  });
}