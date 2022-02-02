import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/embedded_page.dart';
import 'package:mobile/widgets/widget.dart';

import '../../test_utils.dart';

void main() {
  testWidgets("Back button not shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EmbeddedPage(
          showBackButton: false,
          childBuilder: (_) => Scaffold(
            appBar: AppBar(),
            body: const Empty(),
          ),
        ),
      ),
    );
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets("Back button shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EmbeddedPage(
          showBackButton: true,
          childBuilder: (_) => Scaffold(
            appBar: AppBar(),
            body: const Empty(),
          ),
        ),
      ),
    );
    expect(find.byType(BackButton), findsOneWidget);
  });
}
