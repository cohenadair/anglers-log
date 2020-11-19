import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/multi_list_picker_input.dart';

import '../test_utils.dart';

main() {
  testWidgets("No initial values", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          emptyValue: (_) => "Empty",
          onTap: () {},
        ),
      ),
    );
    expect(find.text("Empty"), findsOneWidget);
  });

  testWidgets("Initial values", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          values: {"Value 1", "Value 2"},
          emptyValue: (_) => "Empty",
          onTap: () {},
        ),
      ),
    );
    expect(find.text("Empty"), findsNothing);
    expect(find.text("Value 1"), findsOneWidget);
    expect(find.text("Value 2"), findsOneWidget);
  });

  testWidgets("Custom padding", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          emptyValue: (_) => "Empty",
          onTap: () {},
          padding: insetsDefault,
        ),
      ),
    );
    expect(findFirst<Padding>(tester).padding.horizontal, paddingDefault * 2);
  });

  testWidgets("Default padding", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          emptyValue: (_) => "Empty",
          onTap: () {},
        ),
      ),
    );
    expect(findFirst<Padding>(tester).padding.horizontal, 0);
  });
}
