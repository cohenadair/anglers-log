import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.baitCategoryManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.baitCategoryManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(
      Testable((_) => SaveBaitCategoryPage.edit(BaitCategory())),
    );
    expect(find.text("Edit Bait Category"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveBaitCategoryPage()));
    expect(find.text("New Bait Category"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveBaitCategoryPage()));

    await enterTextAndSettle(tester, find.byType(TextField), "Lure");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.baitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory category = result.captured.first;
    expect(category.name, "Lure");
  });

  testWidgets("Editing", (tester) async {
    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    await tester.pumpWidget(
      Testable((_) => SaveBaitCategoryPage.edit(baitCategory)),
    );

    expect(find.text("Lure"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Bead");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.baitCategoryManager.addOrUpdate(captureAny));
    result.called(1);

    BaitCategory newBaitCategory = result.captured.first;
    expect(newBaitCategory.id, baitCategory.id);
    expect(newBaitCategory.name, "Bead");
  });

  testWidgets("Editing name that already exists", (tester) async {
    when(managers.baitCategoryManager.nameExists(any)).thenReturn(true);

    var baitCategory = BaitCategory()
      ..id = randomId()
      ..name = "Lure";

    await tester.pumpWidget(
      Testable((_) => SaveBaitCategoryPage.edit(baitCategory)),
    );

    await enterTextAndSettle(tester, find.byType(TextField), "Rapala");
    expect(find.text("Bait category already exists"), findsOneWidget);
  });
}
