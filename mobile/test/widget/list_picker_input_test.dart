import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Title/value can't both be empty", (tester) async {
    await tester.pumpWidget(Testable((_) => ListPickerInput()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("If title is empty, value is used as title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ListPickerInput(
          value: "Value",
        ),
      ),
    );
    expect(find.widgetWithText(Label, "Value"), findsOneWidget);
    expect(find.byType(SecondaryText), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Empty value renders not selected message", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ListPickerInput(
          title: "Title",
        ),
      ),
    );
    expect(find.byType(SecondaryText), findsOneWidget);
    expect(find.text("Not Selected"), findsOneWidget);
  });
}
