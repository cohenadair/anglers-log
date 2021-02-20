import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockHttpWrapper: true,
      mockIoWrapper: true,
      mockPackageInfoWrapper: true,
      mockPathProviderWrapper: true,
      mockPropertiesManager: true,
    );

    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockPackageInfoWrapper.fromPlatform())
        .thenAnswer((_) => Future.value(PackageInfo(version: "1.0")));
    when(appManager.mockPropertiesManager.feedbackTemplate)
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
    when(appManager.mockIoWrapper.isConnected())
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
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
      navigatorObserver: navObserver,
    ));
    when(appManager.mockHttpWrapper.post(
      any,
      auth: anyNamed("auth"),
      body: anyNamed("body"),
    )).thenAnswer((_) => Future.value(Response("", 400)));

    await tapAndSettle(tester, find.text("SEND"));
    expect(
        find.widgetWithText(
            SnackBar, "Error sending feedback. Please try again later."),
        findsOneWidget);
    verifyNever(navObserver.didPop(any, any));
    expect(
        findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNotNull);
  });

  testWidgets("Successful send closes page", (tester) async {
    var navObserver = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(
        error: "Error",
      ),
      appManager: appManager,
      navigatorObserver: navObserver,
    ));
    when(appManager.mockHttpWrapper.post(
      any,
      auth: anyNamed("auth"),
      body: anyNamed("body"),
    )).thenAnswer((_) => Future.value(Response("", 202)));

    await tester.tap(find.text("SEND"));
    await tester.pump();

    expect(findFirstWithText<ActionButton>(tester, "SEND").onPressed, isNull);

    await tester.pumpAndSettle();
    verify(navObserver.didPop(any, any)).called(1);
  });

  testWidgets("Email is filled when present", (tester) async {
    when(appManager.mockAuthManager.userEmail).thenReturn("test@test.com");

    await tester.pumpWidget(Testable(
      (_) => FeedbackPage(),
      appManager: appManager,
    ));

    expect(find.widgetWithText(TextInput, "test@test.com"), findsOneWidget);
  });
}
