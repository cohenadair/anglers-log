import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/multi_list_picker_input.dart';

import '../test_utils.dart';

void main() {
  testWidgets("No initial values", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          values: const {},
          emptyValue: (_) => "Empty",
          onTap: () {},
        ),
      ),
    );
    expect(find.text("Empty"), findsOneWidget);
  });

  testWidgets("Initial values", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => MultiListPickerInput(
          values: const {"Value 1", "Value 2"},
          emptyValue: (_) => "Empty",
          onTap: () {},
        ),
      ),
    );
    expect(find.text("Empty"), findsNothing);
    expect(find.text("Value 1"), findsOneWidget);
    expect(find.text("Value 2"), findsOneWidget);
  });
}
