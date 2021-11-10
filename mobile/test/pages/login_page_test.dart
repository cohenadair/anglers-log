import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.appPreferenceManager.lastLoggedInEmail).thenReturn(null);
  });

  testWidgets("Button disabled when input is invalid", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));
    expect(findFirstWithText<Button>(tester, "LOGIN").onPressed, isNull);

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirstWithText<Button>(tester, "LOGIN").onPressed, isNotNull);
  });

  testWidgets("Loading indicator is shown correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirst<AnimatedVisibility>(tester).visible, isFalse);

    when(appManager.authManager.login(any, any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(const Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });

  testWidgets("Error message is shown correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    when(appManager.authManager.login(any, any)).thenAnswer((_) =>
        Future.delayed(
            const Duration(milliseconds: 50), () => AuthError.noConnection));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Please connect to the internet and try again."),
        findsOneWidget);
  });

  testWidgets("Reset password works as expected", (tester) async {
    when(appManager.authManager.sendResetPasswordEmail(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.authManager.login(any, any)).thenAnswer((_) =>
        Future.delayed(
            const Duration(milliseconds: 50), () => AuthError.wrongPassword));

    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirstWithText<Button>(tester, "LOGIN").onPressed, isNotNull);
    await tester.tap(find.text("LOGIN"));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tapRichTextContaining(
          tester, "Forgot your password? Reset it.", "Reset it."),
      isTrue,
    );
    await tester.pump();

    expect(find.text("OK"), findsOneWidget);
    verify(appManager.authManager.sendResetPasswordEmail(any)).called(1);
  });

  testWidgets("Switching modes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    expect(find.text("LOGIN"), findsOneWidget);
    expect(findRichText("Don't have an account? Sign up."), findsOneWidget);
    expect(find.text("SIGN UP"), findsNothing);
    expect(findRichText("Already have an account? Login."), findsNothing);

    expect(
      tapRichTextContaining(
          tester, "Don't have an account? Sign up.", "Sign up."),
      isTrue,
    );
    await tester.pump();

    expect(find.text("LOGIN"), findsNothing);
    expect(findRichText("Don't have an account? Sign up."), findsNothing);
    expect(find.text("SIGN UP"), findsOneWidget);
    expect(findRichText("Already have an account? Login."), findsOneWidget);

    expect(
      tapRichTextContaining(
          tester, "Already have an account? Login.", "Login."),
      isTrue,
    );
    await tester.pump();

    expect(find.text("LOGIN"), findsOneWidget);
    expect(findRichText("Don't have an account? Sign up."), findsOneWidget);
    expect(find.text("SIGN UP"), findsNothing);
    expect(find.text("Login."), findsNothing);
  });

  testWidgets("Login updates state to loading", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirst<AnimatedVisibility>(tester).visible, isFalse);

    when(appManager.authManager.login(any, any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(const Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });

  testWidgets("Sign up updates state to loading", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    expect(
      tapRichTextContaining(
          tester, "Don't have an account? Sign up.", "Sign up."),
      isTrue,
    );
    await tester.pump();

    expect(findFirst<AnimatedVisibility>(tester).visible, isFalse);

    when(appManager.authManager.signUp(any, any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("SIGN UP"));
    await tester.pump(const Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });

  testWidgets("Email is populated with last logged in email", (tester) async {
    when(appManager.appPreferenceManager.lastLoggedInEmail)
        .thenReturn("test@test.com");

    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: false),
      appManager: appManager,
    ));

    expect(find.text("test@test.com"), findsOneWidget);
  });

  testWidgets("Updating from legacy shows welcome text", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const LoginPage(isUpdatingFromLegacy: true),
      appManager: appManager,
    ));

    // Welcome widgets.
    expect(find.text("Welcome to Anglers' Log 2.0"), findsOneWidget);
    expect(find.widgetWithText(Button, "CONTINUE"), findsOneWidget);

    await tester.tap(find.widgetWithText(Button, "CONTINUE"));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text("Welcome to Anglers' Log 2.0"), findsNothing);
    expect(find.text("Anglers' Log"), findsOneWidget);
    expect(find.widgetWithText(Button, "SIGN UP"), findsOneWidget);
  });
}
