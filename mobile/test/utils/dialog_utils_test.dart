import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("DialogButton popsOnTap=true", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: true,
        popOnTap: true,
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(DialogButton), findsNothing);
  });

  testWidgets("DialogButton popsOnTap=false", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: true,
        popOnTap: false,
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(DialogButton), findsOneWidget);
  });

  testWidgets("DialogButton disabled", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: false,
      ),
    );

    var button = findFirstWithText<TextButton>(tester, "TEST");
    expect(button.onPressed, isNull);
  });

  testWidgets("Discard dialog pops by default", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => Button(
          text: "Test",
          onPressed: () => showDiscardChangesDialog(context),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.text("DISCARD"));
    expect(find.byType(Button), findsNothing);
  });

  testWidgets("Discard dialog calls onDiscard", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (context) => Button(
          text: "Test",
          onPressed: () =>
              showDiscardChangesDialog(context, () => invoked = true),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.text("DISCARD"));
    expect(find.byType(Button), findsOneWidget);
    expect(invoked, isTrue);
  });
}
