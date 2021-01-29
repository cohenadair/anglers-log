import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
    );
  });

  testWidgets("Button disabled when input is invalid", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => LoginPage(),
      appManager: appManager,
    ));
    expect(findFirst<Button>(tester).onPressed, isNull);

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirst<Button>(tester).onPressed, isNotNull);
  });

  testWidgets("Loading indicator is shown correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => LoginPage(),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirst<AnimatedVisibility>(tester).visible, isFalse);

    when(appManager.mockAuthManager.login(any, any)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });

  testWidgets("Error message is shown correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => LoginPage(),
      appManager: appManager,
    ));

    // Title label.
    expect(find.byType(Label), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    when(appManager.mockAuthManager.login(any, any)).thenAnswer((_) =>
        Future.delayed(
            Duration(milliseconds: 50), () => AuthError.noConnection));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(Duration(milliseconds: 100));

    expect(find.text("Please connect to the internet and try again."),
        findsOneWidget);
    expect(find.byType(Label), findsNWidgets(2));
  });

  testWidgets("Switching modes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => LoginPage(),
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
      (_) => LoginPage(),
      appManager: appManager,
    ));

    await tester.enterText(
        find.widgetWithText(TextInput, "Email"), "test@test.com");
    await tester.enterText(
        find.widgetWithText(TextInput, "Password"), "123456");
    await tester.pump();

    expect(findFirst<AnimatedVisibility>(tester).visible, isFalse);

    when(appManager.mockAuthManager.login(any, any)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("LOGIN"));
    await tester.pump(Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });

  testWidgets("Sign up updates state to loading", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => LoginPage(),
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

    when(appManager.mockAuthManager.signUp(any, any)).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50), () => null));

    await tester.tap(find.text("SIGN UP"));
    await tester.pump(Duration(milliseconds: 100));

    expect(findFirst<AnimatedVisibility>(tester).visible, isTrue);
  });
}
