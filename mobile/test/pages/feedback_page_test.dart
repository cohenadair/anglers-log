import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          appName: "",
          buildNumber: "",
          packageName: "",
          version: "1.0",
        ),
      ),
    );
    when(appManager.propertiesManager.feedbackTemplate)
        .thenReturn("%s%s%s%s%s%s%s%s");
  });

  testWidgets("Message required for non-errors", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));
    expect(findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNull);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Custom title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          title: "Title",
        ),
        appManager: appManager,
      ),
    );
    expect(find.text("Title"), findsOneWidget);
  });

  testWidgets("Default title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));
    expect(find.text("Send Feedback"), findsOneWidget);
  });

  testWidgets("Warning message shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          warningMessage: "This is a warning.",
          error: "Error",
        ),
        appManager: appManager,
      ),
    );
    expect(find.text("This is a warning."), findsOneWidget);
  });

  testWidgets("Warning message not shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          warningMessage: "This is a warning.",
        ),
        appManager: appManager,
      ),
    );
    expect(find.text("This is a warning."), findsNothing);
  });

  testWidgets("Send button state updates when email changes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));
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

  testWidgets("For errors, type RadioInput is hidden", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FeedbackPage(
          error: "Error",
        ),
        appManager: appManager,
      ),
    );
    expect(find.byType(RadioInput), findsNothing);
  });

  testWidgets("For non-errors, type RadioInput is shown", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));
    expect(find.byType(RadioInput), findsOneWidget);
  });

  testWidgets("Selecting type updates state", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));
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

  testWidgets("Snackbar shows for no connection", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
    ));
    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(false));

    await tapAndSettle(tester, find.text("SEND"));
    expect(
      find.widgetWithText(
        SnackBar,
        "No internet connection. Please check your connection and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets("Error Snackbar shows for sending error", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
    ));
    when(appManager.propertiesManager.supportEmail).thenReturn("test@test.com");
    when(appManager.propertiesManager.clientSenderEmail)
        .thenReturn("sender@test.com");
    when(appManager.propertiesManager.sendGridApiKey)
        .thenReturn("random-api-key");
    when(appManager.httpWrapper.post(
      any,
      headers: anyNamed("headers"),
      body: anyNamed("body"),
    )).thenAnswer((_) => Future.value(Response("", 400)));

    await tapAndSettle(tester, find.text("SEND"));
    expect(
        find.widgetWithText(
            SnackBar,
            "Error sending feedback. Please try "
            "again later, or email support@anglerslog.ca directly."),
        findsOneWidget);
    expect(
        findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNotNull);
  });

  testWidgets("Successful send closes page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
    ));
    when(appManager.propertiesManager.supportEmail).thenReturn("test@test.com");
    when(appManager.propertiesManager.clientSenderEmail)
        .thenReturn("sender@test.com");
    when(appManager.propertiesManager.sendGridApiKey)
        .thenReturn("random-api-key");
    when(appManager.httpWrapper.post(
      any,
      headers: anyNamed("headers"),
      body: anyNamed("body"),
    )).thenAnswer((_) =>
        Future.delayed(Duration(milliseconds: 165), () => Response("", 202)));

    await tester.tap(find.text("SEND"));
    await tester.pump();

    expect(find.text("SEND"), findsNothing);
    expect(find.byType(Loading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text("SEND"), findsNothing);
  });

  testWidgets("Email is filled when present", (tester) async {
    when(appManager.authManager.userEmail).thenReturn("test@test.com");

    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));

    expect(find.widgetWithText(TextInput, "test@test.com"), findsOneWidget);
  });
}
