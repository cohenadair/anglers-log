import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/email_verification_page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.sendVerificationEmail(any))
        .thenAnswer((_) => Future.value(false));
  });

  testWidgets("_FeedbackState.none", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const EmailVerificationPage(),
      appManager: appManager,
    ));

    expect(
      find.ancestor(
          of: find.byType(Empty), matching: find.byType(AnimatedSwitcher)),
      findsOneWidget,
    );
  });

  testWidgets("_FeedbackState.loading", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const EmailVerificationPage(),
      appManager: appManager,
    ));

    when(appManager.authManager.sendVerificationEmail(any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => false));

    await tester.tap(find.text("SEND AGAIN"));
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);

    // Give sendVerificationEmail future time to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("_FeedbackState.notVerified", (tester) async {
    when(appManager.authManager.sendVerificationEmail(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.authManager.reloadUser()).thenAnswer((_) => Future.value());
    when(appManager.authManager.isUserVerified).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => const EmailVerificationPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("NEXT"));

    expect(
      find.text(
          "Your email has not yet been verified. Clicking the link verifies you are the owner of the email associated with this account."),
      findsOneWidget,
    );
  });

  testWidgets("_FeedbackState.emailResent", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const EmailVerificationPage(),
      appManager: appManager,
    ));

    when(appManager.authManager.sendVerificationEmail(any))
        .thenAnswer((_) => Future.value(true));

    await tapAndSettle(tester, find.text("SEND AGAIN"));
    expect(find.text("Email sent!"), findsOneWidget);
  });

  testWidgets("onNext called when user is verified", (tester) async {
    when(appManager.authManager.sendVerificationEmail(any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.authManager.reloadUser()).thenAnswer((_) => Future.value());
    when(appManager.authManager.isUserVerified).thenReturn(true);

    var called = false;
    await tester.pumpWidget(Testable(
      (_) => EmailVerificationPage(
        onNext: () => called = true,
      ),
      appManager: appManager,
    ));

    await tester.tap(find.text("NEXT"));
    await tester.pump();

    expect(called, isTrue);
  });
}
