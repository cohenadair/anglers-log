import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/slide_up_transition.dart';

import '../test_utils.dart';

void main() {
  testWidgets("onDismissed callback invoked", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => SlideUpTransition(
          child: Text("Test"),
          onDismissed: () => invoked = true,
        ),
      ),
    );
    // Wait for initial animation.
    await tester.pumpAndSettle();

    // Dismiss.
    await tester.fling(find.byType(Dismissible), Offset(0, 500), 100);
    await tester.pumpAndSettle();

    expect(invoked, isTrue);
    expect(find.text("Test"), findsNothing);
  });
}
