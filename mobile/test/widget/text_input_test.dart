import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/text_input.dart';

import '../test_utils.dart';

main() {
  testWidgets("onChanged callback is invoked", (WidgetTester tester) async {
    bool changed = false;
    await tester.pumpWidget(
      Testable(
        (_) => TextInput.name(
          _,
          onChanged: () => changed = true,
        ),
      ),
    );
    await tester.enterText(find.byType(TextInput), "Input");
    await tester.pumpAndSettle();
    expect(changed, isTrue);
  });
}
