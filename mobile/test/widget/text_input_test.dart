import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';

import '../test_utils.dart';

void main() {
  testWidgets("onChanged callback is invoked", (tester) async {
    var changed = false;
    await tester.pumpWidget(
      Testable(
        (_) => TextInput.name(
          _,
          controller: TextInputController(),
          onChanged: () => changed = true,
        ),
      ),
    );
    await tester.enterText(find.byType(TextInput), "Input");
    await tester.pumpAndSettle();
    expect(changed, isTrue);
  });
}
