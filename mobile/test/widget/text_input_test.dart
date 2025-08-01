import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("onChanged callback is invoked", (tester) async {
    var changed = false;
    await tester.pumpWidget(
      Testable(
        (context) => TextInput.name(
          context,
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
      (context) => TextInput.name(
        context,
        controller: TextInputController()..value = "Input",
        onChanged: (_) => {},
        enabled: false,
      ),
    );

    var formField = tester.widget<TextField>(find.byType(TextField));
    expect(formField.style, styleDisabled(context));
  });
}
