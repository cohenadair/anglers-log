import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/embedded_page.dart';

import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Back button not shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => EmbeddedPage(
          showBackButton: false,
          childBuilder: (_) =>
              Scaffold(appBar: AppBar(), body: const SizedBox()),
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
          childBuilder: (_) =>
              Scaffold(appBar: AppBar(), body: const SizedBox()),
        ),
      ),
    );
    expect(find.byType(BackButton), findsOneWidget);
  });
}
