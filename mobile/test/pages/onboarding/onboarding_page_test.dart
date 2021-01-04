import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/onboarding_page.dart';
import 'package:mobile/widgets/button.dart';

import '../../test_utils.dart';

void main() {
  testWidgets("Disabled next button doesn't show bottom bar", (tester) async {
    await tester.pumpWidget(Testable((_) => OnboardingPage()));
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(ActionButton), findsNothing);
  });

  testWidgets("Bottom bar buttons shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingPage(
          onPressedNextButton: () {},
        ),
      ),
    );
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.text("NEXT"), findsOneWidget);
  });

  testWidgets("Custom next button text", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingPage(
          nextButtonText: "Finished",
          onPressedNextButton: () {},
        ),
      ),
    );
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.text("NEXT"), findsNothing);
    expect(find.text("FINISHED"), findsOneWidget);
  });

  testWidgets("Next button is disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => OnboardingPage(
          onPressedNextButton: () {},
          nextButtonEnabled: false,
        ),
      ),
    );
    expect(find.byType(IconButton), findsOneWidget);
    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);
  });
}
