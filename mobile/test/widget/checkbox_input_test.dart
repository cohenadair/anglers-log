import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/text.dart';

import '../test_utils.dart';

main() {
  testWidgets("Enabled", (WidgetTester tester) async {
    bool checked = false;
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

  testWidgets("Disabled", (WidgetTester tester) async {
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
}
