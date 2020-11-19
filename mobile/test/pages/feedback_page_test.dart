import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailer/mailer.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockIoWrapper: true,
      mockMailSenderWrapper: true,
      mockPackageInfoWrapper: true,
      mockPathProviderWrapper: true,
      mockPropertiesManager: true,
    );

    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockMailSenderWrapper.gmail(any, any)).thenReturn(null);
    when(appManager.mockPackageInfoWrapper.fromPlatform())
        .thenAnswer((_) => Future.value(PackageInfo(version: "1.0")));
    when(appManager.mockPropertiesManager.feedbackTemplate)
        .thenReturn("%s%s%s%s%s%s%s%s");
  });

  testWidgets("Message required for non-errors", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage()));
    expect(findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNull);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Custom title", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          title: "Title",
        ),
      ),
    );
    expect(find.text("Title"), findsOneWidget);
  });

  testWidgets("Default title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage()));
    expect(find.text("Send Feedback"), findsOneWidget);
  });

  testWidgets("Warning message shown", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          warningMessage: "This is a warning.",
          error: "Error",
        ),
      ),
    );
    expect(find.text("This is a warning."), findsOneWidget);
  });

  testWidgets("Warning message not shown", (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          warningMessage: "This is a warning.",
        ),
      ),
    );
    expect(find.text("This is a warning."), findsNothing);
  });

  testWidgets("Send button state updates when email changes",
      (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage()));
    expect(findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNull);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Message"), "A message.");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Email"), "test@test.com");
    expect(
        findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNotNull);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Email"), "test@tes");
    expect(findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNull);

    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Email"), "test@test.com");
    expect(
        findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNotNull);
  });

  testWidgets("For errors, type RadioInput is hidden",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          error: "Error",
        ),
      ),
    );
    expect(find.byType(RadioInput), findsNothing);
  });

  testWidgets("For non-errors, type RadioInput is shown",
      (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage()));
    expect(find.byType(RadioInput), findsOneWidget);
  });

  testWidgets("Selecting type updates state", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => FeedbackPage()));
    expect(findSiblingOfText<Icon>(tester, InkWell, "Bug").icon,
        Icons.radio_button_checked);

    await tapAndSettle(tester, find.text("Feedback"));
    expect(findSiblingOfText<Icon>(tester, InkWell, "Bug").icon,
        Icons.radio_button_unchecked);
    expect(findSiblingOfText<Icon>(tester, InkWell, "Feedback").icon,
        Icons.radio_button_checked);

    await tapAndSettle(tester, find.text("Suggestion"));
    expect(findSiblingOfText<Icon>(tester, InkWell, "Bug").icon,
        Icons.radio_button_unchecked);
    expect(findSiblingOfText<Icon>(tester, InkWell, "Feedback").icon,
        Icons.radio_button_unchecked);
    expect(findSiblingOfText<Icon>(tester, InkWell, "Suggestion").icon,
        Icons.radio_button_checked);
  });

  testWidgets("Snackbar shows for no connection", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
    ));
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(false));

    await tapAndSettle(tester, find.text("SEND"));
    expect(
        find.widgetWithText(SnackBar,
            "No internet connection. Please check your connection and try again."),
        findsOneWidget);
  });

  testWidgets("Error Snackbar shows for sending error",
      (WidgetTester tester) async {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
      navigatorObserver: navObserver,
    ));
    when(appManager.mockMailSenderWrapper.send(any, any))
        .thenAnswer((_) => throw SmtpClientAuthenticationException("Error"));

    await tapAndSettle(tester, find.text("SEND"));
    expect(
        find.widgetWithText(
            SnackBar, "Error sending feedback. Please try again later."),
        findsOneWidget);
    verifyNever(navObserver.didPop(any, any));
  });

  testWidgets("Successful send closes page", (WidgetTester tester) async {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
      navigatorObserver: navObserver,
    ));
    DateTime now = DateTime.now();
    when(appManager.mockMailSenderWrapper.send(any, any))
        .thenAnswer((_) => Future.value(SendReport(Message(), now, now, now)));

    await tapAndSettle(tester, find.text("SEND"));
    verify(navObserver.didPop(any, any)).called(1);
  });
}
