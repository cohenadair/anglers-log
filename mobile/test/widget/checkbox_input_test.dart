import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("Enabled", (tester) async {
    var checked = false;
    await tester.pumpWidget(
      Testable(
        (_) => CheckboxInput(
          label: "Test",
          onChanged: (_) => checked = true,
        ),
      ),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checked, isTrue);
    expect(findFirst<Checkbox>(tester).value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(findFirst<Checkbox>(tester).value, isFalse);
  });

  testWidgets("Disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CheckboxInput(
          label: "Test",
          enabled: false,
        ),
      ),
    );
    expect(find.byType(DisabledLabel), findsOneWidget);
  });

  testWidgets("Hides description", (tester) async {
    await tester.pumpWidget(Testable((_) => CheckboxInput(label: "Test")));
    expect(findFirst<ListItem>(tester).subtitle is Empty, isTrue);
  });

  testWidgets("Shows description", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CheckboxInput(
          label: "Test",
          description: "Description",
        ),
      ),
    );
    expect(findFirst<ListItem>(tester).subtitle is Empty, isFalse);
    expect(find.text("Description"), findsOneWidget);
  });

  testWidgets("ProCheckboxInput gets checked on tap if pro", (tester) async {
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await pumpContext(
      tester,
      (_) => ProCheckboxInput(
        label: "Test",
        value: false,
        onSetValue: (_) {},
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byType(Checkbox));
    expect(findFirst<Checkbox>(tester).value!, isTrue);
  });

  testWidgets("ProCheckboxInput pro page shows on tap", (tester) async {
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(
      tester,
      (_) => ProCheckboxInput(
        label: "Test",
        value: false,
        onSetValue: (_) {},
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byType(Checkbox));
    expect(find.byType(ProPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(findFirst<Checkbox>(tester).value!, isFalse);
  });

  testWidgets("ProCheckboxInput gets unchecked", (tester) async {
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await pumpContext(
      tester,
      (_) => ProCheckboxInput(
        label: "Test",
        value: true,
        onSetValue: (_) {},
      ),
      appManager: appManager,
    );

    expect(findFirst<Checkbox>(tester).value!, isTrue);

    await tapAndSettle(tester, find.byType(Checkbox));
    expect(find.byType(ProPage), findsNothing);
    expect(findFirst<Checkbox>(tester).value!, isFalse);
  });
}
