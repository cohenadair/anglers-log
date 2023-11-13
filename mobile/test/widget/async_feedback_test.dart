import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/widgets/work_result.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.userName).thenReturn(null);
    when(appManager.userPreferenceManager.userEmail).thenReturn(null);
  });

  testWidgets("Action button disabled while loading", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.loading,
        action: () {},
      ),
    );

    expect(findFirst<Button>(tester).onPressed, isNull);
  });

  testWidgets("Action button enabled while idle", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.none,
        action: () {},
      ),
    );

    expect(findFirst<Button>(tester).onPressed, isNotNull);
  });

  testWidgets("Feedback empty when idle", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.none,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Feedback while loading", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.loading,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Feedback success", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.success,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Feedback error", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.error,
        action: () {},
        feedbackPage: const FeedbackPage(),
      ),
      appManager: appManager,
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
    expect(find.text("SEND REPORT"), findsOneWidget);

    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Feedback page is hidden", (tester) async {
    await pumpContext(
      tester,
      (_) => const AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.error,
      ),
      appManager: appManager,
    );
    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Action requires Pro subscription", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value());

    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "ACTION",
        state: AsyncFeedbackState.error,
        actionRequiresPro: true,
        action: () {},
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("ACTION"));
    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Action is invoked", (tester) async {
    var called = false;
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "ACTION",
        actionRequiresPro: false,
        action: () => called = true,
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("ACTION"));
    expect(find.byType(ProPage), findsNothing);
    expect(called, isTrue);
  });
}
