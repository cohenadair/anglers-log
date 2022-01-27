import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/feedback_page.dart';
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

  testWidgets("Assertion is thrown for errors without feedback page",
      (tester) async {
    expect(
      () => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.error,
      ),
      throwsAssertionError,
    );
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
}
