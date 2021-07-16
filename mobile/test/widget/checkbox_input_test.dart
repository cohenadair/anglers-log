import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
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
}
