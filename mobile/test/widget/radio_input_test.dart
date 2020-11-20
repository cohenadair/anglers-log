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
      (tester.widget(find.widgetWithText(Row, "Option 2")) as Row)
          .children
          .any((w) => w is Icon && w.icon == Icons.radio_button_checked),
      isTrue,
    );
  });

  testWidgets("Initial selected index is not set", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => RadioInput(
          optionCount: 3,
          optionBuilder: (context, i) => "Option $i",
          onSelect: (_) {},
        ),
      ),
    );
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
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
      (tester.widget(find.widgetWithText(Row, "Option 1")) as Row)
          .children
          .any((w) => w is Icon && w.icon == Icons.radio_button_checked),
      isTrue,
    );
    expect(selected, isTrue);
  });
}
