import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/styled_bottom_sheet.dart';

import '../test_utils.dart';

main() {
  testWidgets("onDismissed callback invoked", (WidgetTester tester) async {
    bool invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => StyledBottomSheet(
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
