import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Title/value can't both be empty", (tester) async {
    await tester.pumpWidget(Testable((_) => ListPickerInput()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("If title is empty, value is used as title", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => ListPickerInput(
        value: "Value",
      ),
    );

    expect(find.secondaryText(context, text: "Value"), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Empty value renders not selected message", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => ListPickerInput(
        title: "Title",
      ),
    );

    expect(find.secondaryText(context, text: "Not Selected"), findsOneWidget);
  });
}
