import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/multi_list_picker_input.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

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
