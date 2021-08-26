import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/style.dart';
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
          onChanged: (_) => changed = true,
        ),
      ),
    );
    await tester.enterText(find.byType(TextInput), "Input");
    await tester.pumpAndSettle();
    expect(changed, isTrue);
  });

  testWidgets("Disabled input has disabled text style", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => TextInput.name(
        _,
        controller: TextInputController()..value = "Input",
        onChanged: (_) => {},
        enabled: false,
      ),
    );

    var formField = tester.widget<TextField>(find.byType(TextField));
    expect(formField.style, styleDisabled(context));
  });
}
