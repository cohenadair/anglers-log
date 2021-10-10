import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_method_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.methodManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.methodManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveMethodPage.edit(Method()),
      appManager: appManager,
    ));
    expect(find.text("Edit Fishing Method"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveMethodPage(),
      appManager: appManager,
    ));
    expect(find.text("New Fishing Method"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveMethodPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Casting");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.methodManager.addOrUpdate(captureAny));
    result.called(1);

    Method method = result.captured.first;
    expect(method.name, "Casting");
  });

  testWidgets("Editing", (tester) async {
    var method = Method()
      ..id = randomId()
      ..name = "Casting";

    await tester.pumpWidget(Testable(
      (_) => SaveMethodPage.edit(method),
      appManager: appManager,
    ));

    expect(find.text("Casting"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Kayak");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.methodManager.addOrUpdate(captureAny));
    result.called(1);

    Method newMethod = result.captured.first;
    expect(newMethod.id, method.id);
    expect(newMethod.name, "Kayak");
  });
}
