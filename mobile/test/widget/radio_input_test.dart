import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Initial selected index is set", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => RadioInput(
          optionCount: 3,
          optionBuilder: (context, i) => "Option $i",
          onSelect: (_) {},
          initialSelectedIndex: 2,
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.widgetWithText(Row, "Option 2"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Title is set", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => RadioInput(
          optionCount: 3,
          optionBuilder: (context, i) => "Option $i",
          onSelect: (_) {},
          title: "Title",
        ),
      ),
    );
    expect(find.byType(HeadingLabel), findsOneWidget);
  });

  testWidgets("Title is not set", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => RadioInput(
          optionCount: 3,
          optionBuilder: (context, i) => "Option $i",
          onSelect: (_) {},
        ),
      ),
    );
    expect(find.byType(HeadingLabel), findsNothing);
  });

  testWidgets("Change selection", (tester) async {
    var selected = false;
    await tester.pumpWidget(
      Testable(
        (_) => RadioInput(
          optionCount: 3,
          optionBuilder: (context, i) => "Option $i",
          onSelect: (_) => selected = true,
        ),
      ),
    );
    await tester.tap(find.text("Option 1"));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.widgetWithText(Row, "Option 1"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(selected, isTrue);
  });
}
