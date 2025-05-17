import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/landing_page.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Error is shown", (tester) async {
    await tester
        .pumpWidget(Testable((context) => const LandingPage(hasError: false)));
    expect(find.byType(Align), findsNWidgets(2));
  });

  testWidgets("Error is hidden", (tester) async {
    await tester
        .pumpWidget(Testable((context) => const LandingPage(hasError: true)));
    expect(find.byType(Align), findsNWidgets(3));
  });
}
