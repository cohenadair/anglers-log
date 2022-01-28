import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/work_result.dart';

import '../test_utils.dart';

void main() {
  testWidgets("With description", (tester) async {
    await pumpContext(
      tester,
      (_) => const WorkResult.success(
        description: "Test description",
      ),
    );
    expect(find.text("Test description"), findsOneWidget);
  });

  testWidgets("Without description", (tester) async {
    await pumpContext(
      tester,
      (_) => const WorkResult.success(),
    );
    expect(find.byType(Text), findsNothing);
  });
}
