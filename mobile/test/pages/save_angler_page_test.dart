import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_angler_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.anglerManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveAnglerPage.edit(Angler()),
      appManager: appManager,
    ));
    expect(find.text("Edit Angler"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveAnglerPage(),
      appManager: appManager,
    ));
    expect(find.text("New Angler"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveAnglerPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Cohen");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.anglerManager.addOrUpdate(captureAny));
    result.called(1);

    Angler angler = result.captured.first;
    expect(angler.name, "Cohen");
  });

  testWidgets("Editing", (tester) async {
    var angler = Angler()
      ..id = randomId()
      ..name = "Cohen";

    await tester.pumpWidget(Testable(
      (_) => SaveAnglerPage.edit(angler),
      appManager: appManager,
    ));

    expect(find.text("Cohen"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Someone");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.anglerManager.addOrUpdate(captureAny));
    result.called(1);

    Angler newAngler = result.captured.first;
    expect(newAngler.id, angler.id);
    expect(newAngler.name, "Someone");
  });
}
